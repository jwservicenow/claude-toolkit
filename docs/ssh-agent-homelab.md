# SSH Agent Key Management for Claude Access to Homelab Hosts

A shell function alias for loading a passphrase-protected SSH key into the macOS SSH agent with a configurable time-to-live, so access expires automatically without manual cleanup.

## The Problem

If you load an SSH key with `ssh-add` and no time limit, it stays in the agent indefinitely — through sleep, wake, and long sessions. For homelab or sensitive infrastructure access, that's a wider window than necessary.

## Solution Setup

Add these to `~/.zshrc`:

```zsh
# SSH agent helpers — load id_homelab for N hours, default 2
ssh-up() {
  local hours=${1:-2}
  ssh-add -t $(( hours * 3600 )) ~/.ssh/id_homelab && \
    echo "id_homelab loaded — expires in ${hours}h (at $(date -v +${hours}H '+%I:%M %p MDT'))"
}
alias ssh-down='ssh-add -d ~/.ssh/id_homelab && echo "id_homelab removed from agent"'
alias ssh-status='ssh-add -l'
```

Then reload your shell config for the changes to take effect in the current terminal:

```bash
source ~/.zshrc
```

## Usage

```bash
ssh-up        # load for 2h (default)
ssh-up 4      # load for 4h
ssh-down      # remove immediately
ssh-status    # show loaded keys
```

Example output:
```
id_homelab loaded — expires in 4h (at 05:45 PM MDT)
```

## Key Setup

Generate the key pair on your Mac:

```bash
ssh-keygen -t ed25519 -C "your-label" -f ~/.ssh/id_homelab
```

You will be prompted for a passphrase — use one. This is what `ssh-up` asks for when loading the key.

Copy the public key to each host you want to access:

```bash
ssh-copy-id -i ~/.ssh/id_homelab.pub user@your-host
```

The function loads `~/.ssh/id_homelab` — that's the **private key**. The public key (`id_homelab.pub`) is what you install on the hosts; the private key stays on your Mac and is what the agent holds.

## Notes

- Replace `id_homelab` with your key filename
- `date -v` is macOS-specific; on Linux use `date -d "+${hours} hours"`
- If `ssh-down` reports "agent refused operation" the key was already evicted — not an error
- **Common failure:** `Permission denied (publickey)` on SSH = the window expired, not a key problem. Run `ssh-up` and retry.
