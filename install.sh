#!/bin/bash
DESK_FILE=hyprsettings.desktop
BIN_FILE=hyprsettings
BIN_DIR=/usr/bin
BIN_APPLICATION_DIR=/usr/share/applications

cat << EOF
==========================
| Hyprsettings Installer |
==========================
EOF

guess_void() {
	echo "found void proccesing with void_fucntion"
	void_fucntion
}

guess_arch() {
	echo "found arch proccesing with arch_function"
	arch_function
}

guess_fedora() {
	echo "found fedora proccesing with fedora_function"
	fedora_function
}

guess_distro_and_call_relevant_install_function() {
	if [ -f /etc/void-release ]; then
		guess_void
	elif [ -f /etc/arch-release ]; then
		guess_arch
	elif [ -f /etc/fedora-release ]; then
		guess_fedora
	else
		echo "Unsupported distribution. Please install manually."
		exit 1
	fi
}

repo_setup() {
	echo "Alert: The script Going plug additional repository because some of Depends Not"
	echo "doesnt avilable in Void repos officially."
	echo repository=https://raw.githubusercontent.com/Makrennel/hyprland-void/repository-x86_64-glibc | sudo tee /etc/xbps.d/hyprland-void.conf
}

#From now function for Each distro end up calling install_files function
void_fucntion() {
	repo_setup
	sudo xbps-install -S hyprsunset python3 python3-gobject gtk4 libadwita swaybg cargo
}

arch_function() {
	sudo pacman -S --needed hyprsunset python python-gobject gtk4 libadwaita swaybg cargo
}

fedora_function() {
	sudo dnf install hyprsunset python3 python3-gobject gtk4 libadwaita swaybg cargo
}

install_files() {
	chmod +x $BIN_FILE
	sudo cp $BIN_FILE $BIN_DIR
	sudo cp $DESK_FILE $BIN_APPLICATION_DIR
}

main() {
	guess_distro_and_call_relevant_install_function
	install_files
}

main
