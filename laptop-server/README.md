# Keyote Laptop Server

Lightweight HTTP server that receives keyboard commands from mobile app via USB tethering and simulates keyboard input on the host laptop.

## Requirements

- Python 3.10+
- Windows 10/11 (primary), Linux/macOS (supported)
- Standard user privileges (no admin required)

## Installation

```bash
pip install -r requirements.txt
```

## Run Server

```bash
python server.py
```

## Get Laptop IP

**Windows:**
```bash
ipconfig
```

**Linux/macOS:**
```bash
ifconfig
```

## Expected Output

```
Server starting on http://0.0.0.0:5000
Laptop IP: 192.168.42.10
Waiting for connections...
```

## API Endpoints

### POST /key

Send keyboard command:

```json
{
  "key": "a",
  "ctrl": false,
  "shift": false,
  "alt": false,
  "repeat": 1
}
```

**Response:**
```json
{
  "status": "ok",
  "key": "a"
}
```

**Supported Keys:**
- Letters: a-z (case via shift)
- Numbers: 0-9
- Symbols: all standard keyboard symbols
- Special: enter, backspace, delete, tab, escape, space
- Arrows: up, down, left, right
- Function: f1-f12
- Modifiers: ctrl, alt, shift (combinable)

### GET /health

Check server status:

```json
{
  "status": "running",
  "version": "1.0.0"
}
```

### GET /info

Get server information:

```json
{
  "os": "Windows",
  "ip": "192.168.42.10",
  "port": 5000
}
```

## Configuration

Edit `config.json`:

```json
{
  "port": 5000,
  "host": "0.0.0.0",
  "log_level": "INFO",
  "allowed_ips": []
}
```

## Testing

1. **Start server:**
   ```bash
   python server.py
   ```

2. **Test health endpoint:**
   ```bash
   curl http://localhost:5000/health
   ```

3. **Test key press:**
   ```bash
   curl -X POST http://localhost:5000/key \
     -H "Content-Type: application/json" \
     -d '{"key": "a"}'
   ```

4. **Test with modifiers:**
   ```bash
   curl -X POST http://localhost:5000/key \
     -H "Content-Type: application/json" \
     -d '{"key": "c", "ctrl": true}'
   ```

## Troubleshooting

**Server won't start:**
- Check if port 5000 is already in use
- Change port in config.json

**Keys not working:**
- Ensure app has focus on the target application
- Check server logs for errors

**Can't connect from mobile:**
- Verify USB tethering is enabled
- Check laptop IP matches mobile network
- Test with /health endpoint first

## Security Notes

- Server only binds to local network interfaces
- Rejects payloads > 1 KB
- Validates all JSON input strictly
- No authentication (local network only)

## Shutdown

Press `Ctrl+C` to stop the server gracefully.

## License

See project root LICENSE file.
