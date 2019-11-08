#!/bin/bash
LibName="bright-bash"
ExecutablesDir="$HOME/bin"
BashLibPath="$HOME/bin/$LibName"

DIR=""
LibFullPath=""


# Getting Original Library's Directory
[[ ! -d "$ExecutablesDir" ]] && mkdir -m 777 "$ExecutablesDir"

if [[ -f "$BashLibPath" ]]; then LibFullPath="$(readlink -f "$BashLibPath")"
elif [[ "$BASH_SOURCE" != "" ]]; then LibFullPath="$BASH_SOURCE"
else LibFullPath="$0"
fi
[[ "${LibFullPath: 0:1}" == "." ]] && LibFullPath="$PWD${LibFullPath: 1}"


DIR="$(dirname "$LibFullPath")"

# Creating the "$HOME/bin/bright-bash" LINK
sudo ln -sf "$LibFullPath" "$BashLibPath"


source "$DIR/variables.sh"


# Sources Every File inside "./Scripts"
filesToSource="$(find "$DIR/Scripts/" -type f)"
while IFS= read -r file; do source "$file"; done <<< "$filesToSource"

# Generating "OS" and "VER" Distro Variables
GenerateSystemVars
# Injecting Bright Bash Library to Any Shell
InjectLib "
$HOME/.bashrc
$HOME/.zshrc
"


# Local Extra Functions & Variables
LocalExtraLib="$HOME/lib/Bash/Extra"
CreateFile_IfNotExists "$LocalExtraLib/lib.sh" "\"$BashScriptHeader\""
source "$LocalExtraLib/lib.sh"
