function IsNotNumber { $(IsNumber "$@") && echo false || echo true; }
function IsNumber {
    local possibleNumber="$(Trim "$1")"
    local numberPattern='^[0-9]+$'

    [[ "$possibleNumber" =~ $numberPattern ]] && echo true || echo false
}


function GetVersion {}


function Sort { echo "$(SmlCutLines_Empty "$1")" | sort; }
function SortVersion { echo "$(SmlCutLines_Empty "$1")" | sort --version-sort; }
