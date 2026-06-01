# Comprehensive Guide to Your NixOS Configuration

> **Config name:** `nixos-config-fixed`
> **Tracked host:** `spectre` (HP Spectre x360, Intel x86_64)
> **Primary user:** `mystic`
> **Nixpkgs channel:** `nixos-unstable`
> **Flake inputs:** `nixpkgs` + `home-manager`

---

## Table of Contents

1. [Philosophy & Design Goals](#1-philosophy--design-goals)
2. [Repository Layout — The Big Picture](#2-repository-layout--the-big-picture)
3. [The Entry Point: `flake.nix`](#3-the-entry-point-flakenix)
4. [The Host Factory: `lib/mkHost.nix`](#4-the-host-factory-libmkhostnix)
5. [Core System Modules (`modules/core/`)](#5-core-system-modules-modulescore)
6. [Feature Modules (`modules/features/`)](#6-feature-modules-modulesfeatures)
7. [Role Profiles (`profiles/`)](#7-role-profiles-profiles)
8. [Host Configuration (`hosts/spectre/`)](#8-host-configuration-hostsspectre)
9. [User Account Layer (`users/mystic/`)](#9-user-account-layer-usersmystic)
10. [Home Manager: Core Programs (`home/mystic/core/`)](#10-home-manager-core-programs-homemysticcore)
11. [Home Manager: User Features (`home/mystic/features/`)](#11-home-manager-user-features-homemysticfeatures)
12. [Project Dev-Shell Templates (`templates/`)](#12-project-dev-shell-templates-templates)
13. [Lock File & Input Pinning (`flake.lock`)](#13-lock-file--input-pinning-flakelock)
14. [The `.gitignore`](#14-the-gitignore)
15. [Day-to-Day Workflow & Aliases](#15-day-to-day-workflow--aliases)
16. [How to Extend the Config](#16-how-to-extend-the-config)
17. [Architecture Diagram — Module Loading Order](#17-architecture-diagram--module-loading-order)

---

## 1. Philosophy & Design Goals

Your config follows several key architectural principles that are worth understanding up front, as they explain every structural decision throughout the repo.

### Separation of Concerns

The config is split into four distinct conceptual layers, each with its own directory and responsibility:

| Layer | Directory | What it expresses |
|---|---|---|
| **Core** | `modules/core/` | Things every NixOS host must have (boot, networking, Nix daemon, users) |
| **Features** | `modules/features/` | Optional capabilities (audio, Bluetooth, desktop, containers, etc.) |
| **Profiles** | `profiles/` | Curated bundles of features for a machine role (laptop, desktop, server) |
| **Hosts** | `hosts/` | Machine-unique facts (hostname, timezone, hardware, stateVersion) |

This means you never have to repeat yourself. Adding Bluetooth to a new machine is as simple as adding the `laptop` profile — not rewriting audio and Bluetooth config from scratch.

### Home Manager Is First-Class

Rather than managing user dotfiles manually or with a separate tool, your config integrates Home Manager directly as a NixOS module. The user's shell, editor, Git config, SSH config, aliases, and GUI packages are all declared in Nix and applied atomically alongside system changes. There is no drift between system and user state.

### Everything Is a Flake

Using `flake.nix` as the root means:
- All inputs (nixpkgs, home-manager) are **pinned** by `flake.lock` — you get reproducible builds across machines and time.
- The config is self-describing and composable with other flakes.
- Dev shells for your projects live as separate flakes that are **bootstrapped** from templates in this repo.

### Opinionated, Not Maximalist

The config makes deliberate choices (e.g., Podman instead of Docker, PipeWire instead of PulseAudio, `btop` instead of `htop`, `eza` instead of `ls`) and removes redundant tools with comments explaining why. This keeps the config legible and maintainable.

---

## 2. Repository Layout — The Big Picture

```
nixos-config-fixed/
│
├── flake.nix                    ← Entry point; registers hosts & templates
├── flake.lock                   ← Pinned input revisions
├── .gitignore
├── README.md
├── LICENSE
│
├── lib/
│   ├── default.nix              ← Exports mkHost
│   └── mkHost.nix               ← Host factory function
│
├── modules/
│   ├── core/                    ← Applied to EVERY host automatically
│   │   ├── default.nix
│   │   ├── boot.nix
│   │   ├── networking.nix
│   │   ├── nix.nix
│   │   └── users.nix
│   └── features/                ← Opt-in capabilities
│       ├── audio.nix
│       ├── bluetooth.nix
│       ├── desktop.nix
│       ├── dev.nix
│       ├── packages.nix
│       ├── power.nix
│       ├── printing.nix
│       └── virt.nix
│
├── profiles/
│   ├── laptop/default.nix       ← Bundles features for laptop machines
│   ├── desktop/default.nix      ← Bundles features for desktop machines
│   └── server/default.nix       ← Headless server profile
│
├── hosts/
│   └── spectre/
│       ├── default.nix          ← Machine-unique config (hostname, timezone, lid)
│       └── hardware-configuration.nix
│
├── users/
│   └── mystic/
│       ├── system.nix           ← NixOS user account declaration
│       └── home.nix             ← Home Manager entry point (username, stateVersion)
│
├── home/
│   └── mystic/
│       ├── default.nix
│       ├── core/
│       │   ├── default.nix
│       │   ├── git.nix
│       │   ├── ssh.nix
│       │   └── zsh.nix
│       └── features/
│           ├── default.nix      ← Auto-imports all .nix files in this dir
│           └── packages.nix
│
└── templates/
    ├── godot/flake.nix          ← Godot 4 dev shell
    └── gtk/flake.nix            ← GTK4 dev shell (Vala/Python/Rust)
```

---

## 3. The Entry Point: `flake.nix`

```
flake.nix
```

This is the root of the entire configuration. When you run `nh os switch`, Nix evaluates this file first and follows the graph of imports from here.

### Inputs

```nix
inputs = {
  nixpkgs.url     = "github:nixos/nixpkgs?ref=nixos-unstable";
  home-manager = {
    url = "github:nix-community/home-manager";
    inputs.nixpkgs.follows = "nixpkgs";
  };
};
```

Two inputs are declared:

- **`nixpkgs` (nixos-unstable):** The NixOS package collection and module system. Using `nixos-unstable` means you get the latest packages as they land in Nixpkgs, without waiting for a stable release cycle. This is the standard choice for desktop NixOS users who want recent software.
- **`home-manager`:** The user environment manager. The critical detail here is `inputs.nixpkgs.follows = "nixpkgs"` — this tells home-manager to use the exact same nixpkgs as the rest of the config, preventing two separate copies of nixpkgs from being downloaded and preventing subtle version mismatches between system and user packages.

### Outputs

The `outputs` function receives the resolved inputs and produces:

**`nixosConfigurations`** — A set of named NixOS systems. Currently one host:

```nix
spectre = mkHost {
  hostname = "spectre";
  system   = "x86_64-linux";
  profiles = [ "laptop" ];
  users    = [ "mystic" ];
};
```

This single call to `mkHost` expands into a complete `nixpkgs.lib.nixosSystem` invocation through the library function described in the next section.

**`templates`** — A registry of project bootstrapping flakes:

```nix
templates = {
  godot = { path = ./templates/godot; description = "..."; };
  gtk   = { path = ./templates/gtk;   description = "..."; };
};
```

Templates are usable via `nix flake init -t path:/home/mystic/nixos#godot` (locally) or `nix flake init -t github:yourusername/nixos-config#godot` (remotely). This lets any project directory get an instant, reproducible dev environment with a single command.

---

## 4. The Host Factory: `lib/mkHost.nix`

```
lib/
├── default.nix    ← Imports and re-exports mkHost
└── mkHost.nix     ← The factory function
```

`lib/mkHost.nix` is the most architecturally important file in the config. It is a **factory function** — a function that takes a description of a host and returns a fully assembled NixOS system. This is what makes adding a new machine trivial.

### What `mkHost` Accepts

```nix
{
  hostname,          # Must match a folder under hosts/
  system   ? "x86_64-linux",
  profiles ? [],     # Names of profiles/ folders to apply
  users    ? [],     # Names of users/ folders to wire in
  extraModules ? [], # Escape hatch for one-off modules
}
```

### The Seven-Stage Module Assembly

`mkHost` builds a flat list of NixOS modules in a specific, deliberate order:

**Stage 1 — Core modules (always present):**
```nix
[ ../modules/core ]
```
Every host, regardless of its role, gets the core modules unconditionally. This guarantees that the Nix daemon settings, bootloader, networking, and user baseline are always applied.

**Stage 2 — Host-specific config:**
```nix
++ [ ../hosts/${hostname} ]
```
This imports `hosts/spectre/default.nix` and `hosts/spectre/hardware-configuration.nix` (via that file's imports). This is where hardware-specific kernel modules, disk UUIDs, and machine-unique settings live.

**Stage 3 — Role profiles:**
```nix
++ map (p: ../profiles/${p}) profiles
```
Maps the `profiles` list (e.g., `[ "laptop" ]`) to `profiles/laptop/default.nix`. A profile imports the appropriate feature modules for that class of machine.

**Stage 4 — Home Manager NixOS module:**
```nix
++ [ home-manager.nixosModules.home-manager ]
```
Injects Home Manager's NixOS integration module, which adds the `home-manager.*` option namespace and wires HM activation into the system switch process.

**Stage 5 — User Home Manager configs:**
```nix
++ [{
  home-manager = {
    useGlobalPkgs   = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    users = builtins.listToAttrs (map (u: {
      name  = u;
      value = import ../users/${u}/home.nix;
    }) users);
  };
}]
```
This configures Home Manager itself:
- `useGlobalPkgs = true`: HM modules see the same pkgs as the system, avoiding a second nixpkgs evaluation.
- `useUserPackages = true`: Packages declared in `home.packages` are installed via the system profile rather than a user-local profile, making them available at the login shell before HM activates.
- `backupFileExtension = "backup"`: If HM wants to manage a file that already exists on disk, it backs it up as `filename.backup` instead of crashing.

**Stage 6 — System-level user accounts:**
```nix
++ map (u: ../users/${u}/system.nix) users
```
Imports `users/mystic/system.nix`, which declares the NixOS user account (groups, shell, description). This runs at the OS level (as root), separate from Home Manager's user-land config.

**Stage 7 — One-off extras:**
```nix
++ extraModules
```
An escape hatch for passing arbitrary extra modules at the `mkHost` call site in `flake.nix`, without having to create a new profile or module file for one-time experiments.

---

## 5. Core System Modules (`modules/core/`)

These modules are applied to **every single host** unconditionally. They represent the minimum viable NixOS configuration.

### `modules/core/boot.nix` — Bootloader & Silent Boot

**Bootloader:**
- Uses `systemd-boot` (not GRUB). Systemd-boot is simpler, faster, and more reliable on UEFI systems. It stores entries in the EFI System Partition.
- `graceful = true`: Systemd-boot will not hard-fail if the ESP is full — it degrades gracefully.
- `configurationLimit = 10`: Keeps the last 10 NixOS generations in the boot menu, preventing the ESP from filling up over time.
- `canTouchEfiVariables = true`: Allows NixOS to write the boot entry into the UEFI firmware's boot order.

**Kernel:**
- `linuxPackages_latest`: Tracks the latest stable kernel rather than the LTS kernel. Good for hardware compatibility, especially on recent laptops like the HP Spectre x360.

**Silent Boot:**
A set of kernel parameters and Plymouth suppress all boot messages, producing a clean splash screen experience:
- `quiet`, `splash`, `loglevel=3`: Minimize kernel log verbosity.
- `rd.systemd.show_status=false`, `rd.udev.log_level=3`, `udev.log_priority=3`: Silence systemd and udev output during initrd.
- `boot.shell_on_fail`: If boot fails (e.g., bad initrd), drops to a recovery shell rather than hanging silently. Safety net that doesn't compromise the quiet experience during normal boots.
- `boot.consoleLogLevel = 0` and `boot.initrd.verbose = false`: Suppress early kernel console output.

**Plymouth:**
- Theme: `bgrt` — uses the UEFI BGRT (Boot Graphics Resource Table) logo, which is the manufacturer's logo from the firmware. On an HP Spectre this means the HP logo appears during boot, giving a polished OEM-like experience without custom theming effort.

### `modules/core/networking.nix` — Network Management

```nix
networking.networkmanager.enable = true;
```

A single line that enables NetworkManager as the network stack. NetworkManager handles Wi-Fi, Ethernet, VPN, and connection profiles with a daemon that integrates with GNOME's network settings panel. The user is in the `networkmanager` group (declared in `users/mystic/system.nix`), which allows managing connections without root.

### `modules/core/nix.nix` — The Nix Daemon & Store

This is one of the most carefully tuned files in the config. It configures how the Nix daemon itself behaves.

**Package policy:**
- `allowUnfree = true`: Permits installing packages with non-free licenses (e.g., VS Code, Obsidian, Discord via Vesktop). Without this, those packages silently fail to build.
- `hardware.enableRedistributableFirmware = true`: Loads firmware blobs that are redistribution-permitted but not fully open source (Wi-Fi, Bluetooth, GPU microcode). Deliberately stops short of `hardware.enableAllFirmware` to avoid non-redistributable blobs.

**Experimental features:**
```nix
experimental-features = [ "nix-command" "flakes" ];
```
Enables the `nix` CLI (`nix build`, `nix develop`, etc.) and the flakes system. Both are stable in practice but still gated behind this flag in the official Nix release.

**Binary caches (substituters):**
```nix
substituters = [
  "https://cache.nixos.org"
  "https://nix-community.cachix.org"
];
```
Two binary caches are configured:
- `cache.nixos.org`: The official Nixpkgs binary cache. Pre-built derivations for the entire nixpkgs tree.
- `nix-community.cachix.org`: A community cache maintained by the nix-community org. Provides pre-built binaries for popular community tools like home-manager, nixfmt, nil (the LSP), and more. Without this, building tools like `nil` from source could take minutes.

**Store optimization:**
```nix
optimise.automatic = true;
```
The comment here is worth highlighting: `auto-optimise-store` (which deduplicates on every store write inline) was explicitly removed because it causes multi-second pauses mid-build. The replacement is `optimise.automatic`, which runs deduplication as a separate systemd timer — same space savings, zero build-time impact.

**Garbage collection:**
```nix
gc = {
  automatic = true;
  dates     = "weekly";
  options   = "--delete-older-than 30d";
};
```
Old generations are purged automatically once a week, deleting anything older than 30 days. The `nix-clean` shell alias (`nh clean all --keep 3`) provides an aggressive manual alternative that keeps only the last 3 generations.

**Nixpkgs pinning:**
```nix
registry.nixpkgs.flake = inputs.nixpkgs;
nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
```
This ensures that when you run `nix shell nixpkgs#some-tool` or reference `<nixpkgs>` anywhere, you get the exact same nixpkgs revision that the system was built with — not whatever nixpkgs happens to be on the channel at that moment. This is crucial for reproducibility.

### `modules/core/users.nix` — Sudo Policy

```nix
security.sudo.wheelNeedsPassword = true;
```

Members of the `wheel` group (including `mystic`) can use `sudo`, but must enter their password. This is the secure default — password-less sudo is not enabled.

---

## 6. Feature Modules (`modules/features/`)

Feature modules are opt-in capabilities. They are never applied directly to a host — they are always imported by a profile, which is then listed in `mkHost`. This keeps the dependency graph explicit.

### `modules/features/audio.nix` — PipeWire Audio Stack

The config uses PipeWire as the audio server, replacing both PulseAudio and JACK:

```nix
services.pipewire = {
  enable    = true;
  alsa.enable       = true;
  alsa.support32Bit = true;   # For 32-bit apps (Steam, Wine, etc.)
  pulse.enable      = true;   # PulseAudio compatibility layer
  jack.enable       = true;   # JACK compatibility for pro-audio / DAWs
  wireplumber = { ... };
};
```

PipeWire handles all three protocol families simultaneously:
- **ALSA:** Direct hardware access. 32-bit support is included for compatibility with legacy and gaming software.
- **PulseAudio emulation:** Allows any PulseAudio application to work transparently.
- **JACK emulation:** Low-latency audio for pro-audio applications, DAWs, or real-time audio tools.

**Bluetooth audio tuning via WirePlumber:**
```nix
"bluez5.roles" = [ "a2dp_sink" "a2dp_source" ];
"bluetooth.autoswitch-to-headset-profile" = false;
```
By default, connecting a Bluetooth headset triggers an automatic switch to the "headset" profile (HSP/HFP), which enables the microphone but degrades audio quality significantly (to 8–16 kHz mono). This config locks Bluetooth audio to the A2DP profile only, which provides stereo, high-quality audio. The microphone sacrifice is intentional — if you want the mic, you can manually switch profiles in the GNOME settings.

### `modules/features/bluetooth.nix` — Bluetooth

```nix
hardware.bluetooth = {
  enable      = true;
  powerOnBoot = true;
  settings.General = {
    Enable       = "Source,Sink,Media,Socket";
    Experimental = true;
  };
};
services.blueman.enable = true;
```

- `powerOnBoot = true`: The Bluetooth adapter is powered on at boot rather than requiring manual activation.
- `Experimental = true`: Enables BlueZ experimental features, which unlocks battery level reporting for supported devices (headphones, controllers, etc.) in GNOME's power panel.
- `blueman`: A Bluetooth manager applet that provides a system tray icon and device pairing GUI, complementing GNOME's built-in Bluetooth panel.

### `modules/features/desktop.nix` — GNOME & Display

```nix
services.xserver.enable            = true;
services.displayManager.gdm.enable = true;
services.desktopManager.gnome.enable = true;
```

The desktop stack is GNOME on GDM. Even though GNOME has moved to Wayland-first, `services.xserver.enable = true` is still required on NixOS because it wires up the Xorg infrastructure that GDM and GNOME depend on (for input device configuration, display settings, etc.), even when running a Wayland session.

**Touchpad & input:**
```nix
services.libinput.enable = true;
```
libinput handles touchpad, touchscreen, and pointer input. Enables natural scrolling, tap-to-click, and gesture detection.

**IIO sensors:**
```nix
hardware.sensor.iio.enable = true;
```
This is specific to convertible/tablet-form-factor laptops like the HP Spectre x360. IIO (Industrial I/O) sensor support enables the accelerometer, which drives auto-rotate. When you flip the Spectre into tablet mode, the display orientation follows.

**Flatpak:**
```nix
services.flatpak.enable = true;
```
Flatpak is enabled as a supplementary package source for software not in nixpkgs or that requires sandbox isolation (e.g., some proprietary apps). Flatpaks must still be installed manually via `flatpak install`; enabling the service just makes the infrastructure available.

**GNOME Extensions:**
```nix
environment.systemPackages = with pkgs; [
  gnomeExtensions.screen-rotate
  gnomeExtensions.blur-my-shell
  gnomeExtensions.dash-to-dock
  gnomeExtensions.appindicator
];
```
Four extensions are pre-installed at the system level:
- **screen-rotate**: Manual rotation controls for tablet mode (useful alongside the IIO auto-rotate).
- **blur-my-shell**: Adds blur behind the top bar, dash, and overview, giving a translucent glassmorphism effect.
- **dash-to-dock**: Converts GNOME's overview-only dash into a persistent dock, similar to macOS or Ubuntu's launcher.
- **appindicator**: Restores the system tray area, allowing apps like Blueman to show tray icons (GNOME removed the tray in GNOME 3.26; this extension brings it back).

**GNOME bloat removal:**
```nix
environment.gnome.excludePackages = with pkgs; [
  gnome-tour
  epiphany     # GNOME Web — Firefox is used instead
  geary        # GNOME Mail
  gnome-music
];
```
Four stock GNOME apps are removed. Firefox replaces GNOME Web; Obsidian/other tools replace GNOME Music; no mail client is installed system-wide (browser-based email is assumed).

### `modules/features/dev.nix` — Foreign Binary Support (nix-ld)

```nix
programs.nix-ld = {
  enable    = true;
  libraries = with pkgs; [
    stdenv.cc.cc.lib  # libstdc++
    zlib
    openssl
    libGL
    vulkan-loader
    xorg.libX11 xorg.libXcursor xorg.libXrandr xorg.libXi
    wayland
  ];
};
```

NixOS stores libraries in `/nix/store/...` paths, not the FHS-standard `/lib` and `/usr/lib`. Pre-compiled binaries (downloaded SDKs, proprietary tools, CI artifacts, game engines) try to load libraries from standard paths and fail with `No such file or directory` even when the library exists on the system.

`nix-ld` solves this by providing a dynamic linker shim at the standard ELF interpreter path (`/lib64/ld-linux-x86-64.so.2`) that redirects library resolution into the Nix store.

The libraries list pre-loads the most common ones that pre-compiled binaries need: the C++ standard library, zlib, OpenSSL, OpenGL/Vulkan (for GPU-accelerated tools and game engines), X11 (for X11-linked binaries under XWayland), and Wayland (for native Wayland apps).

### `modules/features/packages.nix` — Base System Packages

```nix
environment.systemPackages = with pkgs; [
  bash zsh git wget curl
  btop unzip zip
  pantum-driver
];
```

A minimal set of packages available system-wide to all users:
- **Shell tools:** `bash`, `zsh`, `git`, `wget`, `curl` — the essentials every user would expect.
- **`btop`**: A rich terminal system monitor (CPU, RAM, disk, network) with mouse support. `htop` was removed with the comment that btop is a strict superset.
- **Archive tools:** `unzip`, `zip`.
- **`pantum-driver`**: A printer driver, suggesting you have a Pantum printer.

Note: `tree` is omitted here because `eza --tree` (aliased as `tree` in the zsh config) provides the same functionality with color and icons.

### `modules/features/power.nix` — Power & Thermal Management

Three services work together to maximize battery life and thermals:

**auto-cpufreq:**
```nix
services.auto-cpufreq = {
  enable = true;
  settings = {
    battery  = { governor = "powersave"; turbo = "auto"; };
    charger  = { governor = "performance"; turbo = "auto"; };
  };
};
```
Automatically switches the CPU frequency governor based on power source. On battery → `powersave` (reduces clock speeds to conserve power). On charger → `performance` (allows full clock speeds). `turbo = "auto"` lets the daemon decide whether to enable Intel Turbo Boost based on system load and temperature, rather than always-on or always-off.

**fstrim:**
```nix
services.fstrim = { enable = true; interval = "weekly"; };
```
Runs TRIM on SSDs weekly. TRIM tells the SSD firmware which blocks are no longer in use, allowing it to erase them in the background. Without periodic TRIM, write performance on SSDs degrades over time as the firmware runs out of pre-erased blocks.

**thermald:**
```nix
services.thermald.enable = true;
```
Intel's thermal daemon monitors CPU temperature using DPTF (Dynamic Platform and Thermal Framework) data from the firmware and applies cooling policies before the kernel's own thermal throttling kicks in. On a thin ultrabook like the HP Spectre x360, this can meaningfully reduce fan noise and thermal throttling during sustained loads.

### `modules/features/printing.nix` — Network Printing

```nix
services.printing.enable = true;
services.avahi = {
  enable = true;
  nssmdns4 = true;
  openFirewall = true;
};
```

- **CUPS** (`services.printing`): The standard Linux printing system, required for any printing.
- **Avahi**: Implements mDNS/DNS-SD (the Bonjour protocol), which is how modern network printers advertise themselves on the local network. `nssmdns4` integrates mDNS hostname resolution into the system name resolver (so `.local` hostnames work). `openFirewall = true` automatically opens the UDP/5353 mDNS port in the firewall.

### `modules/features/virt.nix` — Containers (Podman)

```nix
virtualisation.podman = {
  enable = true;
  dockerCompat  = true;
  defaultNetwork.settings.dns_enabled = true;
};

environment.systemPackages = with pkgs; [
  podman-compose
  podman-tui
];
```

- **Podman** instead of Docker: Podman is daemonless (no root daemon running constantly), rootless by default (containers run as your user), and Docker-compatible at the API level. `dockerCompat = true` installs a `docker` shim that maps `docker` CLI commands to Podman, so any script or Compose file that uses `docker` works unchanged.
- **`dns_enabled = true`**: Enables DNS resolution between containers on the default network so containers can reach each other by name.
- **`podman-compose`**: A Python implementation of `docker-compose` that works with Podman.
- **`podman-tui`**: A full terminal UI for browsing images, containers, volumes, and pods — essentially `lazydocker` for Podman.

---

## 7. Role Profiles (`profiles/`)

Profiles are the **composition layer** between feature modules and hosts. Instead of each host importing features individually, a profile bundles the right features for a class of machine.

### `profiles/laptop/default.nix`

```nix
imports = [
  ../../modules/features/audio.nix
  ../../modules/features/bluetooth.nix
  ../../modules/features/desktop.nix
  ../../modules/features/dev.nix        # ← laptop only
  ../../modules/features/packages.nix
  ../../modules/features/power.nix      # ← laptop only
  ../../modules/features/printing.nix
  ../../modules/features/virt.nix
];
```

The laptop profile is the most complete profile — it includes everything including `dev.nix` (nix-ld for foreign binaries, useful for development on the go) and `power.nix` (battery management). No explicit power governor override is set here; `auto-cpufreq` from `power.nix` handles it dynamically.

### `profiles/desktop/default.nix`

```nix
imports = [
  audio bluetooth desktop packages printing virt
  # NOTICE: dev.nix and power.nix are NOT here
];

powerManagement.cpuFreqGovernor = "performance";
```

The desktop profile omits:
- `dev.nix`: Not included (could easily be added if you use the desktop for development).
- `power.nix`: No battery to manage on a desktop. Instead, the governor is hardcoded to `performance` since power draw is not a concern.

### `profiles/server/default.nix`

```nix
imports = [ packages virt ];  # No audio, bluetooth, desktop, power

services.xserver.enable = false;  # Headless

services.openssh = {
  enable = true;
  settings = {
    PasswordAuthentication       = false;
    PermitRootLogin              = "no";
    KbdInteractiveAuthentication = false;
  };
};

networking.firewall = {
  enable = true;
  allowedTCPPorts = [ 22 ];
};

system.autoUpgrade = {
  enable  = true;
  flake   = "github:CHANGEME/nixos-config";
  flags   = [ "--update-input" "nixpkgs" ];
  dates   = "04:00";
  randomizedDelaySec = "30min";
};
```

The server profile is the most minimal. Notable features:
- **SSH hardening**: Password auth and root login are both disabled. Only key-based authentication works. `KbdInteractiveAuthentication = false` disables challenge-response auth (including PAM-based prompts) as an additional lockdown.
- **Firewall**: Default-deny. Only port 22 (SSH) is open. Individual server hosts would add more ports via their `hosts/<name>/default.nix`.
- **Auto-upgrade**: Unattended upgrades from the GitHub flake at 4 AM, with a random 30-minute delay to prevent all servers hitting GitHub simultaneously. Uses `--update-input nixpkgs` to pull the latest nixpkgs on each run.

---

## 8. Host Configuration (`hosts/spectre/`)

The host layer is intentionally thin. It contains only information that is **unique to this specific physical machine**.

### `hosts/spectre/default.nix`

```nix
imports = [ ./hardware-configuration.nix ];

networking.hostName = "spectre";
time.timeZone       = "Asia/Singapore";

services.logind.settings = {
  Login = {
    HandleLidSwitch              = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked        = "ignore";
    HandlePowerKey               = "suspend";
  };
};

system.stateVersion = "25.05";
```

- **Hostname `spectre`**: Matches the folder name. This hostname is used by `mkHost` to locate `hosts/spectre/` and is set as the machine's network hostname.
- **Timezone `Asia/Singapore`**: UTC+8, no DST. This suggests you're based in Singapore or the surrounding region (which aligns with Karachi's location context — you may have set this intentionally or as a placeholder).
- **Lid behaviour:** All lid-switch events (on battery, on AC, docked) are set to `"ignore"`. This makes the Spectre x360 behave correctly in **tablet mode** — when the lid is fully rotated, the system would otherwise think it's closing and suspend. `HandlePowerKey = "suspend"` ensures the physical power button still suspends the machine.
- **`stateVersion = "25.05"`**: This is the NixOS version at install time. It must never be changed after initial setup — it gates certain migration behaviors in NixOS modules and does not mean the system is pinned to that release.

### `hosts/spectre/hardware-configuration.nix`

This file is generated by `nixos-generate-config` at install time. It contains:

**Kernel modules for initrd:**
```nix
boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
boot.kernelModules = [ "kvm-intel" ];
```
- `xhci_pci`: USB 3.x host controller (required for USB keyboard/input during early boot).
- `ahci`: SATA controller.
- `usb_storage`: USB mass storage (USB sticks, external drives).
- `rtsx_pci_sdmmc`: Realtek PCIe SD card reader driver.
- `kvm-intel`: Intel hardware virtualisation. Loads `kvm` and `kvm-intel` for running VMs and containers.

**Disk layout:**
```nix
fileSystems."/"    = { device = "/dev/disk/by-uuid/601b..."; fsType = "ext4"; };
fileSystems."/boot" = { device = "/dev/disk/by-uuid/8945..."; fsType = "vfat"; options = ["fmask=0077" "dmask=0077"]; };
swapDevices = [{ device = "/dev/disk/by-uuid/55485f..."; }];
```
- Root on ext4, boot (EFI System Partition) on vfat.
- The ESP is mounted with `fmask=0077` and `dmask=0077` — permissions 600 for files and 700 for directories, preventing other users from reading EFI boot files.
- A dedicated swap device (likely a swap partition) is configured.

**Platform:**
```nix
nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
```
The Intel CPU microcode updater is enabled, conditional on `enableRedistributableFirmware` (which is `true` in `modules/core/nix.nix`). Intel microcode updates fix CPU errata and security vulnerabilities.

---

## 9. User Account Layer (`users/mystic/`)

The user layer has a clean split between two concerns: the OS-level account (runs as root/system) and the Home Manager config (runs as the user).

### `users/mystic/system.nix` — NixOS Account

```nix
users.users.mystic = {
  isNormalUser = true;
  description  = "Mystic";
  extraGroups  = [ "wheel" "networkmanager" "podman" ];
  shell        = pkgs.zsh;
};

programs.zsh.enable = true;
```

- **`wheel`**: Grants sudo access (gated behind password by `modules/core/users.nix`).
- **`networkmanager`**: Allows managing network connections without root.
- **`podman`**: Allows using Podman in rootless mode without sudo.
- **`shell = pkgs.zsh`**: Sets zsh as the login shell. The extra `programs.zsh.enable = true` line is required at the system level for zsh to be registered as a valid login shell in `/etc/shells` — without it, the shell assignment would silently fail.

### `users/mystic/home.nix` — Home Manager Root

```nix
home.username      = "mystic";
home.homeDirectory = "/home/mystic";
home.stateVersion  = "25.05";

imports = [
  ../../home/mystic/core
  ../../home/mystic/features
];
```

This is the root file that Home Manager starts from for the `mystic` user. It sets the three mandatory HM options (username, home directory, stateVersion) and delegates all actual configuration to the `home/` directory tree. The separation between `users/mystic/home.nix` (identity/metadata) and `home/mystic/` (the actual config) is intentional — it makes the home config portable and testable independently.

---

## 10. Home Manager: Core Programs (`home/mystic/core/`)

Core programs are tools that are always active, regardless of what features are enabled.

### `home/mystic/core/git.nix` — Git Configuration

```nix
programs.git = {
  enable = true;
  settings = {
    user = { name = "Mystic"; email = "..."; };
    init.defaultBranch     = "main";
    pull.rebase            = true;
    push.autoSetupRemote   = true;
    rerere.enabled         = true;
    column.ui              = "auto";
    branch.sort            = "-committerdate";
  };
  extraConfig = {
    diff.algorithm   = "histogram";
    merge.conflictstyle = "zdiff3";
  };
  aliases = {
    lg   = "log --oneline --graph --decorate --all";
    st   = "status -sb";
    wip  = "commit -am 'WIP'";
    undo = "reset HEAD~1 --mixed";
  };
};
```

Several non-default settings deserve explanation:

- **`pull.rebase = true`**: `git pull` rebases instead of merging, keeping a linear history. You avoid the "Merge branch 'main' of ..." noise commits.
- **`push.autoSetupRemote = true`**: Automatically sets the upstream tracking branch on first push, so `git push` works without needing `--set-upstream` on a new branch.
- **`rerere.enabled = true`**: "Reuse Recorded Resolution." Git remembers how you resolved merge conflicts and automatically applies the same resolution if it sees the identical conflict again. Very useful on long-lived feature branches.
- **`column.ui = "auto"`**: Displays certain outputs (like `git branch`) in multi-column format when the terminal is wide enough.
- **`branch.sort = "-committerdate"`**: `git branch` lists branches ordered by most recently committed to first — not alphabetically. Far more useful in practice.
- **`diff.algorithm = "histogram"`**: More accurate diff algorithm than the default Myers algorithm. Better at identifying moved blocks, producing more readable diffs.
- **`merge.conflictstyle = "zdiff3"`**: Enhanced conflict markers that include the common ancestor's version of the conflicting block, making conflicts significantly easier to resolve.

### `home/mystic/core/ssh.nix` — SSH Client

```nix
programs.ssh = {
  enable = true;
  addKeysToAgent = "yes";
  matchBlocks."github.com" = {
    hostname     = "github.com";
    identityFile = "~/.ssh/id_ed25519";
  };
};
```

- **`addKeysToAgent = "yes"`**: Keys are automatically loaded into `ssh-agent` on first use, so you only type the passphrase once per session.
- **GitHub match block**: Explicitly specifies the Ed25519 key for GitHub. Ed25519 is preferred over RSA — it's smaller, faster, and has better security properties.

### `home/mystic/core/zsh.nix` — Shell Environment

This is the richest core configuration file. It sets up the complete interactive shell experience.

**Zsh base:**
```nix
programs.zsh = {
  enable              = true;
  dotDir              = "${config.xdg.configHome}/zsh";  # ~/.config/zsh
  enableCompletion    = true;
  autosuggestion.enable = true;
  syntaxHighlighting.enable = true;
  oh-my-zsh = {
    enable  = true;
    plugins = [ "git" "sudo" "docker" "extract" ];
  };
};
```

- `dotDir` points to `~/.config/zsh` (XDG Base Directory compliant), keeping the home directory clean. The zshrc won't litter the `$HOME`.
- **`autosuggestion`**: Fish-style inline suggestions based on command history. Accept with the binding below.
- **`syntaxHighlighting`**: Syntax-highlights commands as you type — valid commands in green, invalid in red.
- **Oh-My-Zsh plugins:**
  - `git`: Git status in the prompt + many `g*` aliases.
  - `sudo`: Double-tap `Escape` to prepend `sudo` to the current command.
  - `docker`: Docker completions.
  - `extract`: Universal `extract <archive>` command that handles zip, tar, gz, bz2, xz, etc.

**Shell aliases:**
```nix
shellAliases = {
  # NixOS management
  nix-switch = "nh os switch ~/nixos/ -h spectre";
  nix-test   = "nh os test ~/nixos/ -h spectre";
  nix-clean  = "nh clean all --keep 3";
  conf       = "cd ~/nixos";
  vconf      = "nvim ~/nixos";

  # Better defaults
  ls   = "eza --icons --group-directories-first";
  ll   = "eza --icons --group-directories-first -l";
  la   = "eza --icons --group-directories-first -la";
  tree = "eza --tree --icons";
  cat  = "bat";

  # Git shortcuts
  g  = "git";
  gs = "git st";
  gl = "git lg";
};
```

Key design decisions:
- `nix-switch` uses `nh` (a Nix helper tool) which provides progress bars, diff output before switching, and a nicer UX than raw `nixos-rebuild`. The `-h spectre` flag explicitly targets the `spectre` host configuration.
- `ls`, `ll`, `la`, `tree` are all replaced with `eza` equivalents. `eza` shows icons, colours file types, and groups directories first.
- `cat` is replaced with `bat` — a `cat` clone with syntax highlighting, line numbers, and git diff integration.
- `zoxide` is **not** aliased to `cd` (by design). The comment explains why: aliasing `cd` to `z` breaks scripts that source `.zshrc` and then use `cd` with POSIX semantics. You use `z <partial-dir-name>` explicitly for smart jumping.

**Key bindings:**
```nix
initContent = ''
  bindkey '^ ' autosuggest-accept   # Ctrl+Space to accept autosuggestion
  bindkey '^f' fzf-file-widget      # Ctrl+F for fzf file picker
'';
```

**Starship prompt:**
```nix
programs.starship.settings = {
  add_newline        = false;
  line_break.disabled = true;      # Single-line prompt
  nix_shell.symbol   = "❄️ ";
  git_branch.symbol  = " ";
  directory.truncation_length = 4;
};
```

A compact single-line prompt. Shows a snowflake icon when inside a `nix-shell` or `nix develop` environment, a git branch icon with the branch name, and truncates directory paths to 4 components.

**Shell utilities:**

| Tool | Config | Purpose |
|---|---|---|
| `fzf` | `--height 40%`, border, right-side preview at 50% | Fuzzy finder for files, history, git |
| `eza` | enabled | Modern `ls` replacement |
| `bat` | TwoDark theme | Syntax-highlighting `cat` |
| `zoxide` | enabled | Smart `cd` that learns from your history |
| `direnv` + `nix-direnv` | enabled | Auto-activates Nix dev shells on `cd` |

`direnv` with `nix-direnv` is the critical glue for the dev-shell template workflow. When you `cd` into a project with an `.envrc` containing `use flake`, the shell automatically activates the flake's devShell, putting all the project's tools on your `$PATH`. When you leave the directory, it deactivates. No manual `nix develop` needed.

---

## 11. Home Manager: User Features (`home/mystic/features/`)

### Auto-Import System (`home/mystic/features/default.nix`)

```nix
imports =
  let
    files = builtins.readDir ./.;
    validFiles = lib.filterAttrs
      (name: type:
        (type == "regular" || type == "symlink") &&
        (lib.hasSuffix ".nix" name) &&
        (name != "default.nix")
      ) files;
  in
  lib.mapAttrsToList (name: type: ./. + "/${name}") validFiles;
```

This is a clever metaprogramming pattern. Instead of maintaining an explicit import list (which must be updated every time you add a file), `default.nix` dynamically scans the directory at evaluation time and imports every `.nix` file it finds (except itself). To add a new user feature, just drop a new `.nix` file in `home/mystic/features/` — no changes to `default.nix` required.

### `home/mystic/features/packages.nix` — User GUI Packages

```nix
home.packages = with pkgs; [
  # Terminal & editors
  ghostty helix micro

  # Development tools
  gnupg nixfmt-rfc-style nil

  # System info / eye candy
  fastfetch hyfetch cava cavalier

  # Desktop apps
  pear-desktop vesktop rmpc firefox obsidian parabolic

  # GNOME utilities
  gnome-tweaks refine

  # Containers / Windows compat
  winboat vscode
];
```

A tour of the notable choices:

- **`ghostty`**: A GPU-accelerated terminal emulator. Fast, feature-rich, and native-feel.
- **`helix`**: A modal text editor (Kakoune-inspired, not Vim-inspired). Built-in LSP, tree-sitter syntax highlighting, multiple selections. The primary editor.
- **`micro`**: A simple, nano-like terminal editor. Good for quick edits without the learning curve.
- **`nil`**: The Nix language server. Powers autocomplete, go-to-definition, and diagnostics for `.nix` files in editors that support LSP.
- **`nixfmt-rfc-style`**: The official Nix formatter (RFC 166 style). Used to keep `.nix` files consistently formatted.
- **`gnupg`**: GNU Privacy Guard for signing commits, encrypting files, and managing keys.
- **`fastfetch`**: A system info displayer (like neofetch, but significantly faster).
- **`hyfetch`**: A pride-flag themed system info displayer (neofetch fork).
- **`cava`** / **`cavalier`**: Terminal and GUI audio visualizers — react to music in real time.
- **`pear-desktop`**: A desktop application (likely a community/AUR-style package).
- **`vesktop`**: An unofficial Discord client with better Wayland support, system tray integration, and support for Vencord plugins.
- **`rmpc`**: A terminal MPD (Music Player Daemon) client.
- **`obsidian`**: A note-taking and knowledge management app (Markdown-based, local vault).
- **`parabolic`**: A GUI front-end for `yt-dlp` — downloads video/audio from YouTube and other sites.
- **`gnome-tweaks`**: GNOME Tweaks for fine-grained GNOME customization (fonts, window buttons, etc.).
- **`refine`**: A GNOME extension settings manager (replaces the older GNOME Extensions app).
- **`winboat`**: A tool for running Windows applications (likely a Wine/Proton wrapper or similar).
- **`vscode`**: Visual Studio Code (unfree). Works alongside Helix — VS Code for heavy GUI-based editing, Helix for terminal work.

---

## 12. Project Dev-Shell Templates (`templates/`)

Templates are flakes registered in `flake.nix` that can be used to bootstrap new project directories. They are self-contained — each has its own `flake.nix` with its own inputs and devShells.

### `templates/godot/flake.nix` — Godot 4 Game Dev

This template provides a complete Godot 4 development environment:

| Package | Purpose |
|---|---|
| `godot_4` | The Godot editor and runtime |
| `godot_4-export-templates` | Pre-built templates for exporting to Windows, Linux, Web, Android, etc. |
| `gdtoolkit_4` | `gdformat` (GDScript formatter) + `gdlint` (GDScript linter) |
| `imagemagick` | Texture conversion, icon generation, asset pipeline |
| `ffmpeg` | Audio/video processing for game assets |
| `optipng` | PNG compression for smaller asset files |
| `butler` | itch.io command-line uploader for publishing builds |
| `just` | A command runner (Makefile alternative with nicer syntax) |

The shell hook prints the Godot version on activation, confirming the environment is active.

**Usage:**
```bash
mkdir ~/projects/my-game && cd ~/projects/my-game
nix flake init -t path:/home/mystic/nixos#godot
echo "use flake" > .envrc && direnv allow
# The full Godot dev environment is now active in this directory
```

### `templates/gtk/flake.nix` — GTK4 App Dev (Multi-Language)

This template is notably more sophisticated — it provides **three separate devShells** for the three common GTK development languages, plus a default shell:

**Common GTK dependencies** (shared by all shells):
```
gtk4, glib, gobject-introspection, pkg-config, desktop-file-utils, glib.dev, libadwaita
```
`libadwaita` is included for all variants, targeting the modern GNOME HIG widget set.

**`devShells.vala`** (default):
```
vala, meson, ninja
```
Vala is GObject-native and compiles to C. The standard build system for GNOME apps.

**`devShells.python`**:
```
python3 + pygobject3 + pycairo, blueprint-compiler
```
`blueprint-compiler` processes `.blp` files — a cleaner, type-checked alternative to raw GtkBuilder XML for UI definitions.

**`devShells.rust`**:
```
rustup, cargo, rust-analyzer, clippy
```
Plus a `PKG_CONFIG_PATH` environment variable pointing to GTK4 and libadwaita dev headers, which `gtk-rs` (the Rust GTK bindings) needs at build time.

**Usage:**
```bash
nix develop           # Default (Vala)
nix develop .#python  # Python/PyGObject
nix develop .#rust    # Rust/gtk-rs
```

---

## 13. Lock File & Input Pinning (`flake.lock`)

```json
{
  "nixpkgs": {
    "locked": {
      "rev": "80e4adbcf8992d3fd27ad4964fbb84907f9478b0",
      "narHash": "sha256-C2TjvwYZ...",
      "lastModified": 1768886240
    }
  },
  "home-manager": {
    "locked": {
      "rev": "ec0247a7a19f641595c24ac1ea4df6461d1cdb36",
      "narHash": "sha256-MlqzCJbc...",
      "lastModified": 1769015285
    }
  }
}
```

`flake.lock` pins every input to an exact Git commit hash and a content hash (`narHash`). This means:
- Two machines with the same `flake.lock` get **identical builds** regardless of when they build.
- If nixpkgs updates a package in a way that breaks something, your system is unaffected until you explicitly run `nix flake update`.
- The `narHash` cryptographically verifies the download hasn't been tampered with.

**To update inputs:** `nix flake update` (updates all) or `nix flake update nixpkgs` (updates one).

---

## 14. The `.gitignore`

```gitignore
*.backup          # Home Manager backup files (created when HM backs up existing dotfiles)
.direnv/          # direnv's cached shell environments (large, reproducible on demand)
result            # Symlink created by `nix build`
result-*          # Multiple build results
```

Clean and minimal. The `*.backup` entries are important — when Home Manager takes over a dotfile that already exists, it renames it to `filename.backup`. Those should stay local, not be committed.

---

## 15. Day-to-Day Workflow & Aliases

### Rebuilding the System

| Alias | Command | When to use |
|---|---|---|
| `nix-switch` | `nh os switch ~/nixos/ -h spectre` | Apply changes and activate immediately |
| `nix-test` | `nh os test ~/nixos/ -h spectre` | Build and activate without making it the boot default |
| `nix-clean` | `nh clean all --keep 3` | Free disk space, keep last 3 generations |

`nh` (Nix Helper) wraps `nixos-rebuild` with a diff view showing what packages are added/removed/updated before you commit to a switch, plus nicer progress bars.

### Editing the Config

| Alias | What it does |
|---|---|
| `conf` | `cd ~/nixos` — jump to the config directory |
| `vconf` | `nvim ~/nixos` — open the config in Neovim |

### Git Workflow

| Alias | Expands to |
|---|---|
| `g` | `git` |
| `gs` | `git status -sb` (short, branch-aware) |
| `gl` | `git log --oneline --graph --decorate --all` |
| `git wip` | `git commit -am 'WIP'` — quick save |
| `git undo` | `git reset HEAD~1 --mixed` — undo last commit, keep changes staged |
| `git lg` | Same as `gl` — the pretty log |

### Dev Shell Workflow

```bash
# Bootstrap a new project
mkdir ~/projects/my-app && cd ~/projects/my-app
nix flake init -t path:/home/mystic/nixos#godot   # or #gtk

# Auto-activate (one-time setup per project)
echo "use flake" > .envrc && direnv allow

# Now every `cd` into the project auto-activates the shell
# and every `cd` out deactivates it
```

---

## 16. How to Extend the Config

### Adding a New Host

1. Create `hosts/<name>/default.nix` with at minimum:
   ```nix
   { ... }: {
     imports = [ ./hardware-configuration.nix ];
     networking.hostName = "<name>";
     time.timeZone       = "Your/Timezone";
     system.stateVersion = "25.05";
   }
   ```
2. Copy or generate `hosts/<name>/hardware-configuration.nix` via `nixos-generate-config`.
3. Register in `flake.nix`:
   ```nix
   nixosConfigurations.<name> = mkHost {
     hostname = "<name>";
     system   = "x86_64-linux";
     profiles = [ "laptop" ];  # or "desktop" or "server"
     users    = [ "mystic" ];
   };
   ```

### Adding a New Feature Module

1. Create `modules/features/<feature>.nix`.
2. Import it in the relevant profile(s) under `profiles/`.
3. No changes to `flake.nix` or `mkHost.nix` needed.

### Adding a New User Feature (Home Manager)

Just drop a new `.nix` file into `home/mystic/features/`. The auto-import system in `home/mystic/features/default.nix` picks it up automatically on the next `nix-switch`.

### Adding a New Template

1. Create `templates/<name>/flake.nix`.
2. Register in `flake.nix` under `templates`:
   ```nix
   templates.<name> = {
     path        = ./templates/<name>;
     description = "What this shell provides";
   };
   ```

### Adding a New User

1. Create `users/<username>/system.nix` and `users/<username>/home.nix`.
2. Create `home/<username>/` with core and features sub-trees.
3. Add `"<username>"` to the `users` list in the relevant `mkHost` call in `flake.nix`.

---

## 17. Architecture Diagram — Module Loading Order

The following diagram shows how `mkHost { hostname="spectre"; profiles=["laptop"]; users=["mystic"]; }` assembles the final NixOS system configuration:

```
flake.nix
└── mkHost { hostname="spectre", profiles=["laptop"], users=["mystic"] }
    │
    ├── [Stage 1] modules/core/
    │   ├── boot.nix          (systemd-boot, Plymouth, latest kernel)
    │   ├── networking.nix    (NetworkManager)
    │   ├── nix.nix           (daemon settings, caches, GC, pinning)
    │   └── users.nix         (sudo policy)
    │
    ├── [Stage 2] hosts/spectre/
    │   ├── default.nix       (hostname, timezone, lid behaviour, stateVersion)
    │   └── hardware-configuration.nix (kernel modules, disk UUIDs, microcode)
    │
    ├── [Stage 3] profiles/laptop/
    │   ├── modules/features/audio.nix      (PipeWire + WirePlumber + BT audio)
    │   ├── modules/features/bluetooth.nix  (BlueZ + blueman)
    │   ├── modules/features/desktop.nix    (GNOME, GDM, extensions, Flatpak, IIO)
    │   ├── modules/features/dev.nix        (nix-ld + common libraries)
    │   ├── modules/features/packages.nix   (base system packages)
    │   ├── modules/features/power.nix      (auto-cpufreq, fstrim, thermald)
    │   ├── modules/features/printing.nix   (CUPS + Avahi)
    │   └── modules/features/virt.nix       (Podman + compose + tui)
    │
    ├── [Stage 4] home-manager.nixosModules.home-manager
    │   (HM NixOS integration: useGlobalPkgs, useUserPackages, backupFileExtension)
    │
    ├── [Stage 5] home-manager.users.mystic → users/mystic/home.nix
    │   ├── home/mystic/core/
    │   │   ├── git.nix       (Git settings, aliases, histogram diff)
    │   │   ├── ssh.nix       (SSH agent, GitHub key)
    │   │   └── zsh.nix       (zsh + OMZ + starship + fzf + eza + bat + zoxide + direnv)
    │   └── home/mystic/features/   ← auto-imported
    │       └── packages.nix        (ghostty, helix, vesktop, obsidian, firefox, ...)
    │
    ├── [Stage 6] users/mystic/system.nix
    │   (NixOS account: groups wheel+networkmanager+podman, shell=zsh)
    │
    └── [Stage 7] extraModules (empty for spectre)
```

This layered approach means every piece of configuration has a single, obvious home. Hardware facts live in `hosts/`, capability groupings live in `profiles/`, reusable building blocks live in `modules/`, and personal dotfiles live in `home/`.
