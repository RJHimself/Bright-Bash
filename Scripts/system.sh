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


    local loadingWay="$1"
    local settings="$(SmlTrim "$2")"
    local toDir="$(SwitchDirSymbols_Folder "$3")"


    while IFS= read -r location; do
        if [[ "$(Right 1 "$location")" == "/" ]];
        then DconfSettings_Load "$loadingWay" "$location" "$toDir"
        else DconfSettings_Only "$loadingWay" "$location" "$toDir"
        fi
    done <<< "$settings"
}
function DconfSettings_Load {
    local loadingWay="$1"
    local location="$(Trim "$2")"
    local toDir="$(Trim "$3")"

    local name="$(echo "$location" | tr "/" ".")"


    [[ "$(Left 1 "$location")" != "/" ]] && location="/$location"
    [[ "$(Right 1 "$location")" != "/" ]] && location="$location/"
    name="${name: 1:-1}"


    if $(IsDownload "$loadingWay"); then dconf dump "$location" > "$toDir""$name.txt"
    elif $(IsUpload "$loadingWay"); then dconf load "$location" < "$toDir""$name.txt"
    else echo "dconfSettings can NOT Understand what ya mean by this: $loadingWay"
    fi
}
function DconfSettings_Only {
    local loadingWay="$1"
    local location="$(Trim "$2")"
    local toDir="$(Trim "$3")"

    local name="$(echo "$location" | tr "/" ".")"


    [[ "$(Left 1 "$location")" != "/" ]] && location="/$location"
    name="${name: 1:-1}"


    if $(IsDownload "$loadingWay"); then WriteFile "$toDir""$name.txt" "$(dconf read "$location")"
    elif $(IsUpload "$loadingWay"); then dconf write "$location" "$(ReadFile "$toDir""$name.txt")"
    else echo "dconfSettings can NOT Understand what ya mean by this: $loadingWay"
    fi
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


function AutoLogin {
    local state="$1"
    local loginFile

    # ------------{ Bypass Login }------------
    # Here are the Different Types of DMs (Display Managers)
    # GDM
    # LightDM
    # SDDM
    # LXDM
    # XDM


    case "$(RunningDesktop)" in
    "GNOME")
        loginFile="/etc/gdm3/custom.conf"

        if $(IsON "$state"); then
        sudo sed --in-place "s/.*AutomaticLoginEnable =.*/AutomaticLoginEnable=true/" "$loginFile"
        sudo sed --in-place "s/.*AutomaticLogin =.*/AutomaticLogin=$USER/" "$loginFile"
        elif $(IsOFF "$state"); then
        sudo sed --in-place "s/.*AutomaticLoginEnable=.*/# AutomaticLoginEnable=true/" "$loginFile"
        sudo sed --in-place "s/.*AutomaticLogin=.*/# AutomaticLogin=$USER/" "$loginFile"
        fi
    ;;
    "KDE")
        loginFile="/etc/sddm.conf"

        if $(IsON "$state"); then
        sudo kwriteconfig5 --file "$loginFile" --group Autologin --key Session "plasma.desktop"
        sudo kwriteconfig5 --file "$loginFile" --group Autologin --key User "$USER"
        elif $(IsOFF "$state"); then
        sudo kwriteconfig5 --file "$loginFile" --group Autologin --key Session "plasma"
        sudo kwriteconfig5 --file "$loginFile" --group Autologin --key User ""
        fi
    ;;
    "XFCE")
    ;;
    esac
}
function Reboot {
    reboot
    systemctl reboot
    sudo reboot
    sudo systemctl reboot
}
function AutoStartup {
    local file="$1"
    local fileName="$(GetFileName_NoExtension "$file")"
    local tmpAutoStartup="$(TempFile)"
    local varGroup="$@"

    local fileContent="$(SmlTrim "[Desktop Entry]
    Version=1.0
    Exec=sh -c 'bash "$varGroup"'
    Icon=
    Name=$fileName
    GenericName=$fileName
    Comment=$fileName
    Encoding=UTF-8
    Terminal=true
    Type=Application
    Categories=Application;Network;")"


    echo "$fileContent" > "$tmpAutoStartup"
    mv "$tmpAutoStartup" "$AutoStartupPath/$fileName.desktop"


    # Make it Executable
    sudo chmod +x "$AutoStartupPath/$fileName.desktop"
    # Remove All User Restrictions to this File
    sudo chmod -R 775 "$AutoStartupPath/$fileName.desktop"
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
    # # EXAMPLE:
    # case "$(RunningDesktop)" in
    # "GNOME")
    # ;;
    # "KDE")
    # ;;
    # "XFCE")
    # ;;
    # esac


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
function GetDesktopVersion {
    local version
    local versionLocation


    case "$(RunningDesktop)" in
    "GNOME")
        versionLocation="/usr/share/gnome/gnome-version.xml"
        version="$(ReadXMLValue "platform" "$versionLocation")"
        version="$version"".""$(ReadXMLValue "minor" "$versionLocation")"
        version="$version"".""$(ReadXMLValue "micro" "$versionLocation")"
    ;;
    "KDE")
    ;;
    "XFCE")
    ;;
    esac


    echo "$version"
}


function GenerateSystemVars {
    GenerateDistroVars
    GenerateComputerSpecsVars
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
function GenerateComputerSpecsVars {
    RAM=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    # Getting Only the GB Values
    RAM=$(Reverse $RAM)
    RAM=${RAM: 6}
    RAM=$(Reverse $RAM)
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
