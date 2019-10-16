function RefreshPath { AddToPath ""; }
function AddToPath {
    # ------------ Examples ------------
    # AddToPath "
    #     /snap/bin
    #     ~/bin
    #     ~/lib
    # "


    function ifPathFileExists { $(FileExists "$PathLocation") && echo "$(ReadFile "$PathLocation")" || echo ""; }


    local NewPath="$1"
    local SmlOldPath="$(SmlSplit ":" "$PATH")"

    local SuPath="$(sudo su -c 'echo "$PATH"')"
    local SuOldPath="$(SmlSplit ":" "$SuPath")"


    NewPath="$NewPath"$'\n'"$(ifPathFileExists)"
    NewPath="$(CutLines_Empty "$NewPath")"
    NewPath="$(SmlTrim "$NewPath")"

    NewPath="$(SwitchDirSymbols "$NewPath")"
    NewPath="$(ListDir "$NewPath" "D")"
    NewPath="$(CutLines_Empty "$NewPath")"
    NewPath="$(SmlTrim "$NewPath")"

    NewPath="$(RemoveFolderSlash "$NewPath")"
    NewPath="$(SmlMerge "$NewPath" "$SuOldPath" "$SmlOldPath")"
    NewPath="$(CutLines_Empty "$NewPath")"
    NewPath="$(SmlTrim "$NewPath")"
    NewPath="$(SmlJoin ":" "$NewPath")"


    PATH="$NewPath"
    sudo su -c "PATH="$NewPath""
}


function refresh { RefreshShell; }
function Refresh { RefreshShell; }
function RefreshShell {

    case "$(RunningShell)" in
    "BASH") source "$HOME/.bashrc";;
    "ZSH") source "$HOME/.zshrc";;
    esac
}


function DconfSettings {
    # ------------ Examples ------------
    # > Upload:
    # DconfSettings U "/org/gnome/shell/extensions/"
    # > Download:
    # DconfSettings D "/org/gnome/shell/extensions/"


    local loadingWay="$(echo "$(UCase "$1")")"
    local settings="$2"


    loadingWay="${loadingWay: 0:1}"


    while IFS= read -r location; do
        [[ "$(Left 1 "$location")" != "/" ]] && location="/$location"
        [[ "$(Right 1 "$location")" != "/" ]] && location="$location/"

        name=$(echo "$location" | tr "/" ".")
        name="${name: 1:-1}"


        mkdir -p -m 777 "$rjSetup/Backup/Dconf/"


        if [[ "$loadingWay" == "D" ]]; then dconf dump "$location" > "$rjSetup/Backup/Dconf/$name.txt"
        elif [[ "$loadingWay" == "U" ]]; then dconf load "$location" < "$rjSetup/Backup/Dconf/$name.txt"
        else echo "dconfSettings can NOT Understand what ya mean by this: $1"
        fi
    done <<< "$settings"
}


function IsAdmin { HasSudo; }
function IsRoot { [[ $EUID -ne 0 ]] && echo false || echo true; }


function HasSudo {
    echo $(echo "$?") > /dev/null

    [ $? -eq 0 ] && echo true || echo false;
}
function SudoAccess {
    echo $(echo "$?") > /dev/null

    if [ $? -eq 0 ]; then
    # exit code of sudo-command is 0
    echo "has_sudo__pass_set"
    elif echo $prompt | grep -q '^sudo:'; then
    echo "has_sudo__needs_pass"
    else
    echo "no_sudo"
    fi
}


function PrintFunction { declare -f "$1"; }


function FuncName {
    # which of the Elements on the arrays below inside the Switch/Case statement have one Increment of +1 in the Element, cuz that array shows every Current Function and the Function right above this "FuncName" is the Function that we're Asking for the Name

    case "$(RunningShell)" in
    "BASH") echo "${FUNCNAME[1]}";;
    "ZSH") echo "$funcstack[2]";;
    esac
}


function RunningShell {
    if $(IsNotEmpty "$BASH_VERSION"); then echo "BASH"; return; fi
    if $(IsNotEmpty "$ZSH_VERSION"); then echo "ZSH"; return; fi
}
function RunningDesktop {
    local desktopsList="$(SmlTrim "$(CutLines_Empty "
    GNOME
    KDE
    XFCE
    ")")"


    while IFS= read -r desktop; do
    if $(IsDesktop "$desktop"); then echo "$desktop"; return; fi
    done <<< "$desktopsList"

    echo "Current Desktop Is NOT Detectable"
}
function IsDesktop {
    local tmpDesktop="$(Trim "$(UCase "$1")")";
    local currentDesktop="$XDG_CURRENT_DESKTOP"

    $(Contains "$tmpDesktop" "$currentDesktop") && echo true || echo false
}


function GenerateDistroVars {
    OS=""
    VER=""

    if [ -f /etc/os-release ]; then
        # freedesktop.org and systemd
        . /etc/os-release
        OS=$NAME
        VER=$VERSION_ID
    elif type lsb_release >/dev/null 2>&1; then
        # linuxbase.org
        OS=$(lsb_release -si)
        VER=$(lsb_release -sr)
    elif [ -f /etc/lsb-release ]; then
        # For some versions of Debian/Ubuntu without lsb_release command
        . /etc/lsb-release
        OS=$DISTRIB_ID
        VER=$DISTRIB_RELEASE
    elif [ -f /etc/debian_version ]; then
        # Older Debian/Ubuntu/etc.
        OS=Debian
        VER=$(cat /etc/debian_version)
    elif [ -f /etc/SuSe-release ]; then
        # Older SuSE/etc.
        ...
    elif [ -f /etc/redhat-release ]; then
        # Older Red Hat, CentOS, etc.
        ...
    else
        # Fall back to uname, e.g. "Linux <version>", also works for BSD, etc.
        OS=$(uname -s)
        VER=$(uname -r)
    fi
}


function InjectLib {
    local allShellFiles="$(CutLines_Empty "$(SmlTrim "$1")")"


    function ShellLacksLib {
        local shellFile="$1"
        local shellContent


        if $(FileNotExists "$shellFile"); then echo false; return;fi
        shellContent="$(ReadFile "$shellFile")"

        if $(ContainsAny "$shellContent" "source \"$HOME/bin/$LibName\"" "source \"\$HOME/bin/$LibName\"");
        then echo false; else echo true; fi
    }


    while IFS= read -r shell; do
    if $(ShellLacksLib "$shell"); then AddCodeBlock_Bottom "$shell" "source \"\$HOME/bin/$LibName\"" "$LibName"; fi
    done <<< "$allShellFiles"
}