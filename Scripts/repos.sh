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


    cd "$fromDir"
    sudo git ls-files -m | sudo tar Tc - | sudo tar Cx "$toDir"
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


    if $(DirectoryNotExists "$dir"); then return; fi


    cd "$dir"
    git add -A
    git commit -m "$(Today)"
    cd "$tmpOldPath"
}


function LinkToFind { echo "http.*${3:-$1}.*${3:-$2}"; }
