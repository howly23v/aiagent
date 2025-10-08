const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

app.use(express.json());

app.get('/', (req, res) => {
  res.send('AI VTuber Generator: service is running');
});

app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

const { callGeminiApi } = require('./gemini');

app.post('/generate', async (req, res) => {
  const { prompt } = req.body;
  if (!prompt) return res.status(400).json({ error: 'prompt required' });

  if (process.env.GEMINI_API_KEY) {
    try {
      const result = await callGeminiApi(prompt);
      return res.json({ ok: true, result });
    } catch (err) {
      console.error('Gemini call failed:', err);
      return res.status(502).json({ error: 'Gemini API call failed', message: err.message });
    }
  }

  // Fallback placeholder response when GEMINI_API_KEY is not set
  res.json({
    message: 'GEMINI_API_KEY not set — placeholder response. Set GEMINI_API_KEY to enable real generation.',
    prompt
  });
});

app.listen(port, () => {
  console.log(`AI VTuber Generator listening on port ${port}`);
});
