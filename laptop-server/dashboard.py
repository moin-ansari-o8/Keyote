"""
Keyote Server Dashboard - Professional GUI Application
Modern PyQt6 desktop interface for laptop keyboard server control
"""

import sys
import json
import socket
import tempfile
import os
import logging
import traceback
from pathlib import Path
from datetime import datetime, timedelta
from typing import Optional

from PyQt6.QtWidgets import (
    QApplication, QMainWindow, QWidget, QVBoxLayout, QHBoxLayout,
    QLabel, QPushButton, QLineEdit, QTextEdit, QGroupBox, QCheckBox,
    QDialog, QFormLayout, QSpinBox, QComboBox, QMessageBox, QSystemTrayIcon,
    QMenu, QStyle
)
from PyQt6.QtCore import Qt, QTimer, pyqtSignal, QThread, QSize
from PyQt6.QtGui import QIcon, QFont, QPixmap, QAction, QPalette, QColor

from server_manager import ServerManager


VERSION = "1.0.0"
CONFIG_FILE = Path("config.json")
LOG_FILE = Path("keyote_server_errors.log")

# Setup logging
logging.basicConfig(
    level=logging.DEBUG,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(LOG_FILE),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)


class ServerThread(QThread):
    """Runs FastAPI server in background thread"""
    status_changed = pyqtSignal(str)
    log_message = pyqtSignal(str)
    
    def __init__(self, server_manager):
        super().__init__()
        self.server_manager = server_manager
        
    def run(self):
        self.server_manager.start()


class SettingsDialog(QDialog):
    """Settings configuration dialog"""
    
    def __init__(self, parent=None):
        super().__init__(parent)
        self.setWindowTitle("Server Settings")
        self.setMinimumWidth(400)
        self.setup_ui()
        self.load_settings()
        
    def setup_ui(self):
        layout = QFormLayout()
        
        # Port
        self.port_spin = QSpinBox()
        self.port_spin.setRange(1024, 65535)
        self.port_spin.setValue(5000)
        layout.addRow("Port:", self.port_spin)
        
        # Host
        self.host_input = QLineEdit()
        self.host_input.setText("0.0.0.0")
        layout.addRow("Host:", self.host_input)
        
        # Log Level
        self.log_level_combo = QComboBox()
        self.log_level_combo.addItems(["DEBUG", "INFO", "WARNING", "ERROR"])
        self.log_level_combo.setCurrentText("INFO")
        layout.addRow("Log Level:", self.log_level_combo)
        
        # Theme
        self.theme_combo = QComboBox()
        self.theme_combo.addItems(["Dark", "Light"])
        layout.addRow("Theme:", self.theme_combo)
        
        # Buttons
        button_layout = QHBoxLayout()
        save_btn = QPushButton("Save")
        save_btn.clicked.connect(self.save_settings)
        cancel_btn = QPushButton("Cancel")
        cancel_btn.clicked.connect(self.reject)
        
        button_layout.addWidget(save_btn)
        button_layout.addWidget(cancel_btn)
        
        layout.addRow(button_layout)
        self.setLayout(layout)
        
    def load_settings(self):
        if CONFIG_FILE.exists():
            try:
                with open(CONFIG_FILE, 'r') as f:
                    config = json.load(f)
                self.port_spin.setValue(config.get('port', 5000))
                self.host_input.setText(config.get('host', '0.0.0.0'))
                self.log_level_combo.setCurrentText(config.get('log_level', 'INFO'))
                self.theme_combo.setCurrentText(config.get('theme', 'Dark'))
            except Exception as e:
                print(f"Error loading settings: {e}")
                
    def save_settings(self):
        try:
            config = {
                'port': self.port_spin.value(),
                'host': self.host_input.text(),
                'log_level': self.log_level_combo.currentText(),
                'allowed_ips': [],
                'theme': self.theme_combo.currentText(),
                'auto_start': False,
                'minimize_to_tray': True
            }
            
            with open(CONFIG_FILE, 'w') as f:
                json.dump(config, f, indent=2)
                
            QMessageBox.information(self, "Success", "Settings saved! Restart server to apply changes.")
            self.accept()
        except Exception as e:
            QMessageBox.critical(self, "Error", f"Failed to save settings: {e}")


