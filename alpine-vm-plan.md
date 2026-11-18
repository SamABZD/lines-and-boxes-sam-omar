# Alpine VM build and verification

Implemented and verified on 14 November 2026. The supplied VM is an Alpine Linux 3.24.4 root filesystem in a compressed initramfs, booted by its official x86_64 virt kernel using QEMU 8.2.2. It uses 128 MiB RAM, one emulated CPU, no network, and no disk. No graphical desktop is installed.

## Launch the supplied image

Install `qemu-system-x86_64` in Linux/WSL, then from the project root run:

```sh
sh vm/run.sh
```

The full deliverable ZIP supplies the generated images in `build/vm/`. The script can also take an alternate image-directory path. Press Ctrl+A, then X to close QEMU. The VGA console and serial console each start a game. The serial console is used by the supplied launcher.

The complete ZIP is available from the private repository's [Sprint 1 release](https://github.com/SamABZD/lines-and-boxes-sam-omar/releases/tag/sprint-1).

The first interactive screen is the two-player game; firmware/kernel output can precede it. There is no username or password prompt. Game exit or completion starts another game. A cold boot starts a fresh board.

## Rebuild from source

The image builder needs x86_64 Linux, root privileges for its isolated account setup, GNU Make, a static-capable C toolchain, `tar`, `cpio`, `gzip`, `sha256sum`, and curl or wget:

```sh
sudo sh vm/build-image.sh
```

It downloads pinned assets from the [official Alpine download service](https://alpinelinux.org/downloads/), checks `vm/sources.sha256`, builds the C game with `make static`, extracts a temporary Alpine root filesystem, adds the ordinary `dots` account, copies the game and startup files, and creates `initramfs.cpio.gz`. The rootfs checksum matches Alpine's published `.sha256`; the kernel is pinned to the SHA-256 recorded from the HTTPS release asset. Temporary rootfs contents are removed when the builder exits. Output hashes are recorded in `build/vm/SHA256SUMS`.

The static application is compiled with Ubuntu GCC/glibc and runs without shared-library dependencies in Alpine. This is not a claim that compilation happened inside Alpine. Source remains portable C11 and can also be compiled with Alpine's native compiler.

## Startup path

`vm/init` mounts device, process, and sys filesystems, prints the Alpine release, and executes BusyBox init. `vm/inittab` starts the application directly on ttyS0 and tty1, using `su` to run it as the ordinary `dots` account. The `respawn` action restarts the game after exit. This supplies a controlling terminal without any login prompt or a background service trying to read console input.

The image builder modifies its temporary root filesystem and generated build files, not the host's login configuration. The VM is diskless; there is no saved game or persistent user data requirement in Sprint 1.

## Evidence actually captured

- `evidence/alpine-boot-session.log`: first cold boot, automatic launch, malformed input rejection, B completing a box, and B retaining the turn.
- `evidence/alpine-boot.png`: genuine QEMU VGA screendump showing the initial board and prompt without a login screen.
- `evidence/alpine-full-game.log`: second cold boot, all 49 edges, final 10-10 draw, and a new game automatically starting.
- `evidence/vm-build.txt` and `evidence/vm-checks.txt`: build output, environment, and verification summary.
- `evidence/alpine-current-boot.log`: 18 November recheck of automatic startup, all 49 moves, the 10-10 draw, and automatic restart with the supplied release images.

## Conventional persistent VM alternative

If a course demo requires a conventional disk-installed Alpine VM instead, install Alpine normally, build/install the game under `/opt/dots-and-boxes/`, and follow Alpine's [TTY autologin guide](https://wiki.alpinelinux.org/wiki/TTY_Autologin) using an ordinary `dots` account. Configure only tty1 for automatic login and have that account's login profile execute the game. That alternative has not been configured or tested here; the supplied diskless QEMU VM is the implementation that was verified.
