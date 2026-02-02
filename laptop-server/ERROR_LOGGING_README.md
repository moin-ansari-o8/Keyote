# Error Logging Documentation

## Overview
The Keyote Server Dashboard now includes comprehensive error logging to help diagnose runtime issues.

## Log File Location
**Log file:** `keyote_server_errors.log` (created in the same directory as the executable)

This file captures:
- Application startup and initialization
- Server start/stop operations
- All errors and exceptions with full stack traces
- Server manager operations
- Network configuration changes
- Connection status updates

## How to Use

### 1. Run the Application
- Double-click `KeyoteServer.exe` in the `dist` folder
- The application will create `keyote_server_errors.log` automatically

### 2. When an Error Occurs
- The app will show an error dialog with basic information
- **CRITICAL:** Check `keyote_server_errors.log` for detailed error information
- The log file contains timestamps, error types, and full stack traces

### 3. Reading the Log File
Open `keyote_server_errors.log` with any text editor. Look for lines containing:
- **INFO:** Normal operations (startup, shutdown, etc.)
- **WARNING:** Non-critical issues
- **ERROR:** Errors that were caught and handled
- **CRITICAL:** Fatal errors that caused the app to crash

### Example Log Entries

**Normal Startup:**
```
2026-02-02 15:30:45 - INFO - ============================================================
2026-02-02 15:30:45 - INFO - Keyote Server Dashboard Starting
2026-02-02 15:30:45 - INFO - Version: 1.0.0
2026-02-02 15:30:45 - INFO - Creating QApplication
2026-02-02 15:30:45 - INFO - Dashboard initialized successfully
```

**Server Start Error:**
```
2026-02-02 15:31:12 - ERROR - Error in ServerManager.start(): [Errno 10048] error while attempting to bind on address ('0.0.0.0', 5001): only one usage of each socket address (protocol/network address/port) is normally permitted
2026-02-02 15:31:12 - ERROR - Traceback (most recent call last):
  File "server_manager.py", line 45, in start
    self.server.run()
  ...
```

## Common Issues

### Issue: App closes when clicking "Start Server"
**Solution:** Check the log file for:
- Port already in use errors (Error 10048)
- Missing dependencies
- Import errors
- Permission issues

### Issue: Tray icon not visible
**Solution:** Check the log file for:
- Initialization errors in `setup_tray()`
- QSystemTrayIcon creation failures

### Issue: Server won't start
**Solution:** Check the log file for:
- Port binding errors
- uvicorn configuration issues
- FastAPI import errors

## Troubleshooting Steps

1. **Delete old log file** before running to get fresh logs
2. **Run the application**
3. **Reproduce the issue**
4. **Close the application** (or wait for crash)
5. **Open `keyote_server_errors.log`**
6. **Find the error** (search for "ERROR" or "CRITICAL")
7. **Read the stack trace** for details

## Log File Locations

### When running directly from Python:
`W:\workplace-1\keyote\laptop-server\keyote_server_errors.log`

### When running the .exe:
`keyote_server_errors.log` (same folder as KeyoteServer.exe)

## Additional Info

- Logs are appended (not overwritten) each run
- Log file includes both console output and file output
- Maximum detail is logged (DEBUG level)
- Timestamps use 24-hour format: `YYYY-MM-DD HH:MM:SS`

## Error Message Details

All error dialogs now include:
- Brief error description
- Full exception message
- Reference to log file for details

Example:
```
Failed to start server:
[Errno 10048] Address already in use

Check keyote_server_errors.log for details.
```

## Performance Note

Error logging has minimal performance impact:
- Only writes to file when events occur
- No continuous polling or monitoring
- Async-safe for server operations