class DashboardWindow(QMainWindow):
    """Main dashboard window"""
    
    def __init__(self):
        super().__init__()
        logger.info("Initializing Keyote Server Dashboard")
        try:
            self.server_manager = ServerManager()
            self.server_thread: Optional[ServerThread] = None
            self.start_time: Optional[datetime] = None
            self.uptime_timer = QTimer()
            self.uptime_timer.timeout.connect(self.update_uptime)
            
            self.setWindowTitle(f"Keyote Server Dashboard v{VERSION}")
            self.setMinimumSize(600, 700)
            
            self.setup_ui()
            self.setup_tray()
            self.apply_theme()
            self.load_config()
            
            # Update timer for uptime
            self.uptime_timer.start(1000)
            logger.info("Dashboard initialized successfully")
        except Exception as e:
            logger.error(f"Error initializing dashboard: {e}")
            logger.error(traceback.format_exc())
            QMessageBox.critical(None, "Initialization Error", 
                f"Failed to initialize application:\n{str(e)}\n\nCheck {LOG_FILE} for details.")
            raise
        
    def setup_ui(self):
        """Build main UI layout"""
        central = QWidget()
        self.setCentralWidget(central)
        layout = QVBoxLayout(central)
        layout.setSpacing(15)
        
        # Header
        header = self.create_header()
        layout.addWidget(header)
        
        # Status Section
        status_group = self.create_status_section()
        layout.addWidget(status_group)
        
        # Network Info Section
        network_group = self.create_network_section()
        layout.addWidget(network_group)
        
        # Control Section
        control_group = self.create_control_section()
        layout.addWidget(control_group)
        
        # Activity Log
        log_group = self.create_log_section()
        layout.addWidget(log_group)
        
        # Footer Options
        footer = self.create_footer()
        layout.addWidget(footer)
        
    def create_header(self) -> QWidget:
        """Create header with title and version"""
        header = QWidget()
        layout = QHBoxLayout(header)
        
        title = QLabel("Keyote Server Dashboard")
        title_font = QFont()
        title_font.setPointSize(16)
        title_font.setBold(True)
        title.setFont(title_font)
        
        version = QLabel(f"v{VERSION}")
        version.setStyleSheet("color: #888;")
        
        layout.addWidget(title)
        layout.addStretch()
        layout.addWidget(version)
        
        return header
        
    def create_status_section(self) -> QGroupBox:
        """Create server status display"""
        group = QGroupBox("Server Status")
        layout = QVBoxLayout()
        
        # Status row
        status_layout = QHBoxLayout()
        self.status_label = QLabel("Stopped")
        self.status_label.setStyleSheet("font-size: 14px; font-weight: bold;")
        
        self.uptime_label = QLabel("Uptime: --:--:--")
        
        status_layout.addWidget(self.status_label)
        status_layout.addStretch()
        status_layout.addWidget(self.uptime_label)
        
        # Connections row
        self.connections_label = QLabel("Connections: 0 active")
        
        layout.addLayout(status_layout)
        layout.addWidget(self.connections_label)
        
        group.setLayout(layout)
        return group
        
    def create_network_section(self) -> QGroupBox:
        """Create network information display"""
        group = QGroupBox("Network Information")
        layout = QVBoxLayout()
        
        # IP Address
        ip_layout = QHBoxLayout()
        ip_label = QLabel("IP Address:")
        self.ip_display = QLineEdit(self.get_local_ip())
        self.ip_display.setReadOnly(True)
        copy_ip_btn = QPushButton("Copy")
        copy_ip_btn.setMaximumWidth(80)
        copy_ip_btn.clicked.connect(self.copy_ip)
        
        ip_layout.addWidget(ip_label)
        ip_layout.addWidget(self.ip_display)
        ip_layout.addWidget(copy_ip_btn)
        
        # Port
        port_layout = QHBoxLayout()
        port_label = QLabel("Port:")
        self.port_input = QLineEdit("5000")
        self.port_input.setMaximumWidth(100)
        update_port_btn = QPushButton("Update")
        update_port_btn.setMaximumWidth(80)
        update_port_btn.clicked.connect(self.update_port)
        
        port_layout.addWidget(port_label)
        port_layout.addWidget(self.port_input)
        port_layout.addWidget(update_port_btn)
        port_layout.addStretch()
        
        # Connection URL
        url_layout = QHBoxLayout()
        url_label = QLabel("Server URL:")
        self.url_display = QLineEdit(f"http://{self.get_local_ip()}:5000")
        self.url_display.setReadOnly(True)
        copy_url_btn = QPushButton("Copy")
        copy_url_btn.setMaximumWidth(80)
        copy_url_btn.clicked.connect(self.copy_url)
        
        url_layout.addWidget(url_label)
        url_layout.addWidget(self.url_display)
        url_layout.addWidget(copy_url_btn)
        
        layout.addLayout(ip_layout)
        layout.addLayout(port_layout)
        layout.addLayout(url_layout)
        
        group.setLayout(layout)
        return group
        
    def create_control_section(self) -> QGroupBox:
        """Create server control buttons"""
        group = QGroupBox("Control")
        layout = QHBoxLayout()
        
        self.start_stop_btn = QPushButton("Start Server")
        self.start_stop_btn.setMinimumHeight(40)
        self.start_stop_btn.clicked.connect(self.toggle_server)
        
        settings_btn = QPushButton("Settings")
        settings_btn.setMinimumHeight(40)
        settings_btn.clicked.connect(self.open_settings)
        
        layout.addWidget(self.start_stop_btn)
        layout.addWidget(settings_btn)
        
        group.setLayout(layout)
        return group
        
    def create_log_section(self) -> QGroupBox:
        """Create activity log display"""
        group = QGroupBox("Activity Log")
        layout = QVBoxLayout()
        
        self.log_display = QTextEdit()
        self.log_display.setReadOnly(True)
        self.log_display.setMaximumHeight(200)
        self.log_display.setStyleSheet("font-family: 'Consolas', monospace; font-size: 11px;")
        
        clear_log_btn = QPushButton("Clear Log")
        clear_log_btn.clicked.connect(self.clear_log)
        
        layout.addWidget(self.log_display)
        layout.addWidget(clear_log_btn)
        
        group.setLayout(layout)
        return group
        
    def create_footer(self) -> QWidget:
        """Create footer with options"""
        footer = QWidget()
        layout = QHBoxLayout(footer)
        
        self.auto_start_check = QCheckBox("Auto-start on Windows startup")
        self.minimize_tray_check = QCheckBox("Minimize to tray")
        self.minimize_tray_check.setChecked(True)
        
        layout.addWidget(self.auto_start_check)
        layout.addWidget(self.minimize_tray_check)
        layout.addStretch()
        
        return footer
        
    def setup_tray(self):
        """Setup system tray icon"""
        self.tray_icon = QSystemTrayIcon(self)
        
        # Use default icon (will be replaced with custom icon later)
        icon = self.style().standardIcon(QStyle.StandardPixmap.SP_ComputerIcon)
        self.tray_icon.setIcon(icon)
        
        # Create tray menu
        tray_menu = QMenu()
        
        show_action = QAction("Show Dashboard", self)
        show_action.triggered.connect(self.show_window)
        
        self.tray_start_action = QAction("Start Server", self)
        self.tray_start_action.triggered.connect(self.toggle_server)
        
        settings_action = QAction("Settings", self)
        settings_action.triggered.connect(self.open_settings)
        
        exit_action = QAction("Exit", self)
        exit_action.triggered.connect(self.quit_application)
        
        tray_menu.addAction(show_action)
        tray_menu.addSeparator()
        tray_menu.addAction(self.tray_start_action)
        tray_menu.addSeparator()
        tray_menu.addAction(settings_action)
        tray_menu.addSeparator()
        tray_menu.addAction(exit_action)
        
        self.tray_icon.setContextMenu(tray_menu)
        self.tray_icon.activated.connect(self.tray_icon_activated)
        self.tray_icon.show()
        
    def tray_icon_activated(self, reason):
        """Handle tray icon clicks"""
        if reason == QSystemTrayIcon.ActivationReason.Trigger:
            self.show_window()
            
    def show_window(self):
        """Show and activate main window"""
        self.show()
        self.activateWindow()
        self.raise_()
        
    def closeEvent(self, event):
        """Handle window close - minimize to tray if enabled"""
        if self.minimize_tray_check.isChecked():
            event.ignore()
            self.hide()
            # Only show notification if tray icon is visible
            if self.tray_icon.isVisible():
                self.tray_icon.showMessage(
                    "Keyote Server",
                    "Application minimized to tray",
                    QSystemTrayIcon.MessageIcon.Information,
                    2000
                )
        else:
            # If not minimizing to tray, properly exit
            event.accept()
            self.quit_application()
            
    def apply_theme(self, theme="Dark"):
        """Apply color theme to application"""
        if theme == "Dark":
            palette = QPalette()
            palette.setColor(QPalette.ColorRole.Window, QColor(53, 53, 53))
            palette.setColor(QPalette.ColorRole.WindowText, Qt.GlobalColor.white)
            palette.setColor(QPalette.ColorRole.Base, QColor(35, 35, 35))
            palette.setColor(QPalette.ColorRole.AlternateBase, QColor(53, 53, 53))
            palette.setColor(QPalette.ColorRole.ToolTipBase, Qt.GlobalColor.white)
            palette.setColor(QPalette.ColorRole.ToolTipText, Qt.GlobalColor.white)
            palette.setColor(QPalette.ColorRole.Text, Qt.GlobalColor.white)
            palette.setColor(QPalette.ColorRole.Button, QColor(53, 53, 53))
            palette.setColor(QPalette.ColorRole.ButtonText, Qt.GlobalColor.white)
            palette.setColor(QPalette.ColorRole.BrightText, Qt.GlobalColor.red)
            palette.setColor(QPalette.ColorRole.Link, QColor(42, 130, 218))
            palette.setColor(QPalette.ColorRole.Highlight, QColor(42, 130, 218))
            palette.setColor(QPalette.ColorRole.HighlightedText, Qt.GlobalColor.black)
            
            QApplication.instance().setPalette(palette)
            
    def load_config(self):
        """Load configuration from file"""
        if CONFIG_FILE.exists():
            try:
                with open(CONFIG_FILE, 'r') as f:
                    config = json.load(f)
                self.port_input.setText(str(config.get('port', 5000)))
                self.auto_start_check.setChecked(config.get('auto_start', False))
                self.minimize_tray_check.setChecked(config.get('minimize_to_tray', True))
                theme = config.get('theme', 'Dark')
                self.apply_theme(theme)
            except Exception as e:
                self.log(f"Error loading config: {e}")
                
    def get_local_ip(self) -> str:
        """Get local IP address"""
        try:
            s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            s.connect(("8.8.8.8", 80))
            ip = s.getsockname()[0]
            s.close()
            return ip
        except Exception:
            return "127.0.0.1"
            
    def copy_ip(self):
        """Copy IP address to clipboard"""
        clipboard = QApplication.clipboard()
        clipboard.setText(self.ip_display.text())
        self.log("IP address copied to clipboard")
        
    def copy_url(self):
        """Copy server URL to clipboard"""
        clipboard = QApplication.clipboard()
        clipboard.setText(self.url_display.text())
        self.log("Server URL copied to clipboard")
        
    def update_port(self):
        """Update server port"""
        try:
            new_port = int(self.port_input.text())
            if new_port < 1024 or new_port > 65535:
                QMessageBox.warning(self, "Invalid Port", "Port must be between 1024 and 65535")
                return
                
            if CONFIG_FILE.exists():
                with open(CONFIG_FILE, 'r') as f:
                    config = json.load(f)
            else:
                config = {}
                
            config['port'] = new_port
            
            with open(CONFIG_FILE, 'w') as f:
                json.dump(config, f, indent=2)
                
            self.url_display.setText(f"http://{self.get_local_ip()}:{new_port}")
            self.log(f"Port updated to {new_port}. Restart server to apply.")
            QMessageBox.information(self, "Success", "Port updated! Restart server to apply changes.")
            
        except ValueError:
            QMessageBox.warning(self, "Invalid Port", "Please enter a valid port number")
            
    def toggle_server(self):
        """Start or stop the server"""
        if self.server_thread and self.server_thread.isRunning():
            self.stop_server()
        else:
            self.start_server()
            
    def start_server(self):
        """Start the FastAPI server"""
        logger.info("Attempting to start server")
        try:
            port = int(self.port_input.text())
            logger.info(f"Port: {port}")
            
            # Validate port
            if port < 1024 or port > 65535:
                raise ValueError(f"Invalid port number: {port}. Must be between 1024-65535")
            
            self.server_manager.port = port
            logger.info(f"Server manager port set to {port}")
            
            # Set log callback to receive server logs
            try:
                from server import set_log_callback
                set_log_callback(self.log)
                logger.info("Log callback set successfully")
            except Exception as e:
                logger.warning(f"Could not set log callback: {e}")
            
            # Create and start server thread
            logger.info("Creating server thread")
            self.server_thread = ServerThread(self.server_manager)
            self.server_thread.start()
            logger.info("Server thread started")
            
            self.status_label.setText("Running")
            self.status_label.setStyleSheet("font-size: 14px; font-weight: bold; color: #00ff00;")
            self.start_stop_btn.setText("Stop Server")
            self.tray_start_action.setText("Stop Server")
            
            self.start_time = datetime.now()
            self.log(f"Server started on port {port}")
            self.log(f"Server URL: http://{self.get_local_ip()}:{port}")
            logger.info(f"Server started successfully on port {port}")
            
            if hasattr(self, 'tray_icon') and self.tray_icon.isVisible():
                self.tray_icon.showMessage(
                    "Keyote Server",
                    f"Server started on port {port}",
                    QSystemTrayIcon.MessageIcon.Information,
                    2000
                )
            
        except ValueError as e:
            error_msg = str(e)
            logger.error(f"Validation error: {error_msg}")
            QMessageBox.warning(self, "Invalid Input", error_msg)
            self.log(f"Error: {error_msg}")
        except Exception as e:
            error_msg = f"Failed to start server: {str(e)}"
            logger.error(error_msg)
            logger.error(traceback.format_exc())
            QMessageBox.critical(self, "Server Start Error", 
                f"{error_msg}\n\nCheck {LOG_FILE} for details.")
            self.log(f"Error: {error_msg}")
            
    def stop_server(self):
        """Stop the FastAPI server"""
        logger.info("Attempting to stop server")
        try:
            if self.server_thread:
                logger.info("Stopping server manager")
                self.server_manager.stop()
                logger.info("Quitting server thread")
                self.server_thread.quit()
                logger.info("Waiting for server thread to finish")
                self.server_thread.wait()
                logger.info("Server thread stopped")
                
            self.status_label.setText("Stopped")
            self.status_label.setStyleSheet("font-size: 14px; font-weight: bold; color: #ff0000;")
            self.start_stop_btn.setText("Start Server")
            self.tray_start_action.setText("Start Server")
            
            self.start_time = None
            self.uptime_label.setText("Uptime: --:--:--")
            self.log("Server stopped")
            logger.info("Server stopped successfully")
            
            if hasattr(self, 'tray_icon') and self.tray_icon.isVisible():
                self.tray_icon.showMessage(
                    "Keyote Server",
                    "Server stopped",
                    QSystemTrayIcon.MessageIcon.Information,
                    2000
                )
            
        except Exception as e:
            error_msg = f"Error stopping server: {str(e)}"
            logger.error(error_msg)
            logger.error(traceback.format_exc())
            QMessageBox.critical(self, "Server Stop Error", 
                f"{error_msg}\n\nCheck {LOG_FILE} for details.")
            self.log(error_msg)
            
    def update_uptime(self):
        """Update uptime display"""
        if self.start_time:
            uptime = datetime.now() - self.start_time
            hours = uptime.seconds // 3600
            minutes = (uptime.seconds % 3600) // 60
            seconds = uptime.seconds % 60
            self.uptime_label.setText(f"Uptime: {hours:02d}:{minutes:02d}:{seconds:02d}")
            
    def open_settings(self):
        """Open settings dialog"""
        dialog = SettingsDialog(self)
        if dialog.exec():
            self.load_config()
            
    def clear_log(self):
        """Clear activity log"""
        self.log_display.clear()
        
    def log(self, message: str):
        """Add message to activity log"""
        timestamp = datetime.now().strftime("%H:%M:%S")
        self.log_display.append(f"[{timestamp}] {message}")
        
    def quit_application(self):
        """Quit application completely"""
        reply = QMessageBox.question(
            self,
            "Confirm Exit",
            "Are you sure you want to exit?",
            QMessageBox.StandardButton.Yes | QMessageBox.StandardButton.No
        )
        
        if reply == QMessageBox.StandardButton.Yes:
            if self.server_thread and self.server_thread.isRunning():
                self.stop_server()
            
            # Hide and cleanup tray icon before quitting
            if hasattr(self, 'tray_icon'):
                self.tray_icon.hide()
                self.tray_icon.deleteLater()
            
            QApplication.quit()


