#!/bin/bash
LibName="bright-bash"
ExecutablesDir="$HOME/bin"
BashLibPath="$HOME/bin/$LibName"
DIR=""
LibFullPath=""


# Getting Original Library's Directory
[[ ! -d "$ExecutablesDir" ]] && mkdir -m 777 "$ExecutablesDir"
[[ -f "$BashLibPath" ]] && LibFullPath="$(readlink -f "$BashLibPath")" || LibFullPath="$0"
DIR="$(dirname "$LibFullPath")"
# Creating the "$HOME/bin/bright-bash" LINK
sudo ln -sf "$LibFullPath" "$BashLibPath"


source "$DIR/variables.sh"


# Sources Every File inside "./Scripts"
filesToSource="$(find "$DIR/Scripts/" -type f)"
while IFS= read -r file; do source "$file"; done <<< "$filesToSource"

# Generating "OS" and "VER" Distro Variables
GenerateDistroVars
# Adding Every Folder under "./FileAsFunction" to $PATH
AddToPath "$DIR/FileAsFunction/**"
# Injecting Bright Bash Library to Any Shell
InjectLib "
$HOME/.bashrc
$HOME/.zshrc
"