#!/bin/bash
# Clean up
rm -rf iso root

# Download kernel, rootfs and text editor
wget "http://www.tinycorelinux.net/14.x/x86_64/release/distribution_files/vmlinuz64"
wget "http://www.tinycorelinux.net/14.x/x86_64/release/distribution_files/corepure64.gz"
git clone https://github.com/maksimKorzh/vici

# Create ISO folder
mkdir -p iso/boot/grub

# Install linux kernel
mv vmlinuz64 ./iso/boot/vmlinuz64

# Unpack rootfs
mkdir root
cd root
gunzip -c ../corepure64.gz | fakeroot -s ../corepure64.fakeroot cpio -i

# Install text editor
cp ../vici/src/vici ./usr/bin/vici

# Pack rootfs
find . | fakeroot -i ../corepure64.fakeroot cpio -o -H newc | gzip > ../iso/boot/coremod64.gz
cd ..

# More clean up
rm -f corepure64.gz corepure64.fakeroot
rm -rf root vici

# Create grub config file
echo "set default=0" >> ./iso/boot/grub/grub.cfg
echo "set timeout=10" >> ./iso/boot/grub/grub.cfg
echo "insmod efi_gop" >> ./iso/boot/grub/grub.cfg
echo "insmod font" >> ./iso/boot/grub/grub.cfg
echo "if loadfont /boot/grub/fonts/unicode.pf2" >> ./iso/boot/grub/grub.cfg
echo "then" >> ./iso/boot/grub/grub.cfg
echo "  insmod gfxterm" >> ./iso/boot/grub/grub.cfg
echo "  set gfxmode-auto" >> ./iso/boot/grub/grub.cfg
echo "  set gfxpayload=keep" >> ./iso/boot/grub/grub.cfg
echo "  terminal_output gfxterm" >> ./iso/boot/grub/grub.cfg
echo "fi" >> ./iso/boot/grub/grub.cfg
echo "menuentry 'linux' --class os {" >> ./iso/boot/grub/grub.cfg
echo "  insmod gzio" >> ./iso/boot/grub/grub.cfg
echo "  insmod part_msdos" >> ./iso/boot/grub/grub.cfg
echo "  linux /boot/vmlinuz64" >> ./iso/boot/grub/grub.cfg
echo "  initrd /boot/coremod64.gz" >> ./iso/boot/grub/grub.cfg
echo "}" >> ./iso/boot/grub/grub.cfg >> ./iso/boot/grub/grub.cfg

# Create ISO image
grub-mkrescue -o linux.iso iso/
