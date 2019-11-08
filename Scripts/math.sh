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

    local versionIndex="$(GetNumberIndex_First "$strEnglobber")"
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
function GetVersion_ByLevel {
    local versionLevel="$(Trim "$1")"
    local fullVersion="$(GetVersion "$2")"

    local finalVersion="$(GetNumber $versionLevel "$fullVersion")"

    echo "$finalVersion"
}

alias GetVersion_Macro=GetVersion_ByLevel_Macro
function GetVersion_ByLevel_Macro { GetVersion_ByLevel 0 "$@"; }
alias GetVersion_Major=GetVersion_ByLevel_Major
function GetVersion_ByLevel_Major { GetVersion_ByLevel 1 "$@"; }

alias GetVersion_Minor=GetVersion_ByLevel_Minor
function GetVersion_ByLevel_Minor { GetVersion_ByLevel 2 "$@"; }
alias GetVersion_Micro=GetVersion_ByLevel_Micro
function GetVersion_ByLevel_Micro { GetVersion_ByLevel 3 "$@"; }


function GetNumberIndex_First { GetNumberIndexAt_First 0 "$@"; }
function GetNumberIndexAt_First {
    local startAt="$(Trim "$1")"
    local strEnglobber="$(MidToEnd $startAt "$(Trim "$2")")"

    local firstNumberIndex="$(IndexOf_Lowest "$strEnglobber" 1 2 3 4 5 6 7 8 9 0)"

    echo $firstNumberIndex
}
function GetNumber { GetNumberAt 0 "$@"; }
function GetNumberAt {
    local startAt="$(Trim "$1")"
    local amount=$(Trim "$2")
    local strEnglobber="$(MidToEnd $startAt "$(Trim "$3")")"

    local currentIndex=0
    local currentNumber
    local currentLength


    for (( i=0; i<=$amount; i++ )); do
        strEnglobber="$(MidToEnd $currentIndex "$(Trim "$strEnglobber")")"

        currentNumber="$(GetNumber_First "$strEnglobber")"
        currentLength="$(Length "$currentNumber")"
        currentIndex=$(( $currentLength + $(GetNumberIndex_First "$strEnglobber") ))
    done


    echo $currentNumber
}
function GetNumber_First { GetNumberAt_First 0 "$@"; }
function GetNumberAt_First {
    local startAt="$(Trim "$1")"
    local strEnglobber="$(MidToEnd $startAt "$(Trim "$2")")"

    local versionIndex="$(GetNumberIndex_First "$strEnglobber")"
    local currentIndex=$versionIndex
    local currentChar="$(GetChar $currentIndex "$strEnglobber")"
    local finalVersion


    while $(IsNumber $currentChar); do
        finalVersion="$finalVersion""$currentChar"

        let "currentIndex++"
        currentChar="$(GetChar $currentIndex "$strEnglobber")"
    done


    echo "$finalVersion"
}


function Sort { echo "$(SmlCutLines_Empty "$1")" | sort --version-sort; }
