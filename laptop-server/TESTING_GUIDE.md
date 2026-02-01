# Testing Guide - Keyote Server

## ✅ Server Status: RUNNING
Your server is live at: `http://0.0.0.0:5000`  
Laptop IP: `172.16.21.4`

---

## 🧪 Step 1: Test Server Locally

### Test 1: Health Check
Open new PowerShell terminal:
```powershell
curl http://localhost:5000/health
```
**Expected Output:**
```json
{"status":"running","version":"1.0.0"}
```

### Test 2: Server Info
```powershell
curl http://localhost:5000/info
```
**Expected Output:**
```json
{"os":"Windows","ip":"172.16.21.4","port":5000,"version":"1.0.0"}
```

### Test 3: Type Single Key
```powershell
curl -X POST http://localhost:5000/key -H "Content-Type: application/json" -d "{\"key\":\"a\"}"
```
**Expected:** Letter 'a' appears in focused text editor

### Test 4: Type with Ctrl (Copy)
1. Open Notepad, type "Hello"
2. Select the text
3. Run:
```powershell
curl -X POST http://localhost:5000/key -H "Content-Type: application/json" -d "{\"key\":\"c\",\"ctrl\":true}"
```
**Expected:** Text copied to clipboard

### Test 5: Special Keys
```powershell
# Press Enter
curl -X POST http://localhost:5000/key -H "Content-Type: application/json" -d "{\"key\":\"enter\"}"

# Press Backspace
curl -X POST http://localhost:5000/key -H "Content-Type: application/json" -d "{\"key\":\"backspace\"}"

# Press Arrow Down
curl -X POST http://localhost:5000/key -H "Content-Type: application/json" -d "{\"key\":\"down\"}"
```

### Test 6: Repeated Keys
```powershell
curl -X POST http://localhost:5000/key -H "Content-Type: application/json" -d "{\"key\":\"x\",\"repeat\":5}"
```
**Expected:** "xxxxx" appears

---

## 📱 Step 2: Test from Mobile (USB Tethering)

### Setup USB Tethering:

**Android:**
1. Connect phone to laptop via USB
2. Settings → Network & Internet → Hotspot & Tethering
3. Enable "USB tethering"
4. Phone should assign IP to laptop (already shows as 172.16.21.4)

**iOS:**
1. Connect iPhone to laptop via USB
2. Settings → Personal Hotspot
3. Enable "Allow Others to Join"
4. Enable "Share via USB"

### Find Mobile's IP:
On your phone, check network settings to find your mobile's IP (usually 172.16.21.x or 192.168.42.x)

### Test from Mobile Browser:
1. Open Chrome/Safari on phone
2. Navigate to: `http://172.16.21.4:5000/health`
3. Should see: `{"status":"running","version":"1.0.0"}`

### Test Key Press from Mobile:
Use a REST client app like **Postman** or **HTTP Shortcuts** (Android):
```
POST http://172.16.21.4:5000/key
Content-Type: application/json

{"key":"hello"}
```

---

## 🚀 Step 3: Build Flutter Mobile App

### Option A: Quick Test with HTTP Tool
Before building the full app, test with existing HTTP client apps:

**Android Apps:**
- HTTP Shortcuts (free, Google Play)
- Postman Mobile
- REST API Client

**Create shortcuts for:**
- Arrow keys (up/down/left/right)
- Enter key
- Backspace
- Common text snippets

### Option B: Build Flutter App

Your Flutter app structure is ready at: `W:\workplace-1\keyote\keyote_apk`

#### Recommended UI Features:

1. **Connection Screen:**
   - IP input field (default: 172.16.21.4)
   - Port input (default: 5000)
   - "Connect" button (test /health endpoint)
   - Connection status indicator

2. **Keyboard Screen:**
   - Virtual keyboard layout
   - Arrow keys cluster
   - Special keys (Enter, Backspace, Delete, Tab, Esc)
   - Modifier toggles (Ctrl, Shift, Alt)
   - Function keys (F1-F12)

3. **Text Input:**
   - Text field for typing longer strings
   - Send button
   - Quick phrases/macros

4. **Settings:**
   - Save/load server IP
   - Keyboard layout customization
   - Vibration feedback toggle

#### Flutter Implementation Steps:

```bash
cd W:\workplace-1\keyote\keyote_apk
```

1. **Add HTTP dependency** to `pubspec.yaml`:
```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.2.0
  shared_preferences: ^2.2.0
```

2. **Create service** in `lib/services/keyboard_service.dart`:
```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class KeyboardService {
  String baseUrl = 'http://172.16.21.4:5000';
  
  Future<bool> testConnection() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/health'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  Future<bool> sendKey(String key, {bool ctrl = false, bool shift = false, bool alt = false, int repeat = 1}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/key'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'key': key,
          'ctrl': ctrl,
          'shift': shift,
          'alt': alt,
          'repeat': repeat,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
```

3. **Run Flutter app:**
```bash
flutter pub get
flutter run
```

---

## 🎯 Next Development Steps

### Priority 1: Basic Functionality
- [x] Server running ✓
- [ ] Test from mobile browser
- [ ] Create Flutter UI with connection screen
- [ ] Implement basic keyboard (letters, numbers)

### Priority 2: Enhanced Features
- [ ] Add special keys (arrows, enter, etc.)
- [ ] Add modifier keys (ctrl, shift, alt)
- [ ] Add vibration feedback
- [ ] Save server IP in preferences

### Priority 3: Advanced Features
- [ ] Custom keyboard layouts
- [ ] Macro/shortcut buttons
- [ ] Gesture controls (swipe for arrows)
- [ ] Dark mode theme
- [ ] Multi-device support

---

## 🔧 Troubleshooting

**Server not accessible from mobile:**
- Verify USB tethering is active
- Check firewall isn't blocking port 5000
- Try: `netsh advfirewall firewall add rule name="Keyote" dir=in action=allow protocol=TCP localport=5000`

**Keys not working:**
- Ensure target app has focus (click on Notepad/editor first)
- Check server console for error logs
- Test with simple keys like 'a' before special keys

**Connection refused:**
- Restart server
- Verify IP hasn't changed: `ipconfig`
- Test localhost first: `curl http://localhost:5000/health`

---

## 📝 Quick Reference

**Server Commands:**
```powershell
# Start server
cd W:\workplace-1\keyote\laptop-server
python server.py

# Check IP
ipconfig

# Stop server
Ctrl+C
```

**Test Commands:**
```powershell
# Health check
curl http://localhost:5000/health

# Type 'hello'
curl -X POST http://localhost:5000/key -H "Content-Type: application/json" -d "{\"key\":\"hello\"}"

# Ctrl+S (save)
curl -X POST http://localhost:5000/key -H "Content-Type: application/json" -d "{\"key\":\"s\",\"ctrl\":true}"
```

**From Mobile:**
Replace `localhost` with your laptop IP: `172.16.21.4`

---

**Server is ready! Start testing with curl commands, then build your Flutter app.**