def main():
    logger.info("="*60)
    logger.info("Keyote Server Dashboard Starting")
    logger.info(f"Version: {VERSION}")
    logger.info(f"Log file: {LOG_FILE.absolute()}")
    logger.info("="*60)
    
    try:
        # Single instance lock using a lock file
        lock_file = os.path.join(tempfile.gettempdir(), 'keyote_server.lock')
        logger.info(f"Lock file: {lock_file}")
        
        # Try to create lock file
        try:
            # Check if lock file exists and contains a running process
            if os.path.exists(lock_file):
                logger.info("Lock file exists, checking if process is running")
                try:
                    with open(lock_file, 'r') as f:
                        pid = int(f.read().strip())
                    logger.info(f"Found PID in lock file: {pid}")
                    # Check if process is still running on Windows
                    import psutil
                    if psutil.pid_exists(pid):
                        # Another instance is already running
                        logger.warning(f"Another instance already running (PID: {pid})")
                        app = QApplication(sys.argv)
                        QMessageBox.warning(
                            None,
                            "Already Running",
                            "Keyote Server is already running. Check the system tray.",
                            QMessageBox.StandardButton.Ok
                        )
                        return
                    else:
                        logger.info(f"Process {pid} not running, removing stale lock file")
                except (ValueError, FileNotFoundError, ImportError) as e:
                    logger.warning(f"Could not check lock file: {e}")
                    pass
            
            # Write current process ID to lock file
            with open(lock_file, 'w') as f:
                f.write(str(os.getpid()))
            logger.info(f"Created lock file with PID: {os.getpid()}")
                
        except Exception as e:
            logger.warning(f"Could not create lock file: {e}")
        
        logger.info("Creating QApplication")
        app = QApplication(sys.argv)
        app.setApplicationName("Keyote Server")
        app.setOrganizationName("Keyote")
        
        # Set quit on last window closed to False (app stays in tray)
        app.setQuitOnLastWindowClosed(False)
        logger.info("QApplication created")
        
        logger.info("Creating DashboardWindow")
        window = DashboardWindow()
        window.show()
        logger.info("DashboardWindow shown")
        
        logger.info("Starting event loop")
        exit_code = app.exec()
        logger.info(f"Event loop exited with code: {exit_code}")
        
        # Clean up lock file on exit
        try:
            if os.path.exists(lock_file):
                os.remove(lock_file)
                logger.info("Lock file removed")
        except Exception as e:
            logger.warning(f"Could not remove lock file: {e}")
        
        logger.info("Application exiting normally")
        sys.exit(exit_code)
        
    except Exception as e:
        logger.critical("FATAL ERROR in main()")
        logger.critical(str(e))
        logger.critical(traceback.format_exc())
        
        # Try to show error dialog
        try:
            app = QApplication.instance() or QApplication(sys.argv)
            QMessageBox.critical(
                None,
                "Fatal Error",
                f"Application crashed:\n{str(e)}\n\nCheck {LOG_FILE.absolute()} for details."
            )
        except:
            pass
        
        sys.exit(1)


if __name__ == "__main__":
    main()
