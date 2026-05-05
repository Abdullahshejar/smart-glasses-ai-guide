import 'dart:async';
import 'dart:developer' as dev;
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';

// Text-To-Speech service.
//
// Two modes:
//   audioBytes provided  → plays the MP3 returned by the Flask backend
//   audioBytes null      → mock delay (used in mock / direct-API modes)
//
// Audio plays through the default audio output, including Bluetooth earphones.
class TtsService {
  final _player = AudioPlayer();
  bool _isSpeaking = false;
  bool get isSpeaking => _isSpeaking;

  Future<void> init() async {
    // Set audio context so it plays through earphones/speaker
    await _player.setAudioContext(
      AudioContext(
        android: AudioContextAndroid(
          isSpeakerphoneOn: false,
          stayAwake: false,
          contentType: AndroidContentType.speech,
          usageType: AndroidUsageType.assistant,
          audioFocus: AndroidAudioFocus.gain,
        ),
      ),
    );
    dev.log('[TTS] Initialised', name: 'TtsService');
  }

  // Speak the answer.
  // [audioBytes] — MP3 from Flask backend; null → uses mock delay instead.
  Future<void> speak(String text, {Uint8List? audioBytes}) async {
    if (_isSpeaking) await stop();

    _isSpeaking = true;

    if (audioBytes != null) {
      // Play the real MP3 returned by Flask / OpenAI TTS
      dev.log('[TTS] Playing backend audio (${audioBytes.length} bytes)',
          name: 'TtsService');

      final completer = Completer<void>();
      StreamSubscription<void>? sub;

      sub = _player.onPlayerComplete.listen((_) {
        if (!completer.isCompleted) completer.complete();
        sub?.cancel();
      });

      await _player.play(BytesSource(audioBytes));
      await completer.future;
    } else {
      // Mock: simulate speaking time (~80 ms per word)
      dev.log('[TTS] Mock speaking: "$text"', name: 'TtsService');
      final wordCount = text.split(' ').length;
      await Future.delayed(Duration(milliseconds: wordCount * 80));
    }

    _isSpeaking = false;
    dev.log('[TTS] Done', name: 'TtsService');
  }

  Future<void> stop() async {
    await _player.stop();
    _isSpeaking = false;
    dev.log('[TTS] Stopped', name: 'TtsService');
  }

  void dispose() {
    _player.dispose();
  }
}
