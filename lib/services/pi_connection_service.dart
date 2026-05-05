import 'dart:async';
import '../models/device_status.dart';

// Manages the connection to the Raspberry Pi Zero 2 W.
// Phase 4: fully mocked — simulates connecting and emitting periodic frames.
// Phase 4+: replace the internals with a real TCP/WebSocket/HTTP stream.
class PiConnectionService {
  // Current connection status exposed as a stream
  final _statusController = StreamController<DeviceStatus>.broadcast();
  Stream<DeviceStatus> get statusStream => _statusController.stream;

  // Latest raw frame bytes from the Pi (null until first frame arrives)
  // Phase 4: always null — real implementation will populate this
  List<int>? get currentFrameBytes => _currentFrameBytes;
  List<int>? _currentFrameBytes;

  DeviceStatus _status = const DeviceStatus.disconnected();
  DeviceStatus get status => _status;

  Timer? _mockFrameTimer;

  // Call once at app start. Simulates the Pi connecting after a short delay.
  Future<void> connect() async {
    _emit(const DeviceStatus.connecting());

    await Future.delayed(const Duration(seconds: 2));

    _emit(const DeviceStatus.connected());

    // Simulate a new frame arriving every 500ms
    _mockFrameTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      // In real implementation: receive JPEG bytes from Pi and set _currentFrameBytes
      // For now we just signal that a frame is "available" without real data
    });
  }

  // Cleanly disconnect from the Pi
  Future<void> disconnect() async {
    _mockFrameTimer?.cancel();
    _mockFrameTimer = null;
    _currentFrameBytes = null;
    _emit(const DeviceStatus.disconnected());
  }

  void _emit(DeviceStatus status) {
    _status = status;
    _statusController.add(status);
  }

  void dispose() {
    _mockFrameTimer?.cancel();
    _statusController.close();
  }
}
