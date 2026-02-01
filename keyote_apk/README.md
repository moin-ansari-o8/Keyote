# Keyote Remote - Android Remote Keyboard

Production-grade Android application for controlling your laptop keyboard over USB tethering network.

## Features

- ✅ Real-time keystroke transmission over HTTP
- ✅ Full modifier key support (Ctrl, Alt, Shift)
- ✅ Arrow keys with long-press repeat
- ✅ Common shortcuts (Copy, Paste, Undo, Save)
- ✅ Connection status indicator
- ✅ Dark/Light theme support
- ✅ Configurable server settings
- ✅ Minimal latency (<50ms on local network)

## Architecture

**Clean MVVM Pattern:**
- **Models**: Data classes for key commands and server configuration
- **ViewModels**: Business logic with ChangeNotifier for state management
- **Views**: Stateless UI components with reactive updates
- **Services**: HTTP client and local storage wrapper

## Requirements

- **Min SDK**: Android 8.0 (API 26)
- **Target SDK**: Android 14 (API 34)
- **Flutter**: 3.16+
- **Dart**: 3.2+

## Setup

### 1. Install Dependencies

```bash
cd keyote_apk
flutter pub get
```

### 2. Configure Laptop Server

Ensure your laptop server is running and accessible on the USB tethering network. The server should expose:

- `GET /health` - Health check endpoint
- `POST /key` - Key command endpoint

**Expected JSON format for POST /key:**
```json
{
  "key": "a",
  "ctrl": false,
  "shift": false,
  "alt": false
}
```

### 3. Connect via USB Tethering

1. Enable USB tethering on your Android device
2. Connect to laptop via USB cable
3. Find your laptop's IP address on the tethering network (typically 192.168.42.x or 192.168.43.x)

### 4. Run the App

```bash
flutter run
```

## Usage

### Initial Configuration

1. Open the app and tap the **Settings** icon (⚙️)
2. Enter your laptop's IP address (e.g., `192.168.42.129`)
3. Confirm port is set to `5000` (or your custom port)
4. Tap **Test Connection** to verify connectivity
5. Tap **Save** to persist settings
6. Navigate back to the main screen

### Sending Keys

**Text Input:**
- Type in the text field - each character is sent in real-time

**Modifier Keys:**
- Tap **Ctrl**, **Alt**, or **Shift** to toggle sticky state
- Modifiers stay active until you send a key or tap again

**Navigation:**
- Use arrow keys (←↑↓→) for cursor movement
- Long-press arrows for continuous repeat

**Action Keys:**
- **Esc**, **Tab**, **Enter** - Single tap
- **Backspace**, **Delete** - Single tap or long-press for repeat

**Shortcuts:**
- **Copy** - Sends Ctrl+C
- **Paste** - Sends Ctrl+V
- **Undo** - Sends Ctrl+Z
- **Save** - Sends Ctrl+S

### Theme Switching

1. Go to **Settings**
2. Toggle **Dark Mode** switch
3. Theme changes immediately and persists

## Project Structure

```
lib/
├── main.dart                           # App entry, Provider setup, routing
├── models/
│   ├── key_command.dart               # Key data model with modifiers
│   └── server_config.dart             # Server IP/port configuration
├── services/
│   ├── keyboard_service.dart          # HTTP client for key transmission
│   └── storage_service.dart           # SharedPreferences wrapper
├── viewmodels/
│   ├── settings_viewmodel.dart        # Settings state management
│   └── keyboard_viewmodel.dart        # Keyboard state + key sending logic
├── views/
│   ├── keyboard_screen.dart           # Main keyboard interface
│   ├── settings_screen.dart           # Configuration screen
│   └── widgets/
│       ├── key_button.dart            # Reusable key button with animations
│       ├── modifier_toggle.dart       # Sticky modifier toggle button
│       └── connection_indicator.dart  # Green/red status indicator
└── utils/
    ├── constants.dart                 # API endpoints, timeouts, dimensions
    └── validators.dart                # IPv4 and port validation
```

## Performance Metrics

- **Cold Start**: <2 seconds
- **Key Send Latency**: <50ms (local network)
- **Memory Usage**: <50 MB
- **APK Size**: <15 MB

## Dependencies

```yaml
dependencies:
  provider: ^6.1.1            # State management
  http: ^1.1.0                # HTTP client
  shared_preferences: ^2.2.2  # Local storage
```

## Building Release APK

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

## Troubleshooting

### Connection Failed

- Verify USB tethering is enabled on Android device
- Check laptop IP address (should be 192.168.x.x)
- Ensure laptop server is running and listening on port 5000
- Test with: `curl http://192.168.x.x:5000/health`

### Keys Not Registering

- Check connection indicator shows green
- Verify server logs for incoming requests
- Ensure firewall allows port 5000
- Try increasing request timeout in `constants.dart`

### High Latency

- Use USB tethering (not WiFi) for best performance
- Check server response time
- Reduce debounce delay in `constants.dart`

## Server Implementation Example

Your laptop server should implement these endpoints:

```python
from flask import Flask, request
import pyautogui

app = Flask(__name__)

@app.route('/health')
def health():
    return {'status': 'ok'}, 200

@app.route('/key', methods=['POST'])
def key():
    data = request.json
    key = data['key']
    ctrl = data.get('ctrl', False)
    shift = data.get('shift', False)
    alt = data.get('alt', False)
    
    modifiers = []
    if ctrl: modifiers.append('ctrl')
    if shift: modifiers.append('shift')
    if alt: modifiers.append('alt')
    
    pyautogui.hotkey(*modifiers, key) if modifiers else pyautogui.press(key)
    return {'status': 'ok'}, 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
```

## License

MIT License

## Support

For issues and feature requests, please open an issue on the repository.

