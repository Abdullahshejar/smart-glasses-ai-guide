import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config/app_config.dart';
import '../core/config/llm_config.dart';
import '../models/artifact_profile.dart';
import '../models/qa_response.dart';
import 'backend_service.dart';

// Sends the artifact context + user question to an LLM and returns the answer.
//
// Three modes (set in Settings):
//   LlmMode.mock  — instant mock answer, no network call
//   LlmMode.flask — calls local Flask backend (app.py) via BackendService
//   LlmMode.live  — calls OpenAI-compatible API directly
//
// Falls back to mock automatically on any network or API error.
class LlmService {
  final _backendService = BackendService();

  Future<QaResponse> ask({
    required ArtifactProfile profile,
    required String question,
  }) async {
    switch (appConfig.llmMode) {
      case LlmMode.flask:
        try {
          final result = await _backendService.ask(
            paintingName: profile.id,
            question: question,
          );
          // Return answer text + MP3 bytes from Flask TTS
          return QaResponse(
            answer: result.answer,
            audioText: result.answer,
            audioBytes: result.audioBytes,
          );
        } catch (_) {
          // Flask unreachable — fall back to mock
          return _mockResponse(profile, question,
              note: '(Flask unavailable — showing mock answer)');
        }

      case LlmMode.live:
        if (llmConfig.apiKey.isNotEmpty) {
          try {
            return await _liveAsk(profile: profile, question: question);
          } catch (_) {
            return _mockResponse(profile, question,
                note: '(Live API unavailable — showing mock answer)');
          }
        }
        // No API key set — fall through to mock
        return _mockResponse(profile, question);

      case LlmMode.mock:
        await Future.delayed(const Duration(seconds: 2));
        return _mockResponse(profile, question);
    }
  }

  // ── Direct OpenAI-compatible API call ────────────────────────────
  Future<QaResponse> _liveAsk({
    required ArtifactProfile profile,
    required String question,
  }) async {
    final response = await http
        .post(
          Uri.parse(llmConfig.apiEndpoint),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${llmConfig.apiKey}',
          },
          body: json.encode({
            'model': llmConfig.model,
            'max_tokens': llmConfig.maxTokens,
            'messages': [
              {'role': 'system', 'content': _systemPrompt},
              {
                'role': 'user',
                'content':
                    '${profile.toContextString()}\nVisitor question: $question',
              },
            ],
          }),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final answer =
          (data['choices'] as List).first['message']['content'] as String;
      return QaResponse.simple(answer.trim());
    }
    throw Exception('API returned ${response.statusCode}');
  }

  // ── Mock response ────────────────────────────────────────────────
  QaResponse _mockResponse(ArtifactProfile profile, String question,
      {String note = ''}) {
    final fact = profile.facts.isNotEmpty ? profile.facts.first : '';
    final answer = 'Great question about "${profile.name}" by ${profile.artist}! '
        'This ${profile.style.toLowerCase()} work was created in ${profile.year}. '
        '$fact'
        '${note.isNotEmpty ? ' $note' : ''}';
    return QaResponse.simple(answer);
  }

  static const _systemPrompt =
      'You are a friendly, knowledgeable museum guide. '
      'Answer questions about artworks clearly and engagingly. '
      'Keep responses to 2–3 sentences.';
}
