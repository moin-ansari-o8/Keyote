# Keyote

Turn your Android phone into a remote keyboard for your laptop using USB tethering. No internet required, no complex setup.

## What It Does

Keyote lets you control your laptop's keyboard from your phone over a USB connection. The phone runs a Flutter app with a virtual keyboard, and the laptop runs a Python server that simulates keystrokes.

```
Phone (Flutter App)  --(USB Tethering)-->  Laptop (Python Server)
      Keyboard UI                          Keyboard Simulation
```

## How It Works

1. Connect phone to laptop via USB cable
2. Enable USB tethering on phone
3. Start Python server on laptop
4. Connect from phone app using laptop's IP
5. Type on phone, characters appear on laptop

## System Requirements

**Laptop:**
- Windows 10/11, Linux, or macOS
- Python 3.10+
- USB port

**Phone:**
- Android 8.0+
- USB tethering support

## Setup

**Laptop Server:**

```bash
cd laptop-server
pip install -r requirements.txt
python server.py
```

The server will display your laptop's IP address (e.g., 192.168.42.10).

**Phone App:**

1. Install APK from releases or build from source
2. Connect phone to laptop via USB
3. Enable USB tethering in phone settings
4. Open Keyote app
5. Enter laptop IP and port (default 5000)
6. Tap Connect

## Project Structure

```
keyote/
├── laptop-server/     # Python HTTP server
│   ├── server.py      # Main server
│   └── dashboard.py   # GUI dashboard
└── keyote_apk/        # Flutter Android app
    └── lib/           # App source code
```

## Features

- Virtual keyboard with sound effects
- Special keys: Enter, Backspace, Delete, Tab, Escape, Space
- Arrow keys: Up, Down, Left, Right
- Function keys: F1-F12
- Modifier keys: Ctrl, Alt, Shift
- Multiple keyboard layouts
- Settings screen for server configuration

## License

MIT License
