"""
Keyote Laptop Server - HTTP Keyboard Input Receiver
Receives keyboard commands from mobile app via USB tethering and simulates keyboard input.
"""

import json
import socket
import sys
from pathlib import Path
from typing import Dict, Any, Optional
from datetime import datetime
from contextlib import asynccontextmanager

from fastapi import FastAPI, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field, field_validator
from pynput.keyboard import Controller, Key
import uvicorn


VERSION = "1.0.0"
CONFIG_FILE = Path("config.json")
keyboard = Controller()


class KeyCommand(BaseModel):
    key: str = Field(..., min_length=1, max_length=20)
    ctrl: bool = False
    shift: bool = False
    alt: bool = False
    repeat: int = Field(default=1, ge=1, le=100)

    @field_validator('key')
    @classmethod
    def validate_key(cls, v: str) -> str:
        if len(v) > 20:
            raise ValueError("Key name too long")
        return v


class Config:
    def __init__(self):
        self.port: int = 5000
        self.host: str = "0.0.0.0"
        self.log_level: str = "INFO"
        self.allowed_ips: list = []
        self.load()

    def load(self):
        if CONFIG_FILE.exists():
            try:
                with open(CONFIG_FILE, 'r') as f:
                    data = json.load(f)
                self.port = data.get('port', 5000)
                self.host = data.get('host', '0.0.0.0')
                self.log_level = data.get('log_level', 'INFO')
                self.allowed_ips = data.get('allowed_ips', [])
            except Exception as e:
                print(f"Error loading config: {e}, using defaults")
        else:
            self.save()

    def save(self):
        try:
            with open(CONFIG_FILE, 'w') as f:
                json.dump({
                    'port': self.port,
                    'host': self.host,
                    'log_level': self.log_level,
                    'allowed_ips': self.allowed_ips
                }, f, indent=2)
        except Exception as e:
            print(f"Error saving config: {e}")


config = Config()


SPECIAL_KEYS = {
    'enter': Key.enter,
    'backspace': Key.backspace,
    'delete': Key.delete,
    'tab': Key.tab,
    'escape': Key.esc,
    'esc': Key.esc,
    'space': Key.space,
    'up': Key.up,
    'down': Key.down,
    'left': Key.left,
    'right': Key.right,
    'home': Key.home,
    'end': Key.end,
    'pageup': Key.page_up,
    'pagedown': Key.page_down,
    'capslock': Key.caps_lock,
    'caps': Key.caps_lock,
    'win': Key.cmd,
    'cmd': Key.cmd,
    'printscreen': Key.print_screen,
    'prtsc': Key.print_screen,
    'f1': Key.f1, 'f2': Key.f2, 'f3': Key.f3, 'f4': Key.f4,
    'f5': Key.f5, 'f6': Key.f6, 'f7': Key.f7, 'f8': Key.f8,
    'f9': Key.f9, 'f10': Key.f10, 'f11': Key.f11, 'f12': Key.f12,
}


@asynccontextmanager
async def lifespan(app: FastAPI):
    print(f"Server starting on http://{config.host}:{config.port}")
    print(f"Laptop IP: {get_local_ip()}")
    print("Waiting for connections...")
    yield
    print("\nServer shutting down...")


app = FastAPI(title="Keyote Server", version=VERSION, lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.middleware("http")
async def payload_size_limit(request: Request, call_next):
    content_length = request.headers.get('content-length')
    if content_length and int(content_length) > 1024:
        return JSONResponse(
            status_code=413,
            content={"error": "Payload too large"}
        )
    return await call_next(request)


def get_local_ip() -> str:
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        ip = s.getsockname()[0]
        s.close()
        return ip
    except Exception:
        return "127.0.0.1"


def get_os_name() -> str:
    if sys.platform == "win32":
        return "Windows"
    elif sys.platform == "darwin":
        return "macOS"
    elif sys.platform.startswith("linux"):
        return "Linux"
    return sys.platform


def log_request(client_ip: str, key: str, ctrl: bool, shift: bool, alt: bool):
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    modifiers = f"Ctrl: {ctrl}, Shift: {shift}, Alt: {alt}"
    print(f"[{timestamp}] {client_ip} → Key: '{key}', {modifiers}")


def press_key(key_name: str, ctrl: bool = False, shift: bool = False, alt: bool = False) -> bool:
    try:
        modifiers = []
        if ctrl:
            modifiers.append(Key.ctrl)
        if shift:
            modifiers.append(Key.shift)
        if alt:
            modifiers.append(Key.alt)

        for mod in modifiers:
            keyboard.press(mod)

        if key_name.lower() in SPECIAL_KEYS:
            key_obj = SPECIAL_KEYS[key_name.lower()]
            keyboard.press(key_obj)
            keyboard.release(key_obj)
        else:
            keyboard.press(key_name)
            keyboard.release(key_name)

        for mod in reversed(modifiers):
            keyboard.release(mod)

        return True
    except Exception as e:
        print(f"Error pressing key '{key_name}': {e}")
        return False


@app.get("/health")
async def health_check() -> Dict[str, str]:
    return {"status": "running", "version": VERSION}


@app.get("/info")
async def server_info() -> Dict[str, Any]:
    return {
        "os": get_os_name(),
        "ip": get_local_ip(),
        "port": config.port,
        "version": VERSION
    }


@app.post("/key")
async def handle_key(command: KeyCommand, request: Request) -> Dict[str, str]:
    client_ip = request.client.host if request.client else "unknown"
    
    log_request(client_ip, command.key, command.ctrl, command.shift, command.alt)

    for i in range(command.repeat):
        success = press_key(command.key, command.ctrl, command.shift, command.alt)
        if not success:
            raise HTTPException(
                status_code=500,
                detail=f"Failed to simulate key: {command.key}"
            )
        if command.repeat > 1 and i < command.repeat - 1:
            import time
            time.sleep(0.01)

    return {"status": "ok", "key": command.key}


@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    return JSONResponse(
        status_code=500,
        content={"error": str(exc)}
    )


def main():
    try:
        uvicorn.run(
            app,
            host=config.host,
            port=config.port,
            log_level=config.log_level.lower(),
            access_log=False,
            timeout_keep_alive=30
        )
    except KeyboardInterrupt:
        print("\nShutting down gracefully...")
    except Exception as e:
        print(f"Server error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
