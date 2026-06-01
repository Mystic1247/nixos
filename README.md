# nixos-config

Multi-host NixOS flake with per-project dev shells.

| Host | Profile | Users | Hardware |
|------|---------|-------|----------|
| `spectre` | laptop | mystic | HP Spectre x360 (Intel, x86_64) |

---

## Structure

```
.
├── flake.nix                        # Hosts + template registry
├── flake.lock
│
├── lib/
│   ├── default.nix
│   └── mkHost.nix                   # Host factory
│
├── profiles/
│   ├── laptop/default.nix           # GUI + audio + BT + power + dev
│   ├── desktop/default.nix          # GUI + audio + BT
│   └── server/default.nix           # Headless + SSH + firewall
│
├── hosts/
│   └── spectre/
│       ├── default.nix
│       └── hardware-configuration.nix
│
├── modules/
│   ├── core/                        # Always applied to every host
│   │   ├── boot.nix
│   │   ├── networking.nix
│   │   ├── nix.nix
│   │   └── users.nix
│   └── features/
│       ├── audio.nix
│       ├── bluetooth.nix
│       ├── desktop.nix
│       ├── dev.nix                  # nix-ld for foreign binaries
│       ├── packages.nix
│       ├── power.nix
│       ├── printing.nix
│       └── virt.nix
│
├── templates/                       # Project bootstrapping templates
│   ├── godot/flake.nix              # Godot 4 dev shell
│   └── gtk/flake.nix               # GTK4 dev shell (Vala / Python / Rust)
│
├── users/
│   └── mystic/
│       ├── system.nix
│       └── home.nix
│
└── home/
    └── mystic/
        ├── core/   (git, ssh, zsh + direnv/zoxide/fzf)
        └── features/
```

---

## Dev Shells — Quick Start

### Bootstrap a new project

```bash
# From your config repo (while developing templates locally):
mkdir ~/projects/my-game && cd ~/projects/my-game
nix flake init -t path:/home/mystic/nixos#godot

# Once pushed to GitHub:
nix flake init -t github:yourusername/nixos-config#godot
```

### Activate automatically (recommended)

```bash
echo "use flake" > .envrc
direnv allow
# Shell now auto-activates whenever you cd into this directory
```

### Activate manually

```bash
nix develop          # default shell
nix develop .#rust   # named shell (GTK template has vala / python / rust)
```

### Add it to an existing project

Just copy the relevant `flake.nix` from `templates/` into your project root and run `direnv allow`.

---

## Common Commands

| Alias | What it does |
|-------|-------------|
| `nix-switch` | Build and activate new system config |
| `nix-test` | Build and test without switching |
| `nix-clean` | GC — keep last 3 generations |
| `conf` | `cd ~/nixos` |
| `vconf` | Open config in Neovim |

---

## Adding a New Host

1. `mkdir hosts/<name>`
2. Add `hardware-configuration.nix` (from `nixos-generate-config`)
3. Add `hosts/<name>/default.nix` with hostname + timezone + stateVersion
4. Register in `flake.nix`: `<name> = mkHost { hostname = "<name>"; profiles = [...]; users = [...]; };`

## Adding a New Template

1. `mkdir templates/<name>`
2. Write `templates/<name>/flake.nix`
3. Register in `flake.nix` under `templates`:
```nix
templates.<name> = {
  path        = ./templates/<name>;
  description = "What this shell provides";
};
```
