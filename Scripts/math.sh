function IsNotNumber { $(IsNumber "$@") && echo false || echo true; }
function IsNumber {
    local possibleNumber="$(Trim "$1")"
    local numberPattern='^[0-9]+$'

    [[ "$possibleNumber" =~ $numberPattern ]] && echo true || echo false
}


function GetVersion {
    local strEnglobber="$(Trim "$1")"
    local versionIndex="$(IndexOf_Lowest "$strEnglobber" 1 2 3 4 5 6 7 8 9 0)"

    
}


function Sort { echo "$(SmlCutLines_Empty "$1")" | sort; }
function SortVersion { echo "$(SmlCutLines_Empty "$1")" | sort --version-sort; }
