class AppConstants {
  static const String keyEndpoint = '/key';
  static const String healthEndpoint = '/health';

  static const int requestTimeout = 1;
  static const int keyRepeatInterval = 100;
  static const int debounceDelay = 50;

  static const double minTapTarget = 56.0;
  static const int animationDuration = 200;

  static const String prefKeyServerConfig = 'server_config';
  static const String prefKeyThemeMode = 'theme_mode';
  static const String prefKeySoundEnabled = 'sound_enabled';
  static const String prefKeySelectedSound = 'selected_sound';

  // Sound options
  static const String soundClick = 'click.wav';
  static const String soundMechanicalOne = 'key-press1.mp3';
  static const String soundMechanicalTwo = 'key-press2.mp3';
  static const String defaultSound = soundMechanicalOne;

  static const Map<String, String> soundLabels = {
    soundClick: 'Click',
    soundMechanicalOne: 'Mechanical One',
    soundMechanicalTwo: 'Mechanical Two',
  };
}
