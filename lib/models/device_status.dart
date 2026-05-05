// Represents the connection state of the Raspberry Pi device.
enum DeviceConnectionState {
  connected,
  disconnected,
  connecting,
  error,
}

class DeviceStatus {
  final DeviceConnectionState state;
  final String? errorMessage; // non-null when state == error

  const DeviceStatus({
    required this.state,
    this.errorMessage,
  });

  // Convenience constructors
  const DeviceStatus.connected() : state = DeviceConnectionState.connected, errorMessage = null;
  const DeviceStatus.disconnected() : state = DeviceConnectionState.disconnected, errorMessage = null;
  const DeviceStatus.connecting() : state = DeviceConnectionState.connecting, errorMessage = null;
  const DeviceStatus.error(String message) : state = DeviceConnectionState.error, errorMessage = message;

  bool get isConnected => state == DeviceConnectionState.connected;

  String get label {
    switch (state) {
      case DeviceConnectionState.connected:    return 'Pi Connected';
      case DeviceConnectionState.disconnected: return 'Pi Disconnected';
      case DeviceConnectionState.connecting:   return 'Connecting...';
      case DeviceConnectionState.error:        return 'Error';
    }
  }
}
