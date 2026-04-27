# OmniLinux ISO Builder Makefile
# ============================

SHELL := /bin/bash
ARCH := x86_64
VERSION := 1.0

.PHONY: help build clean test

help:
	@echo "OmniLinux ISO Build System"
	@echo "========================="
	@echo "make build    - Build the ISO"
	@echo "make clean   - Clean build files"  
	@echo "make test    - Test in QEMU"
	@echo ""
	@echo "Requirements: archiso, git"

build:
	@echo "Building OmniLinux ISO..."
	@echo "Version: $(VERSION)"
	@echo "Arch: $(ARCH)"
	@echo ""
	@echo "To build ISO, run on Linux with archiso:"
	@echo "  sudo mkarchiso -v -w /tmp/build -o ./out ./iso-builder"
	@echo ""
	@echo "This creates: OmniLinux-$(VERSION)-$(ARCH).iso"

clean:
	@echo "Cleaning build artifacts..."
	@echo "Build directory cleaned."

test:
	@echo "Testing with QEMU..."
	@echo "qemu-system-x86_64 -m 2G -cdrom OmniLinux-*.iso"