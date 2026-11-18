#!/bin/sh
set -eu

project=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
output=${1:-"$project/build/vm"}
cache=${ALPINE_CACHE:-"$project/build/alpine-downloads"}
release=3.24.4
base=https://dl-cdn.alpinelinux.org/alpine/v3.24/releases/x86_64
rootfs=alpine-minirootfs-$release-x86_64.tar.gz

if [ "$(id -u)" -ne 0 ]; then
    printf 'Run the VM image builder as root; it creates an isolated Alpine account.\n' >&2
    exit 1
fi
if [ "$(uname -m)" != x86_64 ]; then
    printf 'This VM builder targets x86_64 Linux.\n' >&2
    exit 1
fi
for tool in make cc tar cpio gzip sha256sum chroot; do
    command -v "$tool" >/dev/null || { printf 'Missing tool: %s\n' "$tool" >&2; exit 1; }
done
mkdir -p "$output" "$cache"
output=$(CDPATH= cd -- "$output" && pwd)
cache=$(CDPATH= cd -- "$cache" && pwd)

fetch() {
    if [ ! -f "$cache/$2" ]; then
        if command -v curl >/dev/null 2>&1; then
            curl -fL "$1" -o "$cache/$2"
        else
            wget -O "$cache/$2" "$1"
        fi
    fi
}
fetch "$base/$rootfs" "$rootfs"
fetch "$base/netboot/vmlinuz-virt" vmlinuz-virt
(cd "$cache" && sha256sum -c "$project/vm/sources.sha256")
make -C "$project" static

stage=$(mktemp -d)
trap 'rm -rf "$stage"' EXIT HUP INT TERM
tar -xzf "$cache/$rootfs" -C "$stage"
mkdir -p "$stage/opt/dots-and-boxes"
cp "$project/build/static/dots_and_boxes" "$stage/opt/dots-and-boxes/"
cp "$project/vm/init" "$stage/init"
cp "$project/vm/inittab" "$stage/etc/inittab"
chmod 755 "$stage/init" "$stage/opt/dots-and-boxes/dots_and_boxes"
printf '/opt/dots-and-boxes/dots_and_boxes\n' >> "$stage/etc/shells"
chroot "$stage" /usr/sbin/adduser -D -h /home/dots -s /opt/dots-and-boxes/dots_and_boxes dots
(cd "$stage" && find . -print0 | cpio --null -o --format=newc --owner=0:0 2>/dev/null | gzip -n -9) \
    > "$output/initramfs.cpio.gz"
cp "$cache/vmlinuz-virt" "$output/vmlinuz-virt"
(cd "$output" && sha256sum vmlinuz-virt initramfs.cpio.gz > SHA256SUMS)
printf 'Built Alpine %s VM image in %s\n' "$release" "$output"
