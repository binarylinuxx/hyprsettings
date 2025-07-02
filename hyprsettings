#!/usr/bin/env python3

import gi
gi.require_version('Gtk', '4.0')
gi.require_version('Adw', '1')
from gi.repository import Gtk, Adw, GdkPixbuf, Gio, GLib
import os
import subprocess
import shutil
import configparser
import argparse
from pathlib import Path
import json
import re

class HyprlandSettingsApp(Adw.Application):
    def __init__(self):
        super().__init__(application_id='com.github.binarylinuxx.hyprland-settings')
        self.wallpaper_path = ""
        self.current_light_mode = "Default"
        self.current_volume = 50
        self.is_muted = False
        
        # Config directory and file
        self.config_dir = Path.home() / '.config' / 'hyprsettings'
        self.config_file = self.config_dir / 'config.ini'
        self.config_dir.mkdir(parents=True, exist_ok=True)
        
        # Initialize config parser
        self.config = configparser.ConfigParser()
        self.load_config()
        
        self.presets = {
            "Default": {"temp": 6500, "gamma": 100},
            "Overcast": {"temp": 5500, "gamma": 100},
            "Warm Light": {"temp": 4500, "gamma": 100},
            "Sunset": {"temp": 3500, "gamma": 110},
            "Candlelight": {"temp": 2000, "gamma": 120},
            "Night Light": {"temp": 3000, "gamma": 90},
            "Cool White": {"temp": 8000, "gamma": 100}
        }

    def get_system_info(self):
        """Collect various system information"""
        info = {
            "os": self.get_os_info(),
            "cpu": self.get_cpu_info(),
            "memory": self.get_memory_info(),
            "disk": self.get_disk_info(),
            "gpu": self.get_gpu_info(),
            "hyprland": self.get_hyprland_info()
        }
        return info
    
    def get_os_info(self):
        """Get OS information"""
        try:
            with open("/etc/os-release") as f:
                os_release = f.read()
            name = re.search(r'PRETTY_NAME="(.+?)"', os_release).group(1)
            return name
        except:
            return "Unknown OS"
    
    def get_cpu_info(self):
        """Get CPU information"""
        try:
            with open("/proc/cpuinfo") as f:
                cpuinfo = f.read()
            model = re.search(r'model name\s*:\s*(.+?)\n', cpuinfo).group(1)
            cores = len(re.findall(r'processor\s*:\s*\d+', cpuinfo))
            return f"{model} ({cores} cores)"
        except:
            return "Unknown CPU"
    
    def get_memory_info(self):
        """Get memory information"""
        try:
            with open("/proc/meminfo") as f:
                meminfo = f.read()
            total = int(re.search(r'MemTotal:\s*(\d+)', meminfo).group(1)) // 1024
            available = int(re.search(r'MemAvailable:\s*(\d+)', meminfo).group(1)) // 1024
            used = total - available
            return f"{used}MB / {total}MB ({int(used/total*100)}% used)"
        except:
            return "Unknown memory"
    
    def get_disk_info(self):
        """Get disk usage information"""
        try:
            result = subprocess.run(["df", "-h", "--output=source,pcent,avail"], 
                                  capture_output=True, text=True, check=True)
            lines = result.stdout.splitlines()
            # Filter for root filesystem
            for line in lines:
                if line.startswith("/dev/"):
                    parts = line.split()
                    if len(parts) >= 3:
                        return f"{parts[2]} free ({parts[1]} used)"
            return "Unknown disk"
        except:
            return "Unknown disk"
    
    def get_gpu_info(self):
        """Get GPU information"""
        try:
            result = subprocess.run(["lspci", "-nn"], 
                                  capture_output=True, text=True, check=True)
            gpu_lines = [line for line in result.stdout.splitlines() if "VGA" in line]
            if gpu_lines:
                return gpu_lines[0].split(": ")[-1]
            return "Unknown GPU"
        except:
            return "Unknown GPU"
    
    def get_hyprland_info(self):
                """Get Hyprland version information"""
                try:
                    # First try hyprctl version
                    try:
                        result = subprocess.run(["hyprctl", "version"], 
                                              capture_output=True, text=True, check=True)
                        version_output = result.stdout
                        
                        # Try to extract version from various possible formats
                        if "Hyprland" in version_output:
                            # Format: "Hyprland, version v0.40.0"
                            match = re.search(r'Hyprland.*version\s+v?([\d.]+)', version_output)
                            if match:
                                return f"v{match.group(1)}"
                        
                        # Alternative format: "tag: v0.49.0"
                        match = re.search(r'tag:\s+v?([\d.]+)', version_output)
                        if match:
                            return f"v{match.group(1)}"
                        
                        # Fallback to just showing the first line
                        return version_output.splitlines()[0].strip()
                        
                    except (subprocess.CalledProcessError, FileNotFoundError):
                        # If hyprctl fails, try checking the package version
                        try:
                            # For Void Linux (your OS)
                            result = subprocess.run(["xbps-query", "-Rs", "hyprland"],
                                                  capture_output=True, text=True, check=True)
                            pkg_info = result.stdout
                            match = re.search(r'hyprland-([\d.]+)', pkg_info)
                            if match:
                                return f"v{match.group(1)} (via xbps)"
                            
                            # For Arch Linux
                            result = subprocess.run(["pacman", "-Qi", "hyprland"],
                                                  capture_output=True, text=True, check=True)
                            pkg_info = result.stdout
                            match = re.search(r'Version\s*:\s*([\d.]+)', pkg_info)
                            if match:
                                return f"v{match.group(1)} (via pacman)"
                            
                            # For Debian/Ubuntu
                            result = subprocess.run(["apt", "list", "--installed", "hyprland"],
                                                  capture_output=True, text=True, check=True)
                            pkg_info = result.stdout
                            match = re.search(r'hyprland/(?:\w+\s+)?([\d.]+)', pkg_info)
                            if match:
                                return f"v{match.group(1)} (via apt)"
                            
                        except (subprocess.CalledProcessError, FileNotFoundError):
                            pass
                        
                        return "Hyprland (version unknown)"
                        
                except Exception as e:
                    print(f"Error getting Hyprland version: {e}")
                    return "Hyprland (error getting version)"
        
    def load_config(self):
        """Load configuration from config.ini"""
        if self.config_file.exists():
            self.config.read(self.config_file)
            
            # Load wallpaper
            if self.config.has_option('Desk', 'wallpaper'):
                saved_wallpaper = self.config.get('Desk', 'wallpaper')
                if os.path.exists(saved_wallpaper):
                    self.wallpaper_path = saved_wallpaper
            
            # Load light mode
            if self.config.has_option('Screen', 'light_mode'):
                self.current_light_mode = self.config.get('Screen', 'light_mode')
                
            # Load audio settings
            if self.config.has_option('Audio', 'volume'):
                self.current_volume = int(self.config.get('Audio', 'volume'))
            if self.config.has_option('Audio', 'muted'):
                self.is_muted = self.config.getboolean('Audio', 'muted')
        else:
            # Create default config structure
            self.config.add_section(' Desk')
            self.config.add_section(' Screen')
            self.config.add_section(' Audio')
            self.save_config()
    
    def save_config(self):
        """Save current configuration to config.ini"""
        if not self.config.has_section('Desk'):
            self.config.add_section('Desk')
        if not self.config.has_section('Screen'):
            self.config.add_section('Screen')
        if not self.config.has_section('Audio'):
            self.config.add_section('Audio')
            
        self.config.set('Desk', 'wallpaper', self.wallpaper_path)
        self.config.set('Screen', 'light_mode', self.current_light_mode)
        self.config.set('Audio', 'volume', str(self.current_volume))
        self.config.set('Audio', 'muted', str(self.is_muted))
        
        with open(self.config_file, 'w') as f:
            self.config.write(f)
    
    def get_current_volume(self):
        """Get current volume using pamixer"""
        try:
            if shutil.which("pamixer"):
                # Get volume level
                result = subprocess.run(["pamixer", "--get-volume"], 
                                      capture_output=True, text=True, check=True)
                volume = int(result.stdout.strip())
                
                # Check if muted
                result = subprocess.run(["pamixer", "--get-mute"], 
                                      capture_output=True, text=True, check=True)
                muted = result.stdout.strip().lower() == "true"
                
                return volume, muted
            else:
                return self.current_volume, self.is_muted
        except Exception as e:
            print(f"Error getting volume: {e}")
            return self.current_volume, self.is_muted
    
    def set_volume(self, volume):
        """Set volume using pamixer"""
        try:
            if shutil.which("pamixer"):
                subprocess.run(["pamixer", "--set-volume", str(volume)], check=True)
                self.current_volume = volume
                self.save_config()
                return True
        except Exception as e:
            print(f"Error setting volume: {e}")
        return False
    
    def toggle_mute(self):
        """Toggle mute state using pamixer"""
        try:
            if shutil.which("pamixer"):
                subprocess.run(["pamixer", "--toggle-mute"], check=True)
                _, self.is_muted = self.get_current_volume()
                self.save_config()
                return True
        except Exception as e:
            print(f"Error toggling mute: {e}")
        return False
    
    def restore_settings(self):
        """Restore settings from config (for --restore flag)"""
        try:
            # Restore wallpaper
            if self.wallpaper_path and os.path.exists(self.wallpaper_path):
                self.kill_process("swaybg")
                subprocess.Popen(["swaybg", "-i", self.wallpaper_path, "-m", "fill"])
                subprocess.Popen(["notify-send", "Theme Reloaded And changed wallpaper"])
                subprocess.Popen(f'echo "\\$wall={self.wallpaper_path}" > ~/.config/hypr/current_wall.conf', shell=True)
                
                # Generate color scheme
                if shutil.which("matugen"):
                    subprocess.Popen(["matugen", "image", "-m", "dark", "-t", "scheme-content", self.wallpaper_path])
                
                print(f"Restored wallpaper: {self.wallpaper_path}")
            
            # Restore light mode
            if self.current_light_mode in self.presets:
                preset = self.presets[self.current_light_mode]
                self.kill_process("hyprsunset")
                
                if shutil.which("hyprsunset"):
                    subprocess.Popen(["hyprsunset", "-t", str(preset["temp"]), "-g", str(preset["gamma"])])
                    print(f"Restored light mode: {self.current_light_mode} (Temp: {preset['temp']}K, Gamma: {preset['gamma']}%)")
            
            # Restore audio settings
            if shutil.which("pamixer"):
                subprocess.run(["pamixer", "--set-volume", str(self.current_volume)], check=False)
                if self.is_muted:
                    subprocess.run(["pamixer", "--mute"], check=False)
                else:
                    subprocess.run(["pamixer", "--unmute"], check=False)
                print(f"Restored audio: Volume {self.current_volume}%, Muted: {self.is_muted}")
            
            print("Settings restored successfully!")
            return True
            
        except Exception as e:
            print(f"Error restoring settings: {e}")
            return False
        
    def do_activate(self):
        self.win = Adw.ApplicationWindow(application=self, title="Hyprland Settings")
        self.win.set_default_size(800, 600)
        
        # Create main box
        main_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=12)
        main_box.set_margin_top(12)
        main_box.set_margin_bottom(12)
        main_box.set_margin_start(12)
        main_box.set_margin_end(12)
        
        # Create stack and switcher
        stack = Gtk.Stack()
        stack.set_transition_type(Gtk.StackTransitionType.SLIDE_LEFT_RIGHT)
        stack.set_transition_duration(300)
        
        switcher = Gtk.StackSwitcher()
        switcher.set_stack(stack)
        main_box.append(switcher)
        main_box.append(stack)
        
        # Desktop Section
        desktop_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=12)
        stack.add_titled(desktop_box, "desktop", "Desktop")
        
        # Wallpaper Section
        wall_frame = Adw.PreferencesGroup(title="Wallpaper")
        desktop_box.append(wall_frame)
        
        # Current wallpaper preview
        self.wall_preview = Gtk.Picture()
        self.wall_preview.set_size_request(600, 300)
        self.wall_preview.set_can_shrink(True)
        wall_frame.add(self.wall_preview)
        
        # Load wallpaper preview from config
        self.update_wallpaper_preview()
        
        # Browse button
        browse_btn = Gtk.Button(label=" Browse Wallpaper")
        browse_btn.connect("clicked", self.on_browse_wallpaper)
        wall_frame.add(browse_btn)
        
        # Apply button
        self.apply_btn = Gtk.Button(label="Apply Wallpaper & Generate Scheme")
        self.apply_btn.connect("clicked", self.on_apply_wallpaper)
        self.apply_btn.set_sensitive(bool(self.wallpaper_path))
        wall_frame.add(self.apply_btn)
        
        # Screen Section
        screen_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=12)
        stack.add_titled(screen_box, "screen", "Screen")
        
        # Hyprsunset settings
        hyprsunset_frame = Adw.PreferencesGroup(title="Hyprsunset Configuration")
        screen_box.append(hyprsunset_frame)
        
        # Current mode display
        self.current_mode_label = Gtk.Label()
        self.current_mode_label.set_markup(f"<b>Current Mode:</b> {self.current_light_mode}")
        self.current_mode_label.set_halign(Gtk.Align.START)
        hyprsunset_frame.add(self.current_mode_label)
        
        # Presets Section
        presets_frame = Adw.PreferencesGroup(title="Quick Presets")
        screen_box.append(presets_frame)
        
        # Create preset buttons in a flow box for better wrapping
        presets_flowbox = Gtk.FlowBox()
        presets_flowbox.set_selection_mode(Gtk.SelectionMode.NONE)
        presets_flowbox.set_homogeneous(True)
        presets_frame.add(presets_flowbox)
        
        for preset_name, values in self.presets.items():
            btn = Gtk.Button(label=preset_name)
            btn.connect("clicked", self.on_preset_selected, preset_name, values)
            btn.set_size_request(120, -1)
            
            # Highlight current mode
            if preset_name == self.current_light_mode:
                btn.add_css_class("suggested-action")
            
            presets_flowbox.insert(btn, -1)
        
        # Manual Controls Section
        controls_frame = Adw.PreferencesGroup(title="Or Manual Controls choose the best for Yourself :)")
        screen_box.append(controls_frame)
        
        # Temperature control
        self.temp_row = Adw.SpinRow.new_with_range(1000, 10000, 100)
        self.temp_row.set_title("Temperature (K)")
        
        # Set initial values based on current mode
        if self.current_light_mode in self.presets:
            self.temp_row.set_value(self.presets[self.current_light_mode]["temp"])
            gamma_val = self.presets[self.current_light_mode]["gamma"]
        else:
            self.temp_row.set_value(6500)
            gamma_val = 100
            
        controls_frame.add(self.temp_row)
        
        # Gamma control
        self.gamma_row = Adw.SpinRow.new_with_range(50, 200, 1)
        self.gamma_row.set_title("Gamma (%)")
        self.gamma_row.set_value(gamma_val)
        controls_frame.add(self.gamma_row)
        
        # Apply button
        apply_btn = Gtk.Button(label="Apply Custom Settings")
        apply_btn.connect("clicked", self.on_apply_hyprsunset)
        controls_frame.add(apply_btn)
        
        # Restore Section
        restore_frame = Adw.PreferencesGroup(title="Restore Settings")
        screen_box.append(restore_frame)
        
        restore_btn = Gtk.Button(label="Restore Last Configuration")
        restore_btn.connect("clicked", self.on_restore_clicked)
        restore_btn.add_css_class("destructive-action")
        restore_frame.add(restore_btn)
        
        # Audio Section
        audio_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=12)
        stack.add_titled(audio_box, "audio", "Audio")
        
        # Volume Control Section
        volume_frame = Adw.PreferencesGroup(title="Volume Control")
        audio_box.append(volume_frame)
        
        # Get current volume and mute state
        self.current_volume, self.is_muted = self.get_current_volume()
        
        # Current volume display
        self.volume_status_label = Gtk.Label()
        self.update_volume_status_label()
        self.volume_status_label.set_halign(Gtk.Align.START)
        volume_frame.add(self.volume_status_label)
        
        # Volume scale
        self.volume_scale = Gtk.Scale.new_with_range(Gtk.Orientation.HORIZONTAL, 0, 100, 1)
        self.volume_scale.set_value(self.current_volume)
        self.volume_scale.set_draw_value(True)
        self.volume_scale.set_value_pos(Gtk.PositionType.RIGHT)
        self.volume_scale.connect("value-changed", self.on_volume_changed)
        
        # Create a box for the volume scale with label
        volume_scale_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=6)
        volume_scale_label = Gtk.Label(label="Volume Level")
        volume_scale_label.set_halign(Gtk.Align.START)
        volume_scale_box.append(volume_scale_label)
        volume_scale_box.append(self.volume_scale)
        volume_frame.add(volume_scale_box)
        
        # Volume buttons section
        volume_buttons_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=12)
        volume_buttons_box.set_homogeneous(True)
        
        # Mute/Unmute button
        self.mute_btn = Gtk.Button()
        self.update_mute_button()
        self.mute_btn.connect("clicked", self.on_mute_clicked)
        volume_buttons_box.append(self.mute_btn)
        
        # Quick volume buttons
        vol_down_btn = Gtk.Button(label="Volume -10%")
        vol_down_btn.connect("clicked", self.on_volume_quick_change, -10)
        volume_buttons_box.append(vol_down_btn)
        
        vol_up_btn = Gtk.Button(label="Volume +10%")
        vol_up_btn.connect("clicked", self.on_volume_quick_change, 10)
        volume_buttons_box.append(vol_up_btn)
        
        volume_frame.add(volume_buttons_box)
        
        # Volume presets
        volume_presets_frame = Adw.PreferencesGroup(title="Volume Presets")
        audio_box.append(volume_presets_frame)
        
        volume_presets_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=12)
        volume_presets_box.set_homogeneous(True)
        
        volume_presets = [("Low", 25), ("Medium", 50), ("High", 75), ("Max", 100)]
        for preset_name, volume in volume_presets:
            btn = Gtk.Button(label=f"{preset_name} ({volume}%)")
            btn.connect("clicked", self.on_volume_preset_clicked, volume)
            volume_presets_box.append(btn)
        
        volume_presets_frame.add(volume_presets_box)
        
        # Audio info section
        audio_info_frame = Adw.PreferencesGroup(title="Audio Information")
        audio_box.append(audio_info_frame)
        
        # Refresh audio info button
        refresh_audio_btn = Gtk.Button(label="Refresh Audio Status")
        refresh_audio_btn.connect("clicked", self.on_refresh_audio_clicked)
        audio_info_frame.add(refresh_audio_btn)
        
        # Audio status label
        self.audio_info_label = Gtk.Label()
        self.audio_info_label.set_selectable(True)
        self.audio_info_label.set_wrap(True)
        self.audio_info_label.set_halign(Gtk.Align.START)
        self.update_audio_info()
        audio_info_frame.add(self.audio_info_label)
        
        # Create a scrolled window and set the main box as its child
        scrolled = Gtk.ScrolledWindow()
        # System Info Section
        sysinfo_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=12)
        stack.add_titled(sysinfo_box, "sysinfo", "System Info")
        
        # System Info Frame
        sysinfo_frame = Adw.PreferencesGroup(title="System Information")
        sysinfo_box.append(sysinfo_frame)
        
        # Refresh button
        refresh_btn = Gtk.Button(label=" Refresh Information")
        refresh_btn.connect("clicked", self.update_system_info_display)
        sysinfo_frame.add(refresh_btn)
        
        # System info display
        self.sysinfo_label = Gtk.Label()
        self.sysinfo_label.set_selectable(True)
        self.sysinfo_label.set_wrap(True)
        self.sysinfo_label.set_halign(Gtk.Align.START)
        self.sysinfo_label.set_margin_top(12)
        self.sysinfo_label.set_margin_bottom(12)
        self.sysinfo_label.set_margin_start(12)
        self.sysinfo_label.set_margin_end(12)
        sysinfo_frame.add(self.sysinfo_label)
        
        # Initial update
        self.update_system_info_display()
        scrolled.set_child(main_box)
        
        # Set the scrolled window as the window's child
        self.win.set_content(scrolled)
        self.win.present()

    def update_system_info_display(self, button=None):
        """Update the system information display"""
        try:
            info = self.get_system_info()
            info_text = ""
            info_text += f"<b>OS:</b> {info['os']}\n\n"
            info_text += f"<b>CPU:</b> {info['cpu']}\n\n"
            info_text += f"<b>Memory:</b> {info['memory']}\n\n"
            info_text += f"<b>Disk:</b> {info['disk']}\n\n"
            info_text += f"<b>GPU:</b> {info['gpu']}\n\n"
            info_text += f"<b>Hyprland:</b> {info['hyprland']}"
            
            self.sysinfo_label.set_markup(info_text)
        except Exception as e:
            self.sysinfo_label.set_text(f"Error getting system info: {str(e)}")
    
    def update_volume_status_label(self):
        """Update the volume status label"""
        mute_status = " Muted" if self.is_muted else " Unmuted"
        self.volume_status_label.set_markup(f"<b>Current Volume:</b> {self.current_volume}% - {mute_status}")
    
    def update_mute_button(self):
        """Update the mute button text and style"""
        if self.is_muted:
            self.mute_btn.set_label(" Unmute")
            self.mute_btn.add_css_class("destructive-action")
        else:
            self.mute_btn.set_label(" Mute")
            self.mute_btn.remove_css_class("destructive-action")
    
    def update_audio_info(self):
        """Update audio information display"""
        try:
            if shutil.which("pamixer"):
                # Get detailed audio info
                result = subprocess.run(["pamixer", "--get-volume-human"], 
                                      capture_output=True, text=True, check=False)
                volume_human = result.stdout.strip() if result.returncode == 0 else "N/A"
                
                info_text = f"Volume (Human Readable): {volume_human}\n"
                info_text += f"Volume (Numeric): {self.current_volume}%\n"
                info_text += f"Muted: {'Yes' if self.is_muted else 'No'}\n"
                info_text += f"Audio System: PulseAudio/PipeWire (via pamixer)"
                
                self.audio_info_label.set_text(info_text)
            else:
                self.audio_info_label.set_text("pamixer not found in PATH\nPlease install pamixer for audio control")
        except Exception as e:
            self.audio_info_label.set_text(f"Error getting audio info: {e}")
    
    def on_volume_changed(self, scale):
        """Handle volume scale changes"""
        volume = int(scale.get_value())
        if self.set_volume(volume):
            self.current_volume = volume
            self.update_volume_status_label()
    
    def on_mute_clicked(self, button):
        """Handle mute button clicks"""
        if self.toggle_mute():
            self.update_mute_button()
            self.update_volume_status_label()
            self.update_audio_info()
    
    def on_volume_quick_change(self, button, change):
        """Handle quick volume change buttons"""
        new_volume = max(0, min(100, self.current_volume + change))
        if self.set_volume(new_volume):
            self.volume_scale.set_value(new_volume)
            self.update_volume_status_label()
    
    def on_volume_preset_clicked(self, button, volume):
        """Handle volume preset button clicks"""
        if self.set_volume(volume):
            self.volume_scale.set_value(volume)
            self.update_volume_status_label()
    
    def on_refresh_audio_clicked(self, button):
        """Handle refresh audio info button clicks"""
        self.current_volume, self.is_muted = self.get_current_volume()
        self.volume_scale.set_value(self.current_volume)
        self.update_volume_status_label()
        self.update_mute_button()
        self.update_audio_info()
    
    def update_wallpaper_preview(self):
        if not self.wallpaper_path or not os.path.exists(self.wallpaper_path):
            return
            
        try:
            pixbuf = GdkPixbuf.Pixbuf.new_from_file_at_size(
                self.wallpaper_path, 
                600, 
                300
            )
            self.wall_preview.set_pixbuf(pixbuf)
            self.apply_btn.set_sensitive(True)
        except Exception as e:
            print(f"Error loading wallpaper preview: {e}")
    
    def on_browse_wallpaper(self, button):
        dialog = Gtk.FileChooserNative(
            title="Choose Wallpaper",
            transient_for=self.win,
            action=Gtk.FileChooserAction.OPEN
        )
        
        # Set filters for images
        filter_images = Gtk.FileFilter()
        filter_images.set_name("Image files")
        filter_images.add_mime_type("image/*")
        dialog.add_filter(filter_images)
        
        dialog.connect("response", self.on_file_selected)
        dialog.show()
    
    def on_file_selected(self, dialog, response):
        if response == Gtk.ResponseType.ACCEPT:
            file = dialog.get_file()
            self.wallpaper_path = file.get_path()
            self.update_wallpaper_preview()
            self.save_config()  # Save immediately when wallpaper is selected
        dialog.destroy()
    
    def on_apply_wallpaper(self, button):
        if not self.wallpaper_path:
            return
            
        try:
            # Kill existing swaybg process
            self.kill_process("swaybg")
            
            # Set new wallpaper
            subprocess.Popen(["swaybg", "-i", self.wallpaper_path, "-m", "fill"])
            subprocess.Popen(["notify-send", "Theme Reloaded And changed wallpaper"])
            subprocess.Popen(f'echo "\\$wall={self.wallpaper_path}" > ~/.config/hypr/current_wall.conf', shell=True)
            
            # Generate color scheme
            if shutil.which("matugen"):
                subprocess.Popen(["matugen", "image", "-m", "dark", "-t", "scheme-content", self.wallpaper_path])
            
            # Save config
            self.save_config()
            
            self.show_message("Wallpaper Applied", "Wallpaper set and color scheme generated.")
        except Exception as e:
            self.show_message("Error", f"Failed to apply wallpaper: {str(e)}", is_error=True)
    
    def on_preset_selected(self, button, preset_name, preset_values):
        """Apply a preset configuration"""
        self.current_light_mode = preset_name
        self.temp_row.set_value(preset_values["temp"])
        self.gamma_row.set_value(preset_values["gamma"])
        
        # Update current mode label
        self.current_mode_label.set_markup(f"<b>Current Mode:</b> {self.current_light_mode}")
        
        # Update button styles
        parent = button.get_parent()
        for child in parent:
            child.remove_css_class("suggested-action")
        button.add_css_class("suggested-action")
        
        # Apply the settings
        self.on_apply_hyprsunset(None)
    
    def on_apply_hyprsunset(self, button):
        """Apply hyprsunset settings via CLI"""
        try:
            temperature = int(self.temp_row.get_value())
            gamma = int(self.gamma_row.get_value())
            
            # Kill existing hyprsunset process
            self.kill_process("hyprsunset")
            
            # Start new process
            if shutil.which("hyprsunset"):
                subprocess.Popen(["hyprsunset", "-t", str(temperature), "-g", str(gamma)])
                
                # If it's a custom setting, update current mode
                if button is not None:  # Manual application
                    self.current_light_mode = "Custom"
                    self.current_mode_label.set_markup(f"<b>Current Mode:</b> {self.current_light_mode}")
                
                # Save config
                self.save_config()
                
                self.show_message("Settings Applied", 
                                 f"Hyprsunset settings applied:\nTemperature: {temperature}K\nGamma: {gamma}%")
            else:
                self.show_message("Error", "hyprsunset not found in PATH", is_error=True)
        except Exception as e:
            self.show_message("Error", f"Failed to apply hyprsunset settings: {str(e)}", is_error=True)
    
    def on_restore_clicked(self, button):
        """Handle restore button click in GUI"""
        success = self.restore_settings()
        if success:
            # Refresh audio UI after restore
            self.current_volume, self.is_muted = self.get_current_volume()
            if hasattr(self, 'volume_scale'):
                self.volume_scale.set_value(self.current_volume)
                self.update_volume_status_label()
                self.update_mute_button()
                self.update_audio_info()
            
            self.show_message("Settings Restored", "Configuration restored from cache successfully!")
        else:
            self.show_message("Restore Failed", "Failed to restore settings from cache.", is_error=True)
    
    def kill_process(self, process_name):
        """Helper to kill a process by name"""
        try:
            subprocess.run(["pkill", "-x", process_name], check=False)
        except Exception as e:
            print(f"Error killing process {process_name}: {e}")
    
    def show_message(self, heading, body, is_error=False):
        """Helper to show a message dialog"""
        dialog = Adw.MessageDialog(
            transient_for=self.win,
            heading=heading,
            body=body
        )
        dialog.add_response("ok", "OK")
        if is_error:
            dialog.set_response_appearance("ok", Adw.ResponseAppearance.DESTRUCTIVE)
        dialog.present()

def main():
    parser = argparse.ArgumentParser(description='Hyprland Settings Manager')
    parser.add_argument('--restore', action='store_true', 
                       help='Restore settings from cache and exit')
    
    args = parser.parse_args()
    
    app = HyprlandSettingsApp()
    
    if args.restore:
        # CLI restore mode - don't show GUI
        app.load_config()
        success = app.restore_settings()
        exit(0 if success else 1)
    else:
        # Normal GUI mode
        app.run(None)

if __name__ == "__main__":
    main()
