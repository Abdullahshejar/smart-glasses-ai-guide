import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart';

// Wraps the device's built-in speech recognition.
// Call init() once at startup, then listen() each time the user speaks.
class SpeechService {
  final _stt = SpeechToText();
  bool _ready = false;

  bool get isReady => _ready;

  Future<void> init() async {
    _ready = await _stt.initialize(onError: (_) {});
  }

  // Records until silence (2 s pause) or 15 s max.
  // Returns the transcribed text, or null if nothing was heard.
  Future<String?> listen() async {
    if (!_ready) return null;

    final completer = Completer<String>();
    var last = '';

    await _stt.listen(
      onResult: (result) {
        last = result.recognizedWords;
        if (result.finalResult && !completer.isCompleted) {
          completer.complete(last);
        }
      },
      listenFor: const Duration(seconds: 20),
      pauseFor: const Duration(seconds: 4),
      listenOptions: SpeechListenOptions(cancelOnError: true),
    );

    try {
      return await completer.future.timeout(const Duration(seconds: 17));
    } catch (_) {
      return last.isEmpty ? null : last;
    }
  }

  Future<void> stop() => _stt.stop();

  void dispose() => _stt.cancel();
}
