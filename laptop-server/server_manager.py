"""
Server Manager - Controls FastAPI server lifecycle in background thread
Provides thread-safe start/stop/status management for GUI integration
"""

import threading
import uvicorn
from typing import Optional, Callable
import signal
import sys
import logging
import traceback

logger = logging.getLogger(__name__)


class ServerManager:
    """Manages FastAPI server lifecycle with thread-safe controls"""
    
    def __init__(self):
        self.server: Optional[uvicorn.Server] = None
        self.thread: Optional[threading.Thread] = None
        self.port: int = 5000
        self.host: str = "0.0.0.0"
        self.is_running: bool = False
        self.status_callback: Optional[Callable] = None
        
    def set_status_callback(self, callback: Callable):
        """Set callback for status updates"""
        self.status_callback = callback
        
    def _notify_status(self, status: str):
        """Notify status change via callback"""
        if self.status_callback:
            self.status_callback(status)
            
    def start(self):
        """Start the FastAPI server in current thread"""
        logger.info(f"ServerManager.start() called - port={self.port}, host={self.host}")
        
        if self.is_running:
            logger.warning("Server already running")
            return
            
        try:
            # Import server app
            logger.info("Importing server app")
            from server import app, config
            logger.info("Server app imported successfully")
            
            # Update config
            config.port = self.port
            config.host = self.host
            logger.info(f"Config updated: port={config.port}, host={config.host}")
            
            # Create uvicorn server
            logger.info("Creating uvicorn server")
            uvicorn_config = uvicorn.Config(
                app=app,
                host=self.host,
                port=self.port,
                log_level="info",
                access_log=False,
                timeout_keep_alive=30
            )
            
            self.server = uvicorn.Server(uvicorn_config)
            self.is_running = True
            self._notify_status("running")
            logger.info("Starting uvicorn server.run()")
            
            # Run server (blocking)
            self.server.run()
            logger.info("Server.run() returned")
            
        except Exception as e:
            logger.error(f"Error in ServerManager.start(): {e}")
            logger.error(traceback.format_exc())
            self.is_running = False
            self._notify_status(f"error: {e}")
            raise
            
    def stop(self):
        """Stop the FastAPI server"""
        logger.info("ServerManager.stop() called")
        
        if not self.is_running or not self.server:
            logger.warning("Server not running or server instance is None")
            return
            
        try:
            self.is_running = False
            
            # Signal server to shutdown
            if self.server:
                logger.info("Setting server.should_exit = True")
                self.server.should_exit = True
                logger.info("Server shutdown signaled")
                
            self._notify_status("stopped")
            logger.info("ServerManager stopped successfully")
            
        except Exception as e:
            logger.error(f"Error in ServerManager.stop(): {e}")
            logger.error(traceback.format_exc())
            
        except Exception as e:
            self._notify_status(f"error: {e}")
            raise
            
    def get_status(self) -> dict:
        """Get current server status"""
        return {
            "running": self.is_running,
            "port": self.port,
            "host": self.host
        }
