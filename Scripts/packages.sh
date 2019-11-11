function ListPackagesLike { apt-cache search --names-only ".*$(Trim "$1").*"; }


function AddPkg_GhDebRelease {
    set -e
    loc="$(mktemp).deb"
    case $1 in
    http*) sudo wget -O "$loc" $1;;
    *) loc="$1";;
    esac
    sudo dpkg -i "$loc"
    sudo apt -f install
    sudo rm -f "$loc"
}

function AddPkg_apt {
    local packages="$1"
    local repo="$2"


    if $(IsNotEmpty "$repo"); then
    sleep 1; echo -e "\n" | sudo add-apt-repository -y "$repo"
    fi


    sleep 1
    sudo apt update
    for pkg in $packages; do sleep 1; yes | sudo apt install -y "$pkg"; done
    sleep 1
    sudo apt update
    sleep 1
    yes | sudo apt upgrade
}

function AddPkg_GhClone {
    local oldDir=$PWD
    local tmpFolder=$(mktemp -d)

    local url="$2"
    local fileToExe="$1"
    local folder=$(Gh_GetRepoName "$url")


    cd "$tmpFolder"
    eval "cd "$tmpFolder""

    git clone "$url"

    cd "$tmpFolder/$folder"
    eval "cd "$tmpFolder/$folder""


    while IFS= read -r toExe; do
    eval "$toExe"
    done <<< "$fileToExe"


    cd "$oldDir"
    sudo rm -rf "$tmpFolder"
}

function AddPkg_wget {
    # Replaces These

    # wget "https://URL/To/Pakage"

    # sudo apt install ./PakageName
    # OR
    # sudo dpkg -i ./PakageName
    # OR
    # sudo gdebi ./PakageName


    local oldDir=$PWD
    local tmpFolder=$(mktemp -d)

    local format=$1
    local url=$2
    local debPkg=${url##*/}


    cd $tmpFolder

    wget -O "$debPkg" "$url"


    case $format in
    "apt")
        echo -e "y" | sudo apt install -y $debPkg
        ;;
    "dpkg")
        echo -e "y" | sudo dpkg -i $debPkg
        ;;
    "gdebi")
        echo -e "y" | sudo gdebi $debPkg
        ;;
    *)
        echo "--------------------------------------------"
        echo "This Format It's Not Currently Supported"
        echo "--------------------------------------------"
        ;;
    esac


    cd $oldDir
    sudo rm -rf $tmpFolder
    sudo apt update
}


function AddPkg_GnomeExtension_Only {
    local extension="$(Trim "$1")"
    local uuid="$(unzip -c "$extension" metadata.json | grep uuid | cut -d \" -f4)"

    mkdir -p "$HOME/.local/share/gnome-shell/extensions/$uuid"
    unzip -q "$extension" -d "$HOME/.local/share/gnome-shell/extensions/$uuid/"

    gnome-shell-extension-tool -e "$uuid"
}
function AddPkg_GnomeExtensions {
    local gndExtLocation="$1"
    local gndExtensions


    gndExtensions="$(ListDir "$gndExtLocation" "F")"
    gndExtensions="$(SmlCutLines_Empty "$gndExtensions")"
    gndExtensions="$(SmlTrim "$gndExtensions")"


    while IFS= read -r extension; do
    AddPkg_GnomeExtension_Only "$extension"
    done <<< "$gndExtensions"
}
function AddPkg_Snap {
    local thisSnap="$1"

    sudo snap install "$thisSnap"
    # Actually Installing the Snap Acknowledged Packages
    sudo snap install --classic "$thisSnap"
}


function download_gnome_extension {
    function get_corrent_link {
        local link="$(Replace "%40" "" "$(Trim "$1")")"
        local extension_index="$((1+$(IndexOf_Last "/" "$link")))"
        link="$(MidToEnd $extension_index "$link")"

        local link_length=$(Length "$link")
        local link_fixed_url="https://extensions.gnome.org/extension-data/"


        for (( i=0; i<$link_length; i++ )); do
            local left_side="$(Left $i "$link")"
            local right_side="$(Right $(($link_length-$i)) "$link")"
            local new_url="$link_fixed_url""$left_side""%40""$left_side"

            if $(UrlExists "$new_url"); then echo "$new_url"; return; fi
        done


        return
    }


    local extension_link="$(Trim "$1")"
    local extensions_folder="$(IfTrimNotEmpty "$2" "$HOME/Downloads")"
    extensions_folder="$(SwitchDirSymbols_Folder "$extensions_folder")"


    # %40 is used on most of these gnome extensions to download'em
    $(UrlNotExists "$extension_link") && extension_link="$(get_corrent_link "$extension_link")"
    if $(IsEmpty "$extension_link"); then echo "Returning due to wrong Link"; return; fi


    download_to_folder "$extensions_folder" "$extension_link"
}


function UpdatePkg_apt {
    # Update Package Availability Database
    sudo apt update
    yes | sudo apt upgrade
    # Fixing Broken Packages
    yes | sudo apt --fix-broken install


    # Update Package Availability Database
    sudo apt update
    yes | sudo apt upgrade
    # Fixing Broken Packages
    yes | sudo apt --fix-broken install
}
function UpdatePkg_pacman {
    pamac checkupdates -a
    pamac upgrade -a
}
function UpdatePkg_ALL {
    # APT Packages
    $(IsPkgManagerRunning "apt") && UpdatePkg_apt
    # SNAP Packages
    $(IsPkgManagerRunning "snap") && sudo snap refresh
    # Pacman AUR Packages
    $(IsPkgManagerRunning "pamac") && UpdatePkg_pacman
    # Pamac Packages
    $(IsPkgManagerRunning "pacman") && sudo pacman -Syu
    # YUM Packages
    $(IsPkgManagerRunning "yum") && sudo yum update
    # Flatpak Packages
    $(IsPkgManagerRunning "flatpak") && sudo flatpak update
}


function IsPkgManagerRunning { $(IsNotEmpty "$($1 --version)") && echo true || echo false; }
function IsNotPkgManagerRunning { $(IsPkgManagerRunning "$@") && echo false || echo true; }
