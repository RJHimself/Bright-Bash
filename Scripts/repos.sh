function lastestReleaseLink { echo "https://api.github.com/repos/$1/$2/releases/latest"; }
function ghRelease { curl -s "$1" | grep -o "$2"; }


function gh_getRepoName {
    local url=$1

    local gitRepo=${url##*/}
    local wordLength=$((${#gitRepo} - 4))

    [[ "${gitRepo: $wordLength}" == ".git" ]] && local gitRepo="${gitRepo: 0:$wordLength}"

    echo $gitRepo
}

function gitCloneAll {
    # ONE LINER
    # git branch -a | grep -v HEAD | perl -ne 'chomp($_); s|^\*?\s*||; if (m|(.+)/(.+)| && not $d{$2}) {print qq(git branch --track $2 $1/$2\n)} else {$d{$_}=1}' | csh -xfs

    local repoUrl="$1"
    local repoLocal="$2"
    local repo="$(gh_getRepoName "$repoUrl")"


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

function linkToFind { echo "http.*${3:-$1}.*${3:-$2}"; }
