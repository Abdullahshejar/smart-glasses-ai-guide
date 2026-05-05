import 'dart:async';
import 'package:http/http.dart' as http;
import 'frame_source.dart';

// Fetches JPEG frames from the Pi camera HTTP server.
// The Pi must be running camera_stream.py which serves /frame.jpg on port 8080.
class PiFrameSource implements FrameSource {
  final String piAddress;
  final int port;

  final _controller = StreamController<FrameData>.broadcast();
  Timer? _timer;
  bool _active = false;

  PiFrameSource({
    required this.piAddress,
    this.port = 8080,
  });

  String get _url => 'http://$piAddress:$port/frame.jpg';

  @override
  Future<void> start() async {
    _active = true;
    await _fetchFrame();
    _timer = Timer.periodic(const Duration(milliseconds: 300), (_) => _fetchFrame());
  }

  Future<void> _fetchFrame() async {
    if (!_active || _controller.isClosed) return;
    try {
      final response = await http
          .get(Uri.parse(_url))
          .timeout(const Duration(seconds: 3));
      if (response.statusCode == 200 && !_controller.isClosed) {
        _controller.add(FrameData.fromBytes(response.bodyBytes));
      }
    } catch (_) {
      // missed frame — try again next tick
    }
  }

  @override
  Stream<FrameData> get stream => _controller.stream;

  @override
  void stop() {
    _active = false;
    _timer?.cancel();
    if (!_controller.isClosed) _controller.close();
  }
}
