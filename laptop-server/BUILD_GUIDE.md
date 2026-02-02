# Keyote Server - Build & Deployment Guide

## Development Setup

### Install Dependencies

**Core Server:**
```bash
pip install -r requirements.txt
```

**GUI Dashboard:**
```bash
pip install -r requirements-gui.txt
```

**All Dependencies:**
```bash
pip install -r requirements.txt -r requirements-gui.txt
```

## Running the Application

### CLI Mode (Original)
```bash
python server.py
```

### GUI Dashboard Mode (New)
```bash
python dashboard.py
```

## Building Executable

### Prerequisites
- Python 3.10+ installed
- All dependencies installed
- PyInstaller installed (`pip install pyinstaller`)

### Build Command

**Single-file executable:**
```bash
pyinstaller build.spec
```

**Alternative - Direct build:**
```bash
pyinstaller --onefile --windowed --name KeyoteServer dashboard.py
```

### Build Output
- Executable location: `dist/KeyoteServer.exe`
- Size: ~60-80MB (PyQt6 bundled)
- Standalone: No Python installation required

### Build Options

**Optimize size with UPX:**
```bash
pyinstaller --onefile --windowed --upx-dir=upx build.spec
```

**Debug build (console window):**
```bash
pyinstaller --onefile --console --name KeyoteServer dashboard.py
```

## Distribution

### Single Executable
1. Build: `pyinstaller build.spec`
2. Distribute: Copy `dist/KeyoteServer.exe` to target machine
3. Run: Double-click `KeyoteServer.exe`

### With Configuration
1. Build executable
2. Create distribution folder:
   ```
   KeyoteServer/
   ├── KeyoteServer.exe
   └── config.json (optional - auto-created on first run)
   ```
3. Zip folder for distribution

## Testing

### Test GUI Locally
```bash
python dashboard.py
```

### Test Executable
```bash
dist\KeyoteServer.exe
```

### Verify Features
- ✅ Window opens without errors
- ✅ System tray icon appears
- ✅ Server starts on port 5000
- ✅ IP address displayed correctly
- ✅ Settings dialog opens and saves
- ✅ Minimize to tray works
- ✅ Logs show activity
- ✅ Server stops cleanly

## Troubleshooting

### Build Errors

**Missing modules:**
```bash
pip install --upgrade -r requirements.txt -r requirements-gui.txt
```

**Import errors:**
- Check `hiddenimports` in build.spec
- Add missing modules to spec file

### Runtime Errors

**Server won't start:**
- Check port availability (not in use)
- Check firewall settings
- Verify config.json format

**GUI doesn't appear:**
- Ensure PyQt6 installed correctly
- Check Windows display settings
- Try debug build (console mode)

**Icon missing:**
- Rebuild with icon file: `pyinstaller build.spec`
- Check icon path in spec file

## Development Commands

**Format code:**
```bash
black dashboard.py server.py server_manager.py
```

**Type check:**
```bash
mypy dashboard.py server.py server_manager.py
```

**Run tests:**
```bash
pytest tests/
```

## Configuration

**Default config.json:**
```json
{
  "port": 5000,
  "host": "0.0.0.0",
  "log_level": "INFO",
  "allowed_ips": [],
  "theme": "Dark",
  "auto_start": false,
  "minimize_to_tray": true
}
```

## Notes

- First run creates config.json automatically
- Settings persist across restarts
- Logs are in-memory only (not saved to file)
- Auto-start requires Windows Task Scheduler setup
- Firewall prompt may appear on first run
