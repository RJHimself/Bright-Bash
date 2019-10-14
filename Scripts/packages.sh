function addPkg_ghDebRelease {
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

function addPkg_apt {

    local packages=$1
    local repo=$2


    if $(IsNotEmpty $repo); then
        echo -e "\n" | sudo add-apt-repository -y "$repo"
        sudo apt update
    fi


    # Changing the Way Strings Function to Loop Through Words
    setopt shwordsplit

    for pkg in $packages; do yes | sudo apt install -y $pkg; done

    # Chaning Back to the Default Way Strings Functioned to prevent Functioning Problems
    unsetopt shwordsplit


    yes | sudo apt upgrade
}

function addPkg_ghClone {
    local oldDir=$PWD
    local tmpFolder=$(mktemp -d)

    local url="$2"
    local fileToExe="$1"
    local folder=$(gh_getRepoName "$url")


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

function addPkg_wget {
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


function updatePkg_apt {
    sudo apt update
    yes | sudo apt upgrade
}
