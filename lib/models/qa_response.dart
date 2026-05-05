import 'dart:typed_data';

// The answer returned by the LLM service.
// [answer]     — text shown on screen
// [audioText]  — text passed to mock TTS (same as answer in most cases)
// [audioBytes] — MP3 bytes from Flask backend TTS (null in mock mode)
class QaResponse {
  final String answer;
  final String audioText;
  final Uint8List? audioBytes; // non-null when Flask backend returns TTS audio

  const QaResponse({
    required this.answer,
    required this.audioText,
    this.audioBytes,
  });

  // Convenience: mock mode — text only, no audio bytes
  factory QaResponse.simple(String text) {
    return QaResponse(answer: text, audioText: text);
  }
}
