// App-wide constant values

class AppConstants {
  AppConstants._(); // prevent instantiation

  static const String appName = 'Museum Guide';

  // Route names
  static const String routeHome = '/';
  static const String routeHistory = '/history';
  static const String routeSettings = '/settings';
  static const String routeEndTour = '/end-tour';

  // Mock delay durations (simulating network / model inference)
  static const Duration mockRecognitionDelay = Duration(seconds: 2);
  static const Duration mockLlmDelay = Duration(seconds: 3);
}
