// src/gemini.js
// Server-side helper to call a Gemini-like API. This is a sample implementation
// showing how to safely use an API key from environment variables, set a timeout,
// and return normalized text result. Replace the endpoint and payload with the
// actual Gemini API spec you are using.

const DEFAULT_TIMEOUT_MS = 20_000; // 20 seconds

async function callGeminiApi(prompt, { timeoutMs = DEFAULT_TIMEOUT_MS } = {}) {
  const apiKey = process.env.GEMINI_API_KEY;
  if (!apiKey) throw new Error('GEMINI_API_KEY not set in environment');

  // Replace with the real Gemini endpoint and request shape
  const url = 'https://api.gemini.example/v1/generate';

  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), timeoutMs);

  try {
    const res = await fetch(url, {
      method: 'POST',
      signal: controller.signal,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${apiKey}`,
      },
      body: JSON.stringify({
        prompt,
        // Add other model/config params here if needed
      }),
    });

    if (!res.ok) {
      const txt = await res.text().catch(() => '<no body>');
      const err = new Error(`Gemini API error: ${res.status} ${res.statusText}: ${txt}`);
      err.status = res.status;
      throw err;
    }

    const data = await res.json().catch(() => null);

    // Normalize response: try to extract text in a few common shapes.
    if (!data) return { raw: null };
    if (typeof data.text === 'string') return { text: data.text, raw: data };
    if (data.output && typeof data.output === 'string') return { text: data.output, raw: data };
    // Fallback: stringify
    return { text: JSON.stringify(data), raw: data };
  } finally {
    clearTimeout(timeout);
  }
}

module.exports = {
  callGeminiApi,
};
