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


function IsDownload { [[ "$(FirstUCase "$1")" == "D" ]] && echo true || echo false; }
function IsUpload { [[ "$(FirstUCase "$1")" == "U" ]] && echo true || echo false; }
