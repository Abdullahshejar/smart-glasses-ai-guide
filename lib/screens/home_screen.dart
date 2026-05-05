import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../core/config/app_config.dart';
import '../models/artifact_result.dart';
import '../models/device_status.dart';
import '../services/pi_connection_service.dart';
import '../services/recognition_service.dart';
import '../services/artifact_profile_service.dart';
import '../services/llm_service.dart';
import '../services/tts_service.dart';
import '../services/history_service.dart';
import '../services/speech_service.dart';
import '../services/frame_source/frame_source.dart';
import '../services/frame_source/asset_frame_source.dart';
import '../services/frame_source/url_frame_source.dart';
import '../services/frame_source/pi_frame_source.dart';
import '../widgets/device_status_indicator.dart';
import '../widgets/frame_preview.dart';
import '../widgets/artifact_card.dart';
import '../widgets/talk_button.dart';
import '../widgets/answer_card.dart';
import '../widgets/processing_indicator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ── Services ─────────────────────────────────────────────────────
  final _piService        = PiConnectionService();
  final _recognitionSvc   = RecognitionService();
  final _profileService   = ArtifactProfileService();
  final _llmService       = LlmService();
  final _ttsService       = TtsService();
  final _historyService   = HistoryService();
  final _speechService    = SpeechService();

  // ── Frame source (recreated when config changes) ─────────────────
  FrameSource? _frameSource;
  StreamSubscription<FrameData>? _frameSub;
  FrameData? _currentFrame;

  // ── UI state ──────────────────────────────────────────────────────
  DeviceStatus _deviceStatus = const DeviceStatus.disconnected();
  ArtifactResult? _artifactResult;
  String? _answer;
  bool _isRecognizing  = false;
  bool _isListening    = false;
  bool _isThinking     = false;
  bool _isSpeaking     = false;
  bool _loopActive     = false;
  String? _spokenText;
  String?   _lastAudioText;
  Uint8List? _lastAudioBytes;

  StreamSubscription<DeviceStatus>? _statusSub;

  static const String _mockQuestion = 'Tell me about this artifact.';

  static const _mockPaintings = [
    ArtifactResult(id: 'woman_doves',         name: 'Woman of the Doves',        confidence: 1.0),
    ArtifactResult(id: 'woman_smoke',         name: 'Woman in Smoke',            confidence: 1.0),
    ArtifactResult(id: 'fish_net',            name: 'The Struggle',              confidence: 1.0),
    ArtifactResult(id: 'butterfly_women',     name: 'Butterfly Women',           confidence: 1.0),
    ArtifactResult(id: 'woman_fish',          name: 'The Eye of the Ocean',      confidence: 1.0),
    ArtifactResult(id: 'abstract_colorburst', name: 'The Fractured Cosmos',      confidence: 1.0),
    ArtifactResult(id: 'abstract_landscape',  name: 'Fading Shore',              confidence: 1.0),
    ArtifactResult(id: 'woman_horse',         name: 'The Guardian and the Grey', confidence: 1.0),
    ArtifactResult(id: 'night_sky',           name: 'The Quiet Hours',           confidence: 1.0),
    ArtifactResult(id: 'seashell',            name: 'What the Sea Left Behind',  confidence: 1.0),
    ArtifactResult(id: 'bridge_sunset',       name: 'The Crossing at Dusk',      confidence: 1.0),
    ArtifactResult(id: 'musician_women',      name: 'The Garden Concert',        confidence: 1.0),
  ];

  // ── Lifecycle ─────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    // Re-init frame source whenever config changes (e.g. user switches in Settings)
    appConfig.addListener(_onConfigChanged);
    _startup();
  }

  Future<void> _startup() async {
    await Future.wait([
      _profileService.loadProfiles(),
      _ttsService.init(),
      _recognitionSvc.loadModel(),
      _speechService.init(),
    ]);

    _statusSub = _piService.statusStream.listen((status) {
      if (!mounted) return;
      setState(() => _deviceStatus = status);
      if (status.isConnected) _startRecognitionLoop();
    });

    _initFrameSource();       // set up first frame source
    await _piService.connect();
  }

  // Called when user changes any setting — rebuilds frame source
  void _onConfigChanged() {
    if (!mounted) return;
    _initFrameSource();
    // If user just switched to Live mode and Pi is connected, start the loop
    if (appConfig.recognitionMode == RecognitionMode.live &&
        _deviceStatus.isConnected &&
        !_loopActive) {
      _startRecognitionLoop();
    }
    // If user switched to Mock mode, clear any live result
    if (appConfig.recognitionMode == RecognitionMode.mock) {
      setState(() { _artifactResult = null; _isRecognizing = false; });
    }
  }

  // ── Frame source ──────────────────────────────────────────────────
  void _initFrameSource() {
    _frameSub?.cancel();
    _frameSource?.stop();
    setState(() => _currentFrame = null);

    _frameSource = _buildFrameSource();
    _frameSub = _frameSource!.stream.listen((frame) {
      if (mounted) setState(() => _currentFrame = frame);
    });
    _frameSource!.start();
  }

  FrameSource _buildFrameSource() {
    switch (appConfig.frameSourceMode) {
      case FrameSourceMode.asset:
        return AssetFrameSource();
      case FrameSourceMode.url:
        return UrlFrameSource(url: appConfig.frameSourceUrl);
      case FrameSourceMode.raspberryPi:
        return PiFrameSource(piAddress: appConfig.piAddress);
    }
  }

  // ── Recognition loop ──────────────────────────────────────────────
  Future<void> _startRecognitionLoop() async {
    if (appConfig.recognitionMode == RecognitionMode.mock) return;
    if (_loopActive) return;
    _loopActive = true;
    while (mounted && _deviceStatus.isConnected &&
        appConfig.recognitionMode == RecognitionMode.live) {
      setState(() => _isRecognizing = true);

      // Resolve frame bytes from whatever source is active
      List<int>? frameBytes;
      if (_currentFrame?.bytes != null) {
        frameBytes = _currentFrame!.bytes;
      } else if (_currentFrame?.assetPath != null) {
        final data = await rootBundle.load(_currentFrame!.assetPath!);
        frameBytes = data.buffer.asUint8List();
      }

      final result = await _recognitionSvc.recognize(frameBytes);

      if (!mounted) break;
      setState(() {
        _isRecognizing = false;
        _artifactResult = result;
      });

      await Future.delayed(const Duration(seconds: 3));
    }
    _loopActive = false;
  }

  // ── Talk button ───────────────────────────────────────────────────
  Future<void> _onTalkPressed() async {
    if (_isListening || _isThinking || _artifactResult == null) return;

    // 1. Listening — real speech recognition
    setState(() { _isListening = true; _answer = null; _spokenText = null; });
    final spoken = await _speechService.listen();
    final question = (spoken != null && spoken.trim().isNotEmpty)
        ? spoken.trim()
        : _mockQuestion;
    if (mounted) setState(() => _spokenText = question);

    final profile = _profileService.getProfile(_artifactResult!.id);
    if (!mounted) return;
    if (profile == null) { setState(() => _isListening = false); return; }

    // 2. LLM
    setState(() { _isListening = false; _isThinking = true; });
    final response = await _llmService.ask(profile: profile, question: question);
    if (!mounted) return;

    // 3. Show answer + speak
    setState(() { _isThinking = false; _isSpeaking = true; _answer = response.answer; });
    _lastAudioText  = response.audioText;
    _lastAudioBytes = response.audioBytes;

    _historyService.save(
      artifactName: _artifactResult!.name,
      question: question,
      answer: response.answer,
    );

    await _ttsService.speak(response.audioText, audioBytes: response.audioBytes);
    if (!mounted) return;
    setState(() => _isSpeaking = false);
  }

  Widget _buildMockPicker() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SELECT PAINTING',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppTheme.accent,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: _artifactResult?.id,
              hint: const Text('Choose a painting to test...'),
              isExpanded: true,
              underline: const SizedBox.shrink(),
              items: _mockPaintings
                  .map((p) => DropdownMenuItem(
                        value: p.id,
                        child: Text(p.name, style: const TextStyle(fontSize: 14)),
                      ))
                  .toList(),
              onChanged: (id) {
                if (id == null) return;
                setState(() => _artifactResult =
                    _mockPaintings.firstWhere((p) => p.id == id));
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onStopPressed() async {
    await _ttsService.stop();
    if (mounted) setState(() => _isSpeaking = false);
  }

  Future<void> _onRepeatPressed() async {
    if (_lastAudioText == null || _isSpeaking) return;
    setState(() => _isSpeaking = true);
    await _ttsService.speak(_lastAudioText!, audioBytes: _lastAudioBytes);
    if (mounted) setState(() => _isSpeaking = false);
  }

  void _onEndTour() => Navigator.pushNamed(
        context, AppConstants.routeEndTour,
        arguments: _historyService.items);

  @override
  void dispose() {
    appConfig.removeListener(_onConfigChanged);
    _statusSub?.cancel();
    _frameSub?.cancel();
    _frameSource?.stop();
    _piService.dispose();
    _ttsService.dispose();
    _speechService.dispose();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final bool isBusy = _isListening || _isThinking;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.pushNamed(context, AppConstants.routeSettings),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Connection status — only meaningful in live mode
              if (appConfig.recognitionMode == RecognitionMode.live) ...[
                DeviceStatusIndicator(isConnected: _deviceStatus.isConnected),
                const SizedBox(height: 16),
              ],

              // Frame preview — live or placeholder
              FramePreview(frame: _currentFrame),
              const SizedBox(height: 16),

              // Manual painting picker in mock mode
              if (appConfig.recognitionMode == RecognitionMode.mock) ...[
                _buildMockPicker(),
                const SizedBox(height: 16),
              ],

              // Detected artifact
              ArtifactCard(
                artifactName: _artifactResult?.name,
                artifactId: _artifactResult?.id,
                confidence: _artifactResult?.confidence,
              ),
              const SizedBox(height: 16),

              // Processing indicator
              if (_isRecognizing || isBusy)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Center(
                    child: ProcessingIndicator(
                      label: _isRecognizing
                          ? 'Detecting artifact...'
                          : _isListening
                              ? 'Listening...'
                              : 'Getting answer...',
                    ),
                  ),
                ),

              // Talk button
              TalkButton(
                isListening: _isListening,
                isDisabled: isBusy || _artifactResult == null,
                onPressed: _onTalkPressed,
              ),
              const SizedBox(height: 12),

              // What the user said
              if (_isListening)
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(Icons.mic, size: 14, color: AppTheme.error),
                      SizedBox(width: 6),
                      Text('Speak now — waiting for your question...',
                          style: TextStyle(color: AppTheme.error, fontSize: 13)),
                    ],
                  ),
                )
              else if (_spokenText != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.person_outline, size: 14, color: Colors.white54),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '"$_spokenText"',
                          style: const TextStyle(color: Colors.white70, fontSize: 13,
                              fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                  ),
                ),

              // Answer
              AnswerCard(
                answer: _answer,
                isSpeaking: _isSpeaking,
                onStop: _onStopPressed,
                onRepeat: _onRepeatPressed,
              ),
              const SizedBox(height: 24),

              // Bottom actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pushNamed(
                          context, AppConstants.routeHistory,
                          arguments: _historyService.items),
                      icon: const Icon(Icons.history, size: 18),
                      label: Text('History (${_historyService.count})'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.onSurface,
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _onEndTour,
                      icon: const Icon(Icons.flag_outlined, size: 18),
                      label: const Text('End Tour'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.error.withValues(alpha: 0.8),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
