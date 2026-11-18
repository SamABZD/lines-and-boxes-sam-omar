#!/bin/sh
set -eu
project=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
image=${1:-"$project/build/vm"}
if [ ! -f "$image/vmlinuz-virt" ] || [ ! -f "$image/initramfs.cpio.gz" ]; then
    printf 'Build the VM image first: sudo sh vm/build-image.sh\n' >&2
    exit 1
fi
exec qemu-system-x86_64 -machine accel=tcg -m 128 -smp 1 \
    -kernel "$image/vmlinuz-virt" -initrd "$image/initramfs.cpio.gz" \
    -append 'console=tty0 console=ttyS0,115200 quiet loglevel=3' \
    -nographic -no-reboot -nic none
