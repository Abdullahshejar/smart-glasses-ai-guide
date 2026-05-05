// LLM configuration — used when LlmMode.live or LlmMode.flask is active.
// Edit these values in the Settings screen at runtime.

// Single global instance
final llmConfig = LlmConfig();

class LlmConfig {
  // ── Flask backend (LlmMode.flask) ──────────────────────────────
  // Base URL of the Flask server running on the same WiFi network.
  // Format: http://<your-mac-local-ip>:5001
  // Find your Mac's IP: System Settings → Wi-Fi → Details
  String flaskBaseUrl = 'http://172.20.10.2:5001';

  // ── Direct OpenAI-compatible API (LlmMode.live) ────────────────
  String apiEndpoint = 'https://api.openai.com/v1/chat/completions';
  String apiKey = '';           // set your API key here
  String model = 'gpt-4o-mini';
  int maxTokens = 300;
}
