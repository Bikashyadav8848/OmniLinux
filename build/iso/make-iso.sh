#!/bin/bash
# Run this on a Linux system with genisoimage/xorriso installed
ISO_FILE="omnilinux-1.0-alpha-full-x86_64.iso"

if command -v xorriso &>/dev/null; then
    xorriso -as mkisofs \
        -iso-level 3 \
        -full-iso9660-filenames \
        -eltorito-catalog boot.catalog \
        -eltorito-boot boot/syslinux/bios.img \
        -no-emul-boot \
        -boot-load-size 4 \
        -eltorito-alt-boot \
        -efi-boot efiboot/EFI/boot/bootx64.efi \
        -no-emul-boot \
        -appendPartition 2 efi -m efi \
        -iso-level 2 \
        -o "${ISO_FILE}" \
        "../build/iso-work"
elif command -v genisoimage &>/dev/null; then
    genisoimage \
        -l -r -J -V "OMNILINUX" \
        -b boot/syslinux/bios.img -no-emul-boot \
        -c boot.catalog \
        -o "${ISO_FILE}" \
        "../build/iso-work"
else
    echo "Install genisoimage or xorriso to create bootable ISO"
    exit 1
fi
echo "ISO created: ${ISO_FILE}"
