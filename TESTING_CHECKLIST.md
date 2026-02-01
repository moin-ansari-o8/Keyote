# Testing Checklist - Keyote Remote

## Prerequisites
- [ ] Laptop server running (see README for Python example)
- [ ] Android device with USB debugging enabled
- [ ] USB cable connected
- [ ] USB tethering enabled on Android

## Testing Steps

### 1. Initial Setup
```bash
cd W:\workplace-1\keyote\keyote_apk
flutter run
```

### 2. Settings Configuration
- [ ] App launches successfully
- [ ] Tap Settings icon (⚙️)
- [ ] Enter laptop IP (e.g., 192.168.42.129)
- [ ] Port shows 5000
- [ ] Tap "Test Connection"
- [ ] Should show green "Connection successful!" snackbar
- [ ] Tap "Save"
- [ ] Navigate back to main screen

### 3. Connection Indicator
- [ ] Green indicator shows "Connected"
- [ ] If server stops, indicator turns red

### 4. Text Input
- [ ] Type "hello" in text field
- [ ] Each character appears on laptop as typed
- [ ] Multi-line text works

### 5. Modifier Keys
- [ ] Tap Ctrl - button highlights
- [ ] Type 'c' - sends Ctrl+C to laptop
- [ ] Ctrl button auto-releases
- [ ] Same for Alt and Shift

### 6. Arrow Keys
- [ ] Tap Up arrow - cursor moves up on laptop
- [ ] Tap Down arrow - cursor moves down
- [ ] Tap Left arrow - cursor moves left
- [ ] Tap Right arrow - cursor moves right
- [ ] Long-press Up - continuous movement
- [ ] Release - movement stops

### 7. Action Keys
- [ ] Tap Enter - new line on laptop
- [ ] Tap Backspace - deletes character
- [ ] Long-press Backspace - continuous delete
- [ ] Tap Delete - forward delete
- [ ] Tap Tab - inserts tab
- [ ] Tap Esc - sends escape

### 8. Shortcut Buttons
- [ ] Tap "Copy" - sends Ctrl+C
- [ ] Tap "Paste" - sends Ctrl+V
- [ ] Tap "Undo" - sends Ctrl+Z
- [ ] Tap "Save" - sends Ctrl+S

### 9. Theme Toggle
- [ ] Go to Settings
- [ ] Toggle Dark Mode switch
- [ ] UI switches to dark theme immediately
- [ ] Toggle back - switches to light theme
- [ ] Close and reopen app - theme persists

### 10. Performance
- [ ] App starts in <2 seconds
- [ ] Key presses feel instant (<50ms)
- [ ] No lag or stuttering
- [ ] Memory usage reasonable (check in Android settings)

### 11. Error Handling
- [ ] Stop laptop server
- [ ] Try typing - app doesn't crash
- [ ] Connection indicator shows red
- [ ] Enter invalid IP (999.999.999.999) - shows error
- [ ] Enter invalid port (99999) - shows error

### 12. Edge Cases
- [ ] Rapid typing - all keys register
- [ ] Long-press multiple arrow keys - works correctly
- [ ] Rotate device - app maintains state
- [ ] Put app in background - still works when returned

## Expected Results

✅ All tests should pass
✅ No crashes or freezes
✅ Smooth, responsive UI
✅ Keys register correctly on laptop
✅ Low latency feel

## Common Issues

### Connection Failed
- Check laptop server is running: `python server.py`
- Verify IP address: `ipconfig` (Windows) or `ifconfig` (Linux)
- Check firewall isn't blocking port 5000

### Keys Not Appearing
- Check server logs for incoming requests
- Verify JSON payload format
- Test with curl: `curl -X POST http://192.168.x.x:5000/key -H "Content-Type: application/json" -d '{"key":"a","ctrl":false,"shift":false,"alt":false}'`

### High Latency
- Ensure USB tethering (not WiFi)
- Check server response time
- Close background apps on Android

## Build Release APK

After all tests pass:

```bash
flutter build apk --release
```

APK location: `build/app/outputs/flutter-apk/app-release.apk`

Install on device:
```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

## Next Steps

1. ✅ Run all tests above
2. ✅ Fix any issues found
3. ✅ Build release APK
4. ✅ Test release build
5. ✅ Archive temp-todo file
6. ✅ Project complete!
