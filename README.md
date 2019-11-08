# ⚡ Bright Bash

This is an open source bash library to write scripts with more ease, achieving this by converting commands to more human like syntax.

## Installation

```bash
mkdir -p "$HOME/lib/bash"
git clone https://github.com/RJHimself/Bright-Bash "$HOME/lib/bash/bright-bash"
source "$HOME/lib/bash/bright-bash/lib.sh"
```

## Examples

### Checking If a File Exists

```bash
# Bright Bash:
FileExists "$HOME/.bashrc"
# Vanilla Bash
[[ -f "$HOME/.bashrc" ]] && echo true || echo false
```
