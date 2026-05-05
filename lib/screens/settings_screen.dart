import 'package:flutter/material.dart';
import '../core/config/app_config.dart';
import '../core/config/llm_config.dart';
import '../core/theme/app_theme.dart';

// Settings screen — all changes apply instantly via appConfig / llmConfig.
// ChangeNotifier propagates changes to HomeScreen without a restart.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _flaskUrlCtrl;
  late final TextEditingController _apiKeyCtrl;
  late final TextEditingController _endpointCtrl;
  late final TextEditingController _modelCtrl;
  late final TextEditingController _frameUrlCtrl;
  late final TextEditingController _piAddressCtrl;

  @override
  void initState() {
    super.initState();
    _flaskUrlCtrl  = TextEditingController(text: llmConfig.flaskBaseUrl);
    _apiKeyCtrl    = TextEditingController(text: llmConfig.apiKey);
    _endpointCtrl  = TextEditingController(text: llmConfig.apiEndpoint);
    _modelCtrl     = TextEditingController(text: llmConfig.model);
    _frameUrlCtrl  = TextEditingController(text: appConfig.frameSourceUrl);
    _piAddressCtrl = TextEditingController(text: appConfig.piAddress);
  }

  @override
  void dispose() {
    _flaskUrlCtrl.dispose();
    _apiKeyCtrl.dispose();
    _endpointCtrl.dispose();
    _modelCtrl.dispose();
    _frameUrlCtrl.dispose();
    _piAddressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appConfig,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Settings')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── Recognition ──────────────────────────────────────
              _sectionHeader('Recognition'),
              _modeToggle<RecognitionMode>(
                label: 'Recognition Mode',
                value: appConfig.recognitionMode,
                options: RecognitionMode.values,
                labels: const ['Mock', 'Live (ONNX)'],
                onChanged: appConfig.setRecognitionMode,
              ),
              if (appConfig.recognitionMode == RecognitionMode.live)
                _infoTile(
                  icon: Icons.check_circle_outline,
                  color: AppTheme.success,
                  text: 'ONNX model loaded from assets/models/best.onnx\n'
                      'YOLOv8 · 12 paintings · 640×640 input',
                ),

              const SizedBox(height: 24),

              // ── LLM ──────────────────────────────────────────────
              _sectionHeader('LLM / Answer Source'),
              _modeToggle<LlmMode>(
                label: 'LLM Mode',
                value: appConfig.llmMode,
                options: LlmMode.values,
                labels: const ['Mock', 'Direct API', 'Flask Backend'],
                onChanged: appConfig.setLlmMode,
              ),

              // Flask backend fields
              if (appConfig.llmMode == LlmMode.flask) ...[
                const SizedBox(height: 12),
                _infoTile(
                  icon: Icons.info_outline,
                  text: 'Start app.py on your Mac, then enter its local IP below.\n'
                      'Find your Mac IP: System Settings → Wi-Fi → Details',
                ),
                const SizedBox(height: 8),
                _textField(
                  label: 'Flask URL',
                  controller: _flaskUrlCtrl,
                  hint: 'http://192.168.1.x:5001',
                  onChanged: (v) => llmConfig.flaskBaseUrl = v,
                ),
              ],

              // Direct API fields
              if (appConfig.llmMode == LlmMode.live) ...[
                const SizedBox(height: 12),
                _textField(
                  label: 'API Key',
                  controller: _apiKeyCtrl,
                  hint: 'sk-...',
                  obscure: true,
                  onChanged: (v) => llmConfig.apiKey = v,
                ),
                const SizedBox(height: 12),
                _textField(
                  label: 'Endpoint',
                  controller: _endpointCtrl,
                  hint: 'https://api.openai.com/v1/chat/completions',
                  onChanged: (v) => llmConfig.apiEndpoint = v,
                ),
                const SizedBox(height: 12),
                _textField(
                  label: 'Model',
                  controller: _modelCtrl,
                  hint: 'gpt-4o-mini',
                  onChanged: (v) => llmConfig.model = v,
                ),
              ],

              const SizedBox(height: 24),

              // ── Frame Source ──────────────────────────────────────
              _sectionHeader('Frame Source'),
              _modeToggle<FrameSourceMode>(
                label: 'Frame Source',
                value: appConfig.frameSourceMode,
                options: FrameSourceMode.values,
                labels: const ['Asset', 'URL', 'Raspberry Pi'],
                onChanged: appConfig.setFrameSourceMode,
              ),
              if (appConfig.frameSourceMode == FrameSourceMode.url) ...[
                const SizedBox(height: 12),
                _textField(
                  label: 'Image URL',
                  controller: _frameUrlCtrl,
                  hint: 'http://192.168.1.x:8080/frame.jpg',
                  onChanged: (v) => appConfig.setFrameSourceUrl(v),
                ),
              ],
              if (appConfig.frameSourceMode == FrameSourceMode.raspberryPi) ...[
                const SizedBox(height: 12),
                _textField(
                  label: 'Pi IP Address',
                  controller: _piAddressCtrl,
                  hint: '192.168.1.x',
                  onChanged: (v) => appConfig.setPiAddress(v),
                ),
                _infoTile(
                  icon: Icons.construction,
                  text: 'Pi streaming is a placeholder — see '
                      'services/frame_source/pi_frame_source.dart to implement.',
                ),
              ],
              if (appConfig.frameSourceMode == FrameSourceMode.asset)
                _infoTile(
                  icon: Icons.image_outlined,
                  text: 'Add a sample image to:\nassets/images/sample_artifact.jpg',
                ),

              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: AppTheme.accent,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _modeToggle<T>({
    required String label,
    required T value,
    required List<T> options,
    required List<String> labels,
    required ValueChanged<T> onChanged,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SegmentedButton<T>(
                segments: List.generate(
                  options.length,
                  (i) =>
                      ButtonSegment(value: options[i], label: Text(labels[i])),
                ),
                selected: {value},
                onSelectionChanged: (s) => onChanged(s.first),
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: AppTheme.primary,
                  selectedForegroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _textField({
    required String label,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
    String hint = '',
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
        filled: true,
        fillColor: AppTheme.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String text,
    Color color = Colors.white38,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: TextStyle(color: color, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
