import { onRequest } from "firebase-functions/v2/https";
import { defineSecret } from "firebase-functions/params";
import Stripe from "stripe";

const GEMINI_API_KEY = defineSecret("GEMINI_API_KEY");
const STRIPE_SECRET_KEY = defineSecret("STRIPE_SECRET_KEY");

export const generateWithGemini = onRequest(
  { secrets: [GEMINI_API_KEY], cors: true, region: 'us-central1' },
  async (req, res) => {
    try {
      // Validate request method
      if (req.method !== "POST") {
        res.status(405).json({ error: "Method not allowed" });
        return;
      }

      const { prompt, model } = req.body;
      if (!prompt || typeof prompt !== "string") {
        res.status(400).json({ error: "Missing or invalid prompt" });
        return;
      }

      // Call Gemini API
      const modelName = model || "gemini-2.5-flash-lite";
      const url = `https://generativelanguage.googleapis.com/v1beta/models/${modelName}:generateContent?key=${GEMINI_API_KEY.value()}`;

      const geminiResponse = await fetch(url, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          contents: [{ role: "user", parts: [{ text: prompt }] }],
          generationConfig: { response_mime_type: "application/json" }
        })
      });

      const data = await geminiResponse.json();

      if (!geminiResponse.ok) {
        const errorMessage = data?.error?.message || "Gemini API error";
        console.error("Gemini error:", errorMessage);
        res.status(geminiResponse.status).json({ error: errorMessage });
        return;
      }

      const text = data?.candidates?.[0]?.content?.parts?.[0]?.text ?? "";
      res.status(200).json({ text, raw: data });
    } catch (error: unknown) {
      console.error("Function error:", error);
      const message = error instanceof Error ? error.message : "Internal error";
      res.status(500).json({ error: message });
    }
  }
);

// ============ Stripe Checkout ============

// Product prices in Stripe
const PRICE_IDS = {
  monthly: "price_1SvubBGUSTQ8gR9hEwwN1JXm",
  annual: "price_1SvubhGUSTQ8gR9hgHbo2Sy9",
  lifetime: "price_1Svuc2GUSTQ8gR9hDC0rKi84a",
};

export const createStripeCheckout = onRequest(
  { secrets: [STRIPE_SECRET_KEY], cors: true, region: "us-central1" },
  async (req, res) => {
    try {
      if (req.method !== "POST") {
        res.status(405).json({ error: "Method not allowed" });
        return;
      }

      const { priceId, userId, userEmail, successUrl, cancelUrl } = req.body;

      if (!priceId || !userId || !userEmail) {
        res.status(400).json({ error: "Missing priceId, userId, or userEmail" });
        return;
      }

      const stripe = new Stripe(STRIPE_SECRET_KEY.value());

      // Determine if it's a subscription or one-time payment
      const isSubscription = priceId !== PRICE_IDS.lifetime;

      const session = await stripe.checkout.sessions.create({
        payment_method_types: ["card"],
        mode: isSubscription ? "subscription" : "payment",
        line_items: [
          {
            price: priceId,
            quantity: 1,
          },
        ],
        customer_email: userEmail,
        client_reference_id: userId,
        success_url: successUrl || "https://studydeck-78bde.web.app/subscription/success",
        cancel_url: cancelUrl || "https://studydeck-78bde.web.app/subscription/cancel",
        metadata: {
          userId: userId,
          plan: priceId,
        },
      });

      res.status(200).json({ url: session.url, sessionId: session.id });
    } catch (error: unknown) {
      console.error("Stripe checkout error:", error);
      const message = error instanceof Error ? error.message : "Checkout error";
      res.status(500).json({ error: message });
    }
  }
);

// Stripe Webhook to handle successful payments
export const stripeWebhook = onRequest(
  { secrets: [STRIPE_SECRET_KEY], region: "us-central1" },
  async (req, res) => {
    try {
      const stripe = new Stripe(STRIPE_SECRET_KEY.value());
      const sig = req.headers["stripe-signature"] as string;

      // For now, just log the event - webhook secret needed for verification
      // In production, verify with: stripe.webhooks.constructEvent(req.rawBody, sig, webhookSecret)

      const event = req.body;

      switch (event.type) {
        case "checkout.session.completed": {
          const session = event.data.object;
          console.log("Payment successful for user:", session.client_reference_id);
          // TODO: Update user's premium status in Firestore
          break;
        }
        case "customer.subscription.deleted": {
          const subscription = event.data.object;
          console.log("Subscription cancelled:", subscription.id);
          // TODO: Remove user's premium status
          break;
        }
        default:
          console.log(`Unhandled event type: ${event.type}`);
      }

      res.status(200).json({ received: true });
    } catch (error: unknown) {
      console.error("Webhook error:", error);
      res.status(400).json({ error: "Webhook error" });
    }
  }
);
