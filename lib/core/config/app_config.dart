import 'package:flutter/foundation.dart';

enum RecognitionMode { mock, live }
enum LlmMode { mock, live, flask } // flask = call local Flask backend
enum FrameSourceMode { asset, url, raspberryPi }

// Single global instance — all services and screens reference this.
final appConfig = AppConfig();

/// Holds all runtime configuration switches.
/// Extends [ChangeNotifier] so widgets rebuild when settings change.
/// Defaults are all safe for testing with no real hardware or API keys.
class AppConfig extends ChangeNotifier {
  // ── Recognition ────────────────────────────────────────────────
  RecognitionMode _recognitionMode = RecognitionMode.mock;
  RecognitionMode get recognitionMode => _recognitionMode;

  void setRecognitionMode(RecognitionMode mode) {
    if (_recognitionMode == mode) return;
    _recognitionMode = mode;
    notifyListeners();
  }

  // ── LLM ────────────────────────────────────────────────────────
  LlmMode _llmMode = LlmMode.flask;
  LlmMode get llmMode => _llmMode;

  void setLlmMode(LlmMode mode) {
    if (_llmMode == mode) return;
    _llmMode = mode;
    notifyListeners();
  }

  // ── Frame source ───────────────────────────────────────────────
  FrameSourceMode _frameSourceMode = FrameSourceMode.asset;
  FrameSourceMode get frameSourceMode => _frameSourceMode;

  void setFrameSourceMode(FrameSourceMode mode) {
    if (_frameSourceMode == mode) return;
    _frameSourceMode = mode;
    notifyListeners();
  }

  // URL used when frameSourceMode == FrameSourceMode.url
  String _frameSourceUrl = 'http://192.168.1.100:8080/frame.jpg';
  String get frameSourceUrl => _frameSourceUrl;

  void setFrameSourceUrl(String url) {
    _frameSourceUrl = url;
    notifyListeners();
  }

  // IP address used when frameSourceMode == FrameSourceMode.raspberryPi
  String _piAddress = '192.168.1.100';
  String get piAddress => _piAddress;

  void setPiAddress(String address) {
    _piAddress = address;
    notifyListeners();
  }
}
