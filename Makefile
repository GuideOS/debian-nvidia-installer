PREFIX := /usr
DESTDIR := 
VERSION := $(shell cat VERSION)

.PHONY: all install clean build-deb

all:
	@echo "Available targets:"
	@echo "  install     - Install the application"
	@echo "  build-deb   - Build Debian package"
	@echo "  clean       - Clean build artifacts"

install:
	# Create directories
	install -d $(DESTDIR)$(PREFIX)/bin
	install -d $(DESTDIR)$(PREFIX)/lib/debian-nvidia-installer
	install -d $(DESTDIR)$(PREFIX)/lib/debian-nvidia-installer/translate
	install -d $(DESTDIR)$(PREFIX)/lib/debian-nvidia-installer/tui
	install -d $(DESTDIR)$(PREFIX)/share/applications
	install -d $(DESTDIR)$(PREFIX)/share/debian-nvidia-installer
	install -d $(DESTDIR)$(PREFIX)/share/icons/hicolor/scalable/apps
	
	# Install main executable with version replacement
	sed 's/^declare -g SCRIPT_VERSION="[^"]*"/declare -g SCRIPT_VERSION="$(VERSION)"/' usr/bin/debian-nvidia-installer > $(DESTDIR)$(PREFIX)/bin/debian-nvidia-installer
	chmod 755 $(DESTDIR)$(PREFIX)/bin/debian-nvidia-installer
	
	# Install library files
	install -m 644 usr/lib/debian-nvidia-installer/*.sh $(DESTDIR)$(PREFIX)/lib/debian-nvidia-installer/
	install -m 644 usr/lib/debian-nvidia-installer/translate/*.sh $(DESTDIR)$(PREFIX)/lib/debian-nvidia-installer/translate/
	install -m 644 usr/lib/debian-nvidia-installer/tui/*.sh $(DESTDIR)$(PREFIX)/lib/debian-nvidia-installer/tui/
	
	# Install desktop file and theme
	install -m 644 usr/share/applications/debian-nvidia-installer.desktop $(DESTDIR)$(PREFIX)/share/applications/
	install -m 644 usr/share/debian-nvidia-installer/theme.dialogrc $(DESTDIR)$(PREFIX)/share/debian-nvidia-installer/
	
	# Install icon
	install -m 644 usr/share/icons/hicolor/scalable/apps/debian-nvidia-installer.svg $(DESTDIR)$(PREFIX)/share/icons/hicolor/scalable/apps/

build-deb:
	dpkg-buildpackage -us -uc -b

clean:
	rm -rf debian/debian-nvidia-installer/
	rm -f ../debian-nvidia-installer_*.deb
	rm -f ../debian-nvidia-installer_*.changes
	rm -f ../debian-nvidia-installer_*.buildinfo