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
    NewPath="$(SmlCutLines_Empty "$NewPath")"
    NewPath="$(SmlTrim "$NewPath")"

    NewPath="$(SwitchDirSymbols "$NewPath")"
    NewPath="$(ListDir "$NewPath" "D")"
    NewPath="$(SmlCutLines_Empty "$NewPath")"
    NewPath="$(SmlTrim "$NewPath")"

    NewPath="$(RemoveFolderSlash "$NewPath")"
    NewPath="$(SmlMerge "$NewPath" "$SuOldPath" "$SmlOldPath")"
    NewPath="$(SmlCutLines_Empty "$NewPath")"
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


function pause { read -s -n 1 -p "Press any key to continue…"; }
function Pause { pause; }


function GetScriptPath {
    # This Function NEEDS to get passed the "$0" value like this:
    # GetScriptPath "$0"
    # Otherwise it just doesn't work at all ... XD

    if $(IsEmpty "$1"); then return; fi


    local possiblePath="$1"
    local scriptPath


    if [[ "$BASH_SOURCE" != "" ]]; then scriptPath="$BASH_SOURCE"
    else scriptPath="$possiblePath"
    fi


    [[ "${scriptPath: 0:1}" == "." ]] && scriptPath="$PWD${scriptPath: 1}"


    echo "$scriptPath"
}


function CleanTrash { sudo rm -rf "$HOME/.local/share/Trash/"*; }
function CleanTemp { sudo rm -rf "/tmp/"*; }
function CleanTmp { CleanTemp; }


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
    local location="$(SwitchDirSymbols_Folder "$2")"
    local toDir="$(SwitchDirSymbols_Folder "$3")"

    local name="$(ReplaceChar "/" "." "$location")"
    name="$(Exclude_FirstLast 1 "$name")"


    CreateFolder_IfNotExists "$toDir"


    if $(IsDownload "$loadingWay"); then dconf dump "$location" > "$toDir""$name.txt"
    elif $(IsUpload "$loadingWay"); then dconf load "$location" < "$toDir""$name.txt"
    else echo "dconfSettings can NOT Understand what ya mean by this: $loadingWay"
    fi
}
function DconfSettings_Only {
    local loadingWay="$1"
    local location="$(SwitchDirSymbols_File "$2")"
    local toDir="$(SwitchDirSymbols_Folder "$3")"

    local name="$(ReplaceChar "/" "." "$location")"
    name="$(Exclude_First 1 "$name")"


    CreateFolder_IfNotExists "$toDir"


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
        sudo sed --in-place "s/.*AutomaticLoginEnable\s*=.*/AutomaticLoginEnable=true/" "$loginFile"
        sudo sed --in-place "s/.*AutomaticLogin\s*=.*/AutomaticLogin=$USER/" "$loginFile"
        elif $(IsOFF "$state"); then
        sudo sed --in-place "s/.*AutomaticLoginEnable\s*=.*/# AutomaticLoginEnable=true/" "$loginFile"
        sudo sed --in-place "s/.*AutomaticLogin\s*=.*/# AutomaticLogin=$USER/" "$loginFile"
        fi
    ;;
    "UNITY")
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
    local fileName="$(Trim "$1")"
    local file="$(Trim "$2")"

    local tmpAutoStartup="$(TempFile)"
    local varGroup


    fileName="$(AutoStartup_FileName "$fileName" "$file")"
    $(VariableExists "$3") && varGroup=" ""$(QuoteVariables "${@: 3}")"


    local fileContent="$(SmlTrim "[Desktop Entry]
    Version=1.0
    Exec=sh -c 'bash \"$file\"$varGroup'
    Icon=
    Name=$fileName
    GenericName=$fileName
    Comment=$fileName
    Encoding=UTF-8
    Terminal=true
    Type=Application
    Categories=Application;Network;")"


    CreateFolder_IfNotExists "$AutoStartupPath"


    echo "$fileContent" > "$tmpAutoStartup"
    sudo mv "$tmpAutoStartup" "$AutoStartupPath/$fileName"


    # Make it Executable
    sudo chmod +x "$AutoStartupPath/$fileName"
    # Remove All User Restrictions to this File
    sudo chmod 777 "$AutoStartupPath/$fileName"
}
function AutoStartup_Remove { sudo rm -f "$AutoStartupPath/$(AutoStartup_FileName "$1" "$2")"; }
function AutoStartup_FileName {
    local fileName="$(Trim "$1")"
    local file="$(Trim "$2")"

    $(IsEmpty "$fileName") && fileName="$(GetFileName_NoExtension "$file")"
    fileName="$(AddToEnd_IfNotContains ".desktop" "$fileName")"

    echo "$fileName"
}
function IsAutoStartup { FileExists "$AutoStartupPath/$(AutoStartup_FileName "$1" "$2")"; }
function IsNotAutoStartup { $(IsAutoStartup "$@") && echo false || echo true; }


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
    # "UNITY")
    # ;;
    # "KDE")
    # ;;
    # "XFCE")
    # ;;
    # esac


    local desktopsList="$(SmlTrim "$(SmlCutLines_Empty "
    GNOME
    UNITY
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
    local currentDesktop="$(UCase "$XDG_CURRENT_DESKTOP")"

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
    "UNITY")
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
    ParentDistro=""
    DistroCodeName=""
    Distro=""
    DistroVersion=""


    if $(FileExists "/etc/os-release"); then
        # freedesktop.org and systemd
        source /etc/os-release
        OS="$NAME"
        VER="$VERSION_ID"
        ParentDistro="$ID"
        DistroCodeName="$VERSION_CODENAME"
    elif type lsb_release >/dev/null 2>&1; then
        # linuxbase.org
        OS=$(lsb_release -si)
        VER=$(lsb_release -sr)
        DistroCodeName="$(lsb_release --codename --short)"
    elif $(FileExists "/etc/lsb-release"); then
        # For some versions of Debian/Ubuntu without lsb_release command
        source "/etc/lsb-release"
        OS=$DISTRIB_ID
        VER=$DISTRIB_RELEASE
    elif $(FileExists "/etc/debian_version"); then
        # Older Debian/Ubuntu/etc.
        OS="Debian"
        VER=$(cat /etc/debian_version)
    elif $(FileExists "/etc/SuSe-release"); then
        # Older SuSE/etc.
        ...
    elif $(FileExists "/etc/redhat-release"); then
        # Older Red Hat, CentOS, etc.
        ...
    else
        # Fall back to uname, e.g. "Linux <version>", also works for BSD, etc.
        OS=$(uname -s)
        VER=$(uname -r)
    fi


    Distro="$OS"
    DistroVersion="$VER"
}
function GenerateComputerSpecsVars {
    RAM=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    # Getting Only the GB Values
    RAM=$(Reverse $RAM)
    RAM=${RAM: 6}
    RAM=$(Reverse $RAM)
}


function IsParentDistro { [[ "$(LCase "$(Trim "$1")")" == "$ParentDistro" ]] && echo true || echo false; }
function IsDistroCodeName { [[ "$(LCase "$(Trim "$1")")" == "$DistroCodeName" ]] && echo true || echo false; }
function IsDistro { [[ "$(LCase "$(Trim "$1")")" == "$Distro" ]] && echo true || echo false; }
function IsDistroVersion { [[ "$(LCase "$(Trim "$1")")" == "$DistroVersion" ]] && echo true || echo false; }


function IfIsParentDistro { $(IsParentDistro "$1") && echo "$2" || echo ""; }


function InjectLib {
    local allShellFiles="$(SmlCutLines_Empty "$(SmlTrim "$1")")"


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


function GetProcessesPID { local processName="$(Trim "$1")"; ps -ef | grep $processName | awk '{print $2}'; }
function KillProcessesPID  { SmlExecute "kill" "$(GetProcessesPID "$1")"; }
