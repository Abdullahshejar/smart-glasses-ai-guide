import 'dart:async';
import 'package:http/http.dart' as http;
import 'frame_source.dart';

// Fetches JPEG frames from a static URL at a fixed interval.
// Works with any HTTP image server — including a phone camera app,
// a Pi serving still frames, or a test image URL.
class UrlFrameSource implements FrameSource {
  final String url;
  final Duration fetchInterval;

  final _controller = StreamController<FrameData>.broadcast();
  Timer? _timer;

  UrlFrameSource({
    required this.url,
    this.fetchInterval = const Duration(seconds: 1),
  });

  @override
  Future<void> start() async {
    await _fetchFrame(); // immediate first fetch
    _timer = Timer.periodic(fetchInterval, (_) => _fetchFrame());
  }

  Future<void> _fetchFrame() async {
    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200 && !_controller.isClosed) {
        _controller.add(FrameData.fromBytes(response.bodyBytes));
      }
    } catch (_) {
      // Silently skip — frame just won't update on this tick
    }
  }

  @override
  Stream<FrameData> get stream => _controller.stream;

  @override
  void stop() {
    _timer?.cancel();
    if (!_controller.isClosed) _controller.close();
  }
}
