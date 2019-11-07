function IsNotNumber { $(IsNumber "$@") && echo false || echo true; }
function IsNumber {
    local possibleNumber="$(Trim "$1")"
    local numberPattern='^[0-9]+$'

    [[ "$possibleNumber" =~ $numberPattern ]] && echo true || echo false
}


function GetVersion {}
