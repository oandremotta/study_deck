import { onRequest } from "firebase-functions/v2/https";
import { defineSecret } from "firebase-functions/params";

const GEMINI_API_KEY = defineSecret("GEMINI_API_KEY");

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
