function GitHistoryTree { git-history-tree "$@"; }
function GitChangesTree { git-changes-tree "$@"; }
function git-history-tree { ExeOnDir "git log --graph --oneline --all" "$@"; }
function git-changes-tree { ExeOnDir "git tree" "$@"; }


function FindLink {
    # # EXAMPLE
    # FindLink "https://sites.google.com/a/chromium.org/chromedriver/" "https://chromedriver.storage.googleapis.com.*"

    local whereToSearch="$(Trim "$1")"
    local linkToFind="$(Trim "$2")"

    local pageCode="$(Trim "$(GetPageHtml "$whereToSearch" | grep -o "$linkToFind")")"
    local linkFound

    pageCode="$(SmlSplit " " "$pageCode")"
    linkFound="$(Trim "$(SmlGetLine_First "$pageCode")")"
    [[ $(Right 1 "$linkFound") == '"' ]] && linkFound="${linkFound: 0:-1}"

    echo "$linkFound"
}
function LinkToFind { echo "http.*${3:-$1}.*${3:-$2}"; }
function LastestReleaseLink { echo "https://api.github.com/repos/$1/$2/releases/latest"; }
function GhRelease { curl -s "$1" | grep -o "$2"; }


function Gh_GetRepoName {
    local url=$1

    local gitRepo=${url##*/}
    local wordLength=$((${#gitRepo} - 4))

    [[ "${gitRepo: $wordLength}" == ".git" ]] && local gitRepo="${gitRepo: 0:$wordLength}"

    echo $gitRepo
}

function GitCloneAll {
    # ONE LINER
    # git branch -a | grep -v HEAD | perl -ne 'chomp($_); s|^\*?\s*||; if (m|(.+)/(.+)| && not $d{$2}) {print qq(git branch --track $2 $1/$2\n)} else {$d{$_}=1}' | csh -xfs

    local repoUrl="$1"
    local repoLocal="$2"
    local repo="$(Gh_GetRepoName "$repoUrl")"


    git clone "$repoUrl" "$repoLocal"
    cd "$repo"

    local remoteBranches=$(git branch --all | grep '^\s*remotes' | egrep --invert-match '(:?HEAD|master)$')

    for branch in $remoteBranches; do
        git branch --track "${branch##*/}" "$branch"
    done


    # branch="gnome-apt"
    # git checkout -b $brancha
    # git branch --set-upstream-to=origin/$branch $branch

    git fetch --all
    git pull --all
}

function GitGetChanges {
    local fromDir="$(Trim "$1")"
    local toDir="$(Trim "$2")"

    local tmpOldPath="$(Trim "$PWD")"


    if $(FolderNotExists "$fromDir"); then return; fi
    $(DirectoryNotExists "$toDir") && CreateFolder "$toDir"


    cd "$fromDir"
    sudo su -c "git ls-files -m -o --exclude-standard | tar Tc - | tar Cx \"$toDir\""
    cd "$tmpOldPath"
}

function GitSync {
    local fromDir="$(Trim "$1")"
    local toDir="$(Trim "$2")"

    local tmpOldPath="$(Trim "$PWD")"


    if $(FolderNotExists "$fromDir"); then return; fi


    GitGetChanges "$fromDir" "$toDir"
    GitCommitToday "$fromDir"
}

function GitCommitToday {
    local dir="$(Trim "$1")"
    local tmpOldPath="$(Trim "$PWD")"


    $(DirectoryNotExists "$dir") && dir="$PWD"


    cd "$dir"
    sudo git add -A
    sudo git commit -m "$(Today)"
    cd "$tmpOldPath"
}


function GitInit { ExeOnDir "git init" "$@"; }
function GitAddAll { ExeOnDir "sudo git add -A" "$@"; }
function GitUndoChanges { ExeOnDir "sudo git reset --hard" "$@"; }


function GitPull { ExeOnDir "sudo -u "$USER" git pull" "$@"; }
function GitPush { ExeOnDir "sudo -u "$USER" git push" "$@"; }
function GitPushAll {
    local dir="$(IfTrimNotEmpty "$1" "$PWD")"

    GitCommitToday "$dir"
    GitPush "$dir"
}


function GitCloneTo { ExeOnDir "git clone \"$1\"" "$(Trim "$2")"; }


function GitRestartTest {
    local folder="$(Trim "$1")"
    local oldDir="$PWD"


    $(IsEmpty "$folder") && folder="$PWD"
    [[ $(Left 1 "$folder") == "." ]] && folder="$PWD${folder: 1}"


    cd "$folder"
    sudo rm -rf "$folder/.git"
    git init
    sudo git add -A
    sudo git commit -m "Initial Commit"
    cd "$oldDir"
}


function GetPageHtml { curl -s "$(Trim "$1")"; }
function UrlNotExists { $(UrlExists "$@") && echo false || echo true; }
function UrlExists {
    possibleURL="$(Trim "$1")"

    if curl --output /dev/null --silent --head --fail "$possibleURL"
    then echo true
    else echo false
    fi
}
