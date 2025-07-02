DESK_FILE=hyprsettings.desktop
BIN_FILE=hyprsettings
BIN_DIR=/usr/bin
BIN_APPLICATION_DIR=/usr/share/applications

prepare:
	chmod +x $(BIN_FILE)

install:
	@echo "sudo required."
	cp $(BIN_FILE) $(BIN_DIR)
	cp $(DESK_FILE) $(BIN_APPLICATION_DIR)

test:
	python $(BIN_FILE)

uninstall:
	rm $(BIN_DIR)/$(BIN_FILE)
	rm $(BIN_APPLICATION_DIR)/$(DESK_FILE)

help:
	@echo "Available targets:"
	@echo "  prepare    - Make the script executable"
	@echo "  install    - Install the application system-wide (requires sudo)"
	@echo "  uninstall  - Remove the application from the system (requires sudo)"
	@echo "  help       - Show this help message"
