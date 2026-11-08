# NixOS configuration

One flake for all of my machines: **t480**, **spectre** and **nasher** (Dell Chromebook).

## How it fits together

Every machine is built from four layers, assembled by `lib/mkHost.nix`:

```
modules/core/        always applied: bootloader, Nix settings, base CLI tools, ...
hosts/<hostname>/    this machine: hardware config + its unique quirks
profiles/<role>.nix  a role = a list of features (laptop, desktop, server)
users/<name>/        the account (system.nix) and its Home Manager config (home/)
```

```
flake.nix            inputs + the list of machines
lib/mkHost.nix       builds one machine from the layers above
overlays/            package overlays (helium, freesmlauncher)
modules/
  core/              baseline for every host
  features/          opt-in building blocks (audio, gnome, niri, printing, ...)
profiles/
  workstation.nix    shared graphical base (not used directly)
  laptop.nix         workstation + power management + lid/power-key defaults
  desktop.nix        workstation + performance governor      (no host yet)
  server.nix         headless, key-only SSH, auto-upgrade    (no host yet)
hosts/
  t480/  spectre/  nasher/
users/mystic/
  system.nix         login, groups, shell
  home/              Home Manager: shell/ (fish, prompt, tools), desktop/, git, ssh
```

Rule of thumb for where something goes: needed on every machine → `modules/core`;
a capability some machines have → `modules/features` (and list it in a profile);
true for exactly one machine → that host's `default.nix`; a personal setting → `users/mystic/home`.

## Daily use

The shell has these abbreviations (they expand as you type):

| Type          | Runs                    |
| ------------- | ----------------------- |
| `nix-switch`  | `nh os switch`          |
| `nix-test`    | `nh os test`            |
| `nix-clean`   | `nh clean all --keep 3` |
| `conf`/`hconf`| `cd ~/nixos` / open it in helix |

`nh` finds this repo through `programs.nh.flake` (set in `users/mystic/system.nix`)
and builds the configuration whose flake name equals the machine's hostname.
Weekly clean-up of old generations is automatic (`modules/core/nix.nix`).

Format all Nix files with `nix fmt`.

## Adding things

**A machine**
1. `mkdir hosts/<name>` and put `hardware-configuration.nix` (from `nixos-generate-config`) in it,
   plus a `default.nix` that imports it and sets `system.stateVersion`.
2. Add `<name> = mkHost { hostname = "<name>"; profiles = [ ... ]; users = [ ... ]; };` to `flake.nix`.
   The name *is* the hostname.

**A feature**: create `modules/features/<name>.nix`, then add `"<name>"` to a profile
(`profiles/workstation.nix` for graphical machines) or import it from a single host.

**A user**: copy `users/mystic`, then add the name to `users = [ ... ]` on the hosts that need it.

## Shell: fish

The login shell is fish (`users/mystic/system.nix`). root and system scripts still use bash,
because fish is not POSIX-compatible. User config is in `users/mystic/home/shell/`.

Built-in fish features that replaced zsh plugins: autosuggestions (accept with `→` or
`Ctrl+Space`), syntax highlighting, completions, `Alt+S` to prepend `sudo`.
`Ctrl+F` opens the fzf file picker. `extract <archive>` unpacks common archive types.

Leftovers from the zsh setup can be deleted once fish works for you:
`~/.config/zsh`, `~/.zsh_history`, `~/.cache/oh-my-zsh`.

See `docs/REVIEW.md` for what was reviewed, fixed and what is still open.
