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

app.post('/generate', async (req, res) => {
  const { prompt } = req.body;
  if (!prompt) return res.status(400).json({ error: 'prompt required' });

  // Placeholder: in production you'd call the Gemini API here using GEMINI_API_KEY
  res.json({
    message: 'This is a placeholder response. Replace with Gemini API call.',
    prompt
  });
});

app.listen(port, () => {
  console.log(`AI VTuber Generator listening on port ${port}`);
});
