# ⚡ Bright Bash

This is an open source bash library to write scripts with more ease, achieving this by converting commands to more human like syntax.

## Installation

```bash
mkdir "$HOME/lib"
git glone https://github.com/RJHimself/Bright-Bash "$HOME/lib"
source "$HOME/lib/Bright-Bash"
```

## Examples

### Checking If a File Exists

```bash
# Bright Bash:
FileExists "$HOME/.bashrc"
# Vanilla Bash
[[ -f "$HOME/.bashrc" ]] && echo true || echo false
```
