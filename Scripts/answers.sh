function IsNotON { $(IsON "$@") && echo false || echo true; }
function IsON {
    local state="$(UCase "$(Trim "$1")")"

    [[ "$state" == "ON" ]] && echo true || echo false;
}
function IsNotOFF { $(IsON "$@") && echo false || echo true; }
function IsOFF {
    local state="$(UCase "$(Trim "$1")")"

    [[ "$state" == "OFF" ]] && echo true || echo false;
}


function IsDownload {
    local answer="$(UCase "$(Trim "$1")")"
    answer="$(Left 1 "$answer")"

    
}
