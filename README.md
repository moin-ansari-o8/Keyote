# 🎹 Keyote — USB Tethering Remote Keyboard

> **Transform your phone into a wireless keyboard for your laptop. No drivers. No root. No chaos.**

[![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20Linux%20%7C%20macOS-blue)]()
[![Android](https://img.shields.io/badge/Android-Flutter-02569B)]()
[![Python](https://img.shields.io/badge/Python-3.10%2B-green)]()
[![License](https://img.shields.io/badge/License-MIT-yellow)]()

---

## 📋 Table of Contents

- [Concept](#-concept)
- [Architecture](#-architecture)
- [Why This Approach Wins](#-why-this-approach-wins)
- [Project Structure](#-project-structure)
- [System Requirements](#-system-requirements)
- [Agent Prompts](#-agent-prompts)
  - [Laptop Server Prompt](#1-laptop-server--python)
  - [Flutter App Prompt](#2-flutter-app--android)
- [Setup & Usage](#-setup--usage)
- [API Specification](#-api-specification)
- [Future Roadmap](#-future-roadmap)
- [Professional Recommendations](#-professional-recommendations)
- [Troubleshooting](#-troubleshooting)

---

## 🎯 Concept

**Keyote is not a Bluetooth keyboard. It's a command tunnel.**

### Mental Model

```
Phone (Flutter App)          Laptop (Python Server)
┌─────────────────┐         ┌──────────────────────┐
│                 │         │                      │
│  Remote Control │────────▶│  Local Key Executor  │
│   (HTTP Client) │  USB    │   (Event Injector)   │
│                 │ Tethering│                      │
└─────────────────┘         └──────────────────────┘
```

### How It Works

1. **USB Cable** → Phone connects to laptop via USB
2. **USB Tethering** → Creates private network (`192.168.x.x`)
3. **Flutter App** → Sends key commands via HTTP POST
4. **Python Server** → Receives commands on local network
5. **OS Injection** → Simulates real keyboard events using `pynput`

**Deterministic. Reliable. Cross-platform.**

---

## 🏗️ Architecture

### System Flow Diagram

```
┌──────────────────────────────────────────────────────────┐
│                     KEYOTE SYSTEM                        │
└──────────────────────────────────────────────────────────┘

┌─────────────────┐                    ┌──────────────────┐
│                 │                    │                  │
│  PHONE LAYER    │                    │  LAPTOP LAYER    │
│                 │                    │                  │
│ ┌─────────────┐ │                    │ ┌──────────────┐ │
│ │   UI Layer  │ │                    │ │ HTTP Server  │ │
│ │  (Flutter)  │ │                    │ │ (Flask/Fast) │ │
│ └──────┬──────┘ │                    │ └──────┬───────┘ │
│        │        │                    │        │         │
│ ┌──────▼──────┐ │                    │ ┌──────▼───────┐ │
│ │HTTP Client  │ │  JSON over USB     │ │Event Handler │ │
│ │  (async)    │◄├───────────────────▶├─│  (pynput)    │ │
│ └─────────────┘ │   Tethering        │ └──────┬───────┘ │
│                 │   (192.168.x.x)    │        │         │
└─────────────────┘                    │ ┌──────▼───────┐ │
                                       │ │  OS Keyboard │ │
                                       │ │   Injection  │ │
                                       │ └──────────────┘ │
                                       └──────────────────┘
```

### Key Design Principles

- **Boring Tech** = Reliable tech (HTTP over WebSocket for v1)
- **Offline-first** = No internet dependency
- **Zero-config** = Minimal setup friction
- **Single responsibility** = Phone sends, laptop executes
- **Fail-safe** = Graceful degradation on network issues

---

## 🏆 Why This Approach Wins

### vs USB HID Emulation

| Feature | Network Method (Keyote) | USB HID |
|---------|------------------------|---------|
| **Setup Complexity** | ✅ Minimal | ❌ Driver hell |
| **Cross-platform** | ✅ Works everywhere | ❌ OS-specific |
| **Development Speed** | ✅ Fast | ❌ Slow |
| **Debugging** | ✅ HTTP logs | ❌ Binary protocols |
| **Scalability** | ✅ Easy extensions | ❌ Limited |
| **Admin Required** | ✅ No | ❌ Often yes |

**Engineers choose boring, reliable tech. Boring = powerful.**

---

## 📁 Project Structure

```
keyote/
├── README.md                 # This file
├── laptop-server/            # Python server (local executor)
│   ├── server.py            # Main HTTP server
│   ├── requirements.txt     # Python dependencies
│   ├── config.json          # Server configuration
│   └── README.md            # Server-specific docs
│
└── keyote-apk/              # Flutter app (remote control)
    ├── lib/
    │   ├── main.dart        # App entry
    │   ├── models/          # Data models
    │   ├── services/        # HTTP client, storage
    │   ├── viewmodels/      # MVVM logic
    │   └── views/           # UI screens
    ├── pubspec.yaml
    └── README.md            # App-specific docs
```

---

## 💻 System Requirements

### Laptop Server

- **OS**: Windows 10/11, Linux (Ubuntu 20.04+), macOS 11+
- **Python**: 3.10 or higher
- **RAM**: 50 MB (minimal footprint)
- **Network**: USB tethering support
- **Privileges**: No admin required

### Phone App

- **OS**: Android 8.0+ (API 26+)
- **Storage**: ~15 MB
- **Permissions**: Internet (local network only)
- **USB**: Tethering capability (99% devices)

---

## 🤖 Agent Prompts

> **These are production-ready prompts for AI coding agents. Copy, paste, and build.**

### 1️⃣ Laptop Server — Python

```
You are a senior Python systems engineer with expertise in network services and OS-level automation.

=== GOAL ===
Build a lightweight, production-grade HTTP server that receives keyboard commands from a mobile app over USB tethering and simulates real keyboard input on the host laptop.

=== ENVIRONMENT ===
- Primary Platform: Windows 10/11
- Secondary Support: Linux, macOS
- Python Version: 3.10+
- Network: Local only (USB tethering)
- Privileges: Standard user (no admin)
- Deployment: Offline-capable

=== TECHNICAL REQUIREMENTS ===

1. HTTP Framework:
   - Use FastAPI (preferred) or Flask
   - Async request handling
   - CORS enabled for local network
   - Auto-reload in dev mode

2. Server Configuration:
   - Host: 0.0.0.0 (bind all interfaces)
   - Port: 5000 (configurable via config.json)
   - Timeout: 30s for idle connections
   - Max payload: 1 KB

3. API Endpoints:

   POST /key
   - Accept JSON payload:
     {
       "key": "a",           // single char or special key name
       "ctrl": false,        // boolean
       "shift": false,       // boolean
       "alt": false,         // boolean
       "repeat": 1           // optional, default 1
     }
   - Response: {"status": "ok", "key": "a"}
   - Error handling: 400 for invalid keys, 500 for injection failures

   GET /health
   - Response: {"status": "running", "version": "1.0.0"}
   - Used for connectivity checks

   GET /info
   - Response: {"os": "Windows", "ip": "192.168.42.10", "port": 5000}
   - Helps with debugging

4. Keyboard Simulation:
   - Library: pynput
   - Support key types:
     * Letters: a-z (case-sensitive via shift)
     * Numbers: 0-9
     * Symbols: all standard keyboard symbols
     * Special keys: enter, backspace, delete, tab, escape, space
     * Arrow keys: up, down, left, right
     * Function keys: f1-f12
     * Modifiers: ctrl, alt, shift (combinable)
   - Timing: 10ms delay between repeated keys
   - Error handling: Log failed injections, don't crash

5. Logging:
   - Console output: timestamp, IP, key, modifiers
   - Format: [2026-02-01 14:30:15] 192.168.42.5 → Key: 'a', Ctrl: False
   - Log level: INFO (configurable to DEBUG)
   - No file logging by default (optional feature)

6. Configuration:
   - File: config.json
   - Structure:
     {
       "port": 5000,
       "host": "0.0.0.0",
       "log_level": "INFO",
       "allowed_ips": []  // empty = allow all local
     }
   - Auto-create if missing with defaults

7. Code Quality:
   - Single file: server.py (< 300 lines)
   - Type hints throughout
   - Docstrings for functions
   - Error handling: try-except on all I/O
   - Clean shutdown on Ctrl+C

8. Security:
   - Validate JSON schema strictly
   - Reject payloads > 1 KB
   - Rate limiting: 100 req/sec per IP (optional v2)
   - Only bind to local network interfaces

=== DELIVERABLES ===

1. server.py (production code, no comments except docstrings)
2. requirements.txt (pinned versions)
3. config.json (default configuration)
4. README.md (installation + usage)

=== INSTALLATION INSTRUCTIONS FORMAT ===

# Installation
pip install -r requirements.txt

# Run Server
python server.py

# Get Laptop IP
ipconfig         # Windows
ifconfig         # Linux/Mac

# Expected Output
Server running on http://0.0.0.0:5000
Laptop IP: 192.168.42.10
Waiting for connections...

=== OUTPUT REQUIREMENTS ===
- Only clean production code
- No explanatory text outside code
- No placeholder comments like "# TODO"
- Follow PEP 8 strictly
- Use f-strings for formatting
- Async where beneficial

=== TESTING CHECKLIST ===
After generation, verify:
1. Server starts without errors
2. /health returns 200
3. POST /key with {"key": "a"} types 'a'
4. Ctrl+C shuts down gracefully
5. Invalid JSON returns 400
```

---

### 2️⃣ Flutter App — Android

```
You are a senior Flutter developer specializing in mobile applications with clean architecture and high-performance networking.

=== GOAL ===
Create a production-grade Android application that acts as a remote keyboard, sending key commands to a laptop server over USB tethering network with minimal latency.

=== PLATFORM ===
- Target: Android only
- Min SDK: 26 (Android 8.0)
- Target SDK: 34 (Android 14)
- Flutter Version: 3.16+
- Dart Version: 3.2+

=== ARCHITECTURE ===

Clean MVVM Pattern:
- Models: Data classes (Key, ServerConfig)
- ViewModels: Business logic with ChangeNotifier
- Views: Stateless UI components
- Services: HTTP client, SharedPreferences

No unnecessary packages. Keep it lean.

=== FEATURES ===

1. Settings Screen (/settings)
   - Input field: Laptop IP address (192.168.x.x)
   - Validation: Regex for valid IPv4
   - Test connection button → ping /health
   - Save to local storage (shared_preferences)
   - Default port: 5000 (editable)
   - Theme toggle: Dark/Light

2. Main Keyboard Screen (/)
   Components:
   - Connection status indicator (green/red)
   - Text input field (multi-line, auto-focus)
   - Real-time send: Each keystroke → HTTP POST
   - Virtual keys:
     * Arrow keys (←↑↓→) in cross layout
     * Modifier toggles: Ctrl, Alt, Shift (sticky state)
     * Action keys: Enter, Backspace, Delete, Tab, Esc
     * Shortcut buttons: Ctrl+C, Ctrl+V, Ctrl+Z
   - Long press: Repeat key (send every 100ms)
   - Haptic feedback on key press (optional)

3. Networking Layer
   - Package: http (official Dart package)
   - Service: KeyboardService
   - Method: sendKey(String key, {bool ctrl, shift, alt})
   - Endpoint: POST http://{ip}:5000/key
   - Headers: Content-Type: application/json
   - Timeout: 2 seconds
   - Async: Fire-and-forget (don't await for UI speed)
   - Error handling: Catch exceptions, update connection state
   - Debouncing: Optional 50ms for rapid typing

4. State Management
   - Provider package
   - ViewModels:
     * SettingsViewModel (IP, port, connection state)
     * KeyboardViewModel (modifier states, sending logic)
   - Reactive UI updates on state changes

5. UI/UX Requirements
   - Material 3 design
   - Dark mode + Light mode (system default)
   - Large tap targets: 56dp minimum
   - Smooth animations: 200ms transitions
   - Visual feedback: Button press states
   - Error snackbars: "Connection failed"
   - Success indicator: Subtle flash on successful send
   - Accessibility: Semantic labels, screen reader support

6. Performance Optimization
   - Lazy loading: Don't rebuild whole screen on each key
   - Widget keys: Prevent unnecessary rebuilds
   - Const constructors where possible
   - Async isolates: Not needed (HTTP is async)
   - Memory: < 50 MB usage

7. Error Handling
   - Network errors: Show offline banner
   - Invalid IP: Inline validation error
   - Timeout: Retry logic (3 attempts)
   - Server unreachable: Clear error message
   - Graceful degradation: UI stays responsive

=== FOLDER STRUCTURE ===

lib/
├── main.dart                    # App entry, routes
├── models/
│   ├── key_command.dart        # Key data model
│   └── server_config.dart      # Config model
├── services/
│   ├── keyboard_service.dart   # HTTP client for keys
│   └── storage_service.dart    # SharedPreferences wrapper
├── viewmodels/
│   ├── settings_viewmodel.dart
│   └── keyboard_viewmodel.dart
├── views/
│   ├── keyboard_screen.dart
│   ├── settings_screen.dart
│   └── widgets/
│       ├── key_button.dart
│       ├── modifier_toggle.dart
│       └── connection_indicator.dart
└── utils/
    ├── constants.dart          # API endpoints, colors
    └── validators.dart         # IP validation

=== DEPENDENCIES (pubspec.yaml) ===

dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.1            # State management
  http: ^1.1.0                # HTTP client
  shared_preferences: ^2.2.2  # Local storage

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1

=== DELIVERABLES ===

1. Full Flutter project structure
2. All source files with complete implementation
3. pubspec.yaml with dependencies
4. README.md (setup + usage)
5. android/app/src/main/AndroidManifest.xml (with internet permission)

=== CODE QUALITY STANDARDS ===

- Null safety: Strict mode
- Linting: Follow flutter_lints
- Documentation: Dartdoc for public APIs
- Error handling: Try-catch on all async calls
- Testing: Unit tests for services (optional in v1)
- Comments: Only for complex business logic

=== ANDROID PERMISSIONS ===

<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>

=== PERFORMANCE TARGETS ===

- Cold start: < 2 seconds
- Key send latency: < 50ms (local network)
- Memory usage: < 50 MB
- APK size: < 15 MB

=== OUTPUT REQUIREMENTS ===

- Production-ready code only
- No explanatory comments
- No TODO placeholders
- Follow Dart style guide
- Use modern Flutter patterns (3.x)

=== TESTING CHECKLIST ===

After generation:
1. flutter pub get
2. flutter run
3. Enter laptop IP in settings
4. Test connection → should show green
5. Type text → should appear on laptop
6. Test arrow keys
7. Test Ctrl+C shortcut
8. Test dark/light theme switch
```

---

## 🚀 Setup & Usage

### Quick Start (5 Minutes)

#### Step 1: Laptop Server Setup

```powershell
# Navigate to laptop-server folder
cd W:\workplace-1\keyote\laptop-server

# Install dependencies
pip install -r requirements.txt

# Run server
python server.py

# Note the IP address shown in console
# Example: Server running on http://192.168.42.10:5000
```

#### Step 2: Phone App Setup

```bash
# Open keyote-apk in IDE (VS Code / Android Studio)
cd keyote-apk

# Get dependencies
flutter pub get

# Connect phone via USB
# Enable Developer Options → USB Debugging

# Run app
flutter run
```

#### Step 3: Connect & Use

1. **Phone**: Connect USB cable to laptop
2. **Phone**: Settings → Network → USB Tethering → Enable
3. **App**: Open Keyote app
4. **App**: Go to Settings → Enter laptop IP (from Step 1)
5. **App**: Tap "Test Connection" (should show green)
6. **App**: Return to keyboard screen
7. **Type**: Everything you type now controls laptop

**Fertig.** (Finished.)

---

## 📡 API Specification

### Endpoint: POST `/key`

**Request:**
```json
{
  "key": "a",
  "ctrl": false,
  "shift": false,
  "alt": false,
  "repeat": 1
}
```

**Response (200 OK):**
```json
{
  "status": "ok",
  "key": "a"
}
```

**Error (400 Bad Request):**
```json
{
  "status": "error",
  "message": "Invalid key format"
}
```

### Endpoint: GET `/health`

**Response (200 OK):**
```json
{
  "status": "running",
  "version": "1.0.0"
}
```

### Endpoint: GET `/info`

**Response (200 OK):**
```json
{
  "os": "Windows",
  "ip": "192.168.42.10",
  "port": 5000
}
```

---

## 🗺️ Future Roadmap

### Version 1.0 — MVP (Current Focus)
- ✅ USB tethering connection
- ✅ Basic keyboard input
- ✅ Settings screen
- ✅ Windows support

### Version 1.5 — Enhanced Input
- ⬜ Mouse trackpad support (swipe gestures)
- ⬜ Clipboard sync (copy on phone → paste on laptop)
- ⬜ Macro support (save key sequences)
- ⬜ Custom key bindings

### Version 2.0 — Performance & Discovery
- ⬜ WebSocket protocol (lower latency than HTTP)
- ⬜ Auto-discovery (no IP typing via mDNS/Bonjour)
- ⬜ Multiple device support (switch between laptops)
- ⬜ Connection history

### Version 2.5 — Cross-Platform
- ⬜ iOS app (Flutter for iPhone)
- ⬜ Linux full testing & optimization
- ⬜ macOS full testing & optimization

### Version 3.0 — Professional Features
- ⬜ Server as standalone .exe (PyInstaller)
- ⬜ System tray icon (minimize to tray)
- ⬜ Encrypted connection (TLS for public networks)
- ⬜ Multi-user support (multiple phones → one laptop)
- ⬜ Touch gestures (pinch, swipe for shortcuts)

---

## 💡 Professional Recommendations

### Development Speed Optimizers

1. **Use AI Code Generators Smartly**
   - Feed the agent prompts above verbatim
   - Generate both components in parallel (laptop + phone)
   - Review generated code for security (input validation)
   - Test immediately after generation

2. **Rapid Iteration Loop**
   ```
   Generate → Test → Fix → Repeat
   (Each cycle: < 10 minutes)
   ```

3. **Hot Reload for Flutter**
   - Use `flutter run` with hot reload (r key)
   - Changes reflect in < 2 seconds
   - No rebuild needed for UI tweaks

4. **Docker for Server (Optional)**
   ```dockerfile
   FROM python:3.10-slim
   COPY server.py requirements.txt ./
   RUN pip install -r requirements.txt
   CMD ["python", "server.py"]
   ```
   - Consistent environment across machines
   - Easy deployment to friends

### Scalability Considerations

1. **Modular Architecture**
   - Server: Separate `KeyInjector` class
   - App: Service layer abstraction
   - Easy to swap HTTP → WebSocket later

2. **Configuration Files**
   - Don't hardcode IPs/ports
   - Use `config.json` for server
   - Use `shared_preferences` for app

3. **Protocol Versioning**
   - Add `"version": "1.0"` to JSON payloads
   - Server can handle multiple versions
   - Backward compatibility for updates

### Smart Engineering Decisions

1. **Start Simple, Iterate Fast**
   - HTTP before WebSocket
   - Text input before mouse
   - Windows before cross-platform
   
2. **Fail Fast & Visible**
   - Show errors immediately in app UI
   - Don't silently fail network requests
   - Log everything on server

3. **Measure What Matters**
   - Latency (target: < 50ms)
   - Battery usage (keep < 5% per hour)
   - Memory footprint (server < 50 MB)

4. **Boring Tech Wins**
   - HTTP is boring → it's reliable
   - JSON is boring → it's debuggable
   - Flask/FastAPI → battle-tested
   - Flutter → one codebase, multiple platforms

### Testing Strategy

```
Unit Tests     → 20% (critical functions)
Integration    → 30% (HTTP client ↔ server)
Manual Testing → 50% (real devices, real usage)
```

### Security Hardening (Future)

- Rate limiting (prevent spam)
- IP whitelist (only known devices)
- TLS encryption (if used over WiFi)
- Authentication tokens (multi-user scenario)

### Distribution Strategy

1. **Server**: Package as `.exe` with PyInstaller
   ```bash
   pyinstaller --onefile --windowed server.py
   ```
   
2. **App**: Release APK via GitHub Releases
   ```bash
   flutter build apk --release
   ```

3. **Installer**: Create setup wizard (NSIS/Inno Setup)

---

## 🔧 Troubleshooting

### Common Issues

| Problem | Solution |
|---------|----------|
| **App can't connect** | Check USB tethering is ON, verify IP with `ipconfig` |
| **Keys not typing** | Ensure server is running, check firewall isn't blocking port 5000 |
| **Laggy response** | Close background apps, check network congestion |
| **Server won't start** | Check port 5000 not in use: `netstat -ano \| findstr 5000` |
| **App crashes on send** | Check server is reachable, verify JSON format |

### Debug Commands

```powershell
# Check laptop IP
ipconfig

# Test server endpoint
curl http://localhost:5000/health

# Kill process on port 5000 (if stuck)
netstat -ano | findstr :5000
taskkill /PID <PID> /F

# View server logs in real-time
python server.py  # logs to console
```

---

## 📊 Performance Benchmarks (Target)

| Metric | Target | Acceptable | Poor |
|--------|--------|------------|------|
| Key send latency | < 30ms | < 100ms | > 200ms |
| Server memory | < 30 MB | < 50 MB | > 100 MB |
| App memory | < 40 MB | < 60 MB | > 100 MB |
| Cold start (app) | < 1.5s | < 3s | > 5s |
| Battery drain | < 3%/hr | < 7%/hr | > 10%/hr |

---

## 🤝 Contributing

This is a personal project, but suggestions welcome:

1. Open issue with detailed description
2. Propose enhancement with use case
3. Fork, implement, test, PR

Keep it simple. Boring tech only.

---

## 📄 License

MIT License — Use freely, modify freely, ship freely.

---

## 🙏 Acknowledgments

- **pynput**: Cross-platform keyboard control
- **FastAPI/Flask**: Reliable HTTP servers
- **Flutter**: Beautiful native apps from one codebase
- **USB Tethering**: The boring tech that just works

---

## 📞 Support

Questions? Ideas? Found a bug?

Open an issue with:
- OS version
- Python/Flutter version
- Error logs
- Steps to reproduce

Response time: Within 24 hours.

---

**Built with boring, reliable technology.**  
**Deterministisch. Predictable. Powerful.**

---

*Last Updated: February 1, 2026*  
*Version: 1.0.0-alpha*  
*Status: In Development*
