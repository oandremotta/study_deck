import { onRequest } from "firebase-functions/v2/https";
import { defineSecret } from "firebase-functions/params";
import Stripe from "stripe";
import * as admin from "firebase-admin";

// Initialize Firebase Admin
admin.initializeApp();

const GEMINI_API_KEY = defineSecret("GEMINI_API_KEY");
const STRIPE_SECRET_KEY = defineSecret("STRIPE_SECRET_KEY");

// Environment: "dev" (test mode) or "prod" (live mode)
const STRIPE_ENV = process.env.STRIPE_ENV || "dev";

// Credit packages - reads from .env based on STRIPE_ENV
const getCreditPackages = () => {
  if (STRIPE_ENV === "prod") {
    return {
      credits_50: { priceId: process.env.PROD_PRICE_CREDITS_50 || "", credits: 50 },
      credits_150: { priceId: process.env.PROD_PRICE_CREDITS_150 || "", credits: 150 },
      credits_500: { priceId: process.env.PROD_PRICE_CREDITS_500 || "", credits: 500 },
    };
  }
  // Default: dev
  return {
    credits_50: { priceId: process.env.DEV_PRICE_CREDITS_50 || "", credits: 50 },
    credits_150: { priceId: process.env.DEV_PRICE_CREDITS_150 || "", credits: 150 },
    credits_500: { priceId: process.env.DEV_PRICE_CREDITS_500 || "", credits: 500 },
  };
};

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

// Subscription prices - reads from .env based on STRIPE_ENV
const getSubscriptionPrices = () => {
  if (STRIPE_ENV === "prod") {
    return {
      monthly: process.env.PROD_PRICE_MONTHLY || "",
      annual: process.env.PROD_PRICE_ANNUAL || "",
      lifetime: process.env.PROD_PRICE_LIFETIME || "",
    };
  }
  // Default: dev
  return {
    monthly: process.env.DEV_PRICE_MONTHLY || "",
    annual: process.env.DEV_PRICE_ANNUAL || "",
    lifetime: process.env.DEV_PRICE_LIFETIME || "",
  };
};

// Helper to resolve packageId to priceId and credits
const resolveCreditPackage = (packageId: string) => {
  const packages = getCreditPackages();
  return packages[packageId as keyof typeof packages] || null;
};

// Helper to check if packageId is valid
const isValidCreditPackage = (packageId: string) => resolveCreditPackage(packageId) !== null;

export const createStripeCheckout = onRequest(
  { secrets: [STRIPE_SECRET_KEY], cors: true, region: "us-central1" },
  async (req, res) => {
    try {
      if (req.method !== "POST") {
        res.status(405).json({ error: "Method not allowed" });
        return;
      }

      // Accept either packageId (for credits) or planId (for subscriptions)
      const { packageId, planId, userId, userEmail, successUrl, cancelUrl } = req.body;

      if (!userId) {
        res.status(400).json({ error: "Missing userId" });
        return;
      }

      if (!packageId && !planId) {
        res.status(400).json({ error: "Missing packageId or planId" });
        return;
      }

      const stripe = new Stripe(STRIPE_SECRET_KEY.value());
      const subscriptionPrices = getSubscriptionPrices();

      let priceId: string;
      let credits = 0;
      let isSubscription = false;
      let isCredit = false;

      // Resolve priceId from packageId or planId
      if (packageId) {
        // Credit package purchase
        const creditPackage = resolveCreditPackage(packageId);
        if (!creditPackage) {
          res.status(400).json({ error: `Invalid packageId: ${packageId}` });
          return;
        }
        priceId = creditPackage.priceId;
        credits = creditPackage.credits;
        isCredit = true;
      } else {
        // Subscription purchase
        const validPlans = ["monthly", "annual", "lifetime"];
        if (!validPlans.includes(planId)) {
          res.status(400).json({ error: `Invalid planId: ${planId}` });
          return;
        }
        priceId = subscriptionPrices[planId as keyof typeof subscriptionPrices];
        isSubscription = planId !== "lifetime";
      }

      console.log(`Creating checkout: env=${STRIPE_ENV}, priceId=${priceId}, credits=${credits}`);

      const session = await stripe.checkout.sessions.create({
        payment_method_types: ["card"],
        mode: isSubscription ? "subscription" : "payment",
        line_items: [
          {
            price: priceId,
            quantity: 1,
          },
        ],
        ...(userEmail && { customer_email: userEmail }),
        client_reference_id: userId,
        success_url: successUrl || "https://studydeck-78bde.web.app/subscription/success",
        cancel_url: cancelUrl || "https://studydeck-78bde.web.app/subscription/cancel",
        metadata: {
          userId: userId,
          priceId: priceId,
          packageId: packageId || "",
          planId: planId || "",
          type: isCredit ? "credits" : "subscription",
          credits: credits.toString(),
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
          const userId = session.client_reference_id || session.metadata?.userId;
          const metadata = session.metadata || {};

          console.log("Payment successful for user:", userId);
          console.log("Session metadata:", metadata);

          // Handle credit package purchase
          if (metadata.type === "credits" && metadata.credits) {
            const creditsToAdd = parseInt(metadata.credits, 10);

            if (userId && creditsToAdd > 0) {
              const db = admin.firestore();

              // Add credits to user's balance in Firestore
              const userCreditsRef = db.collection("user_credits").doc(userId);

              await db.runTransaction(async (transaction) => {
                const doc = await transaction.get(userCreditsRef);
                const currentBalance = doc.exists ? (doc.data()?.available || 0) : 0;
                const currentTotal = doc.exists ? (doc.data()?.totalEarned || 0) : 0;

                transaction.set(userCreditsRef, {
                  userId: userId,
                  available: currentBalance + creditsToAdd,
                  totalEarned: currentTotal + creditsToAdd,
                  lastPurchase: admin.firestore.FieldValue.serverTimestamp(),
                  updatedAt: admin.firestore.FieldValue.serverTimestamp(),
                }, { merge: true });
              });

              // Log the purchase
              await db.collection("credit_purchases").add({
                userId: userId,
                credits: creditsToAdd,
                priceId: metadata.priceId,
                sessionId: session.id,
                amount: session.amount_total,
                currency: session.currency,
                createdAt: admin.firestore.FieldValue.serverTimestamp(),
              });

              console.log(`Added ${creditsToAdd} credits to user ${userId}`);
            }
          } else {
            // Handle subscription purchase
            // TODO: Update user's premium status in Firestore
            console.log("Subscription purchase - implement premium status update");
          }
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
