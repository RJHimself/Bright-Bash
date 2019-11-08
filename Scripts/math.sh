function IsNotNumber { $(IsNumber "$@") && echo false || echo true; }
function IsNumber {
    local possibleNumber="$(Trim "$1")"
    local numberPattern='^[0-9]+$'

    [[ "$possibleNumber" =~ $numberPattern ]] && echo true || echo false
}


function GetVersion {
    function KeepLoadingNumbers {
        if $(IsNumber $currentChar) || $(IsChar "." "$currentChar");
        then echo true;
        else echo false;
        fi
    }


    local strEnglobber="$(Trim "$1")"
    local versionIndex="$(IndexOf_Lowest "$strEnglobber" 1 2 3 4 5 6 7 8 9 0)"
    local currentIndex=$versionIndex
    local currentChar="$(GetChar $currentIndex "$strEnglobber")"
    local finalVersion


    while $(KeepLoadingNumbers); do
        finalVersion="$finalVersion""$currentChar"

        let "currentIndex++"
        currentChar="$(GetChar $currentIndex "$strEnglobber")"
    done

    [[ $(Left 1 "$finalVersion") == "." ]] && finalVersion="$(Exclude_First 1 "$finalVersion")"
    [[ $(Right 1 "$finalVersion") == "." ]] && finalVersion="$(Exclude_Last 1 "$finalVersion")"


    echo "$finalVersion"
}


function Sort { echo "$(SmlCutLines_Empty "$1")" | sort --version-sort; }
