function IsNotON { $(IsON "$@") && echo false || echo true; }
function IsON {
    local state="$(UCase "$(Trim "$1")")"

    [[ "$state" == "ON" ]] && echo true || echo false;
}
function IsNotOFF { $(IsOFF "$@") && echo false || echo true; }
function IsOFF {
    local state="$(UCase "$(Trim "$1")")"

    [[ "$state" == "OFF" ]] && echo true || echo false;
}


function IsDownloadOrUpload { if $(IsDownload "$1") || $(IsUpload "$1"); then echo true; else echo false; fi }
function IsDownload { [[ "$(FirstUCase "$1")" == "D" ]] && echo true || echo false; }
function IsUpload { [[ "$(FirstUCase "$1")" == "U" ]] && echo true || echo false; }

function IsNotDownloadOrUpload { $(IsDownloadOrUpload "$1") && echo false || echo true; }
function IsNotDownload { $(IsDownload "$1") && echo false || echo true; }
function IsNotUpload { $(IsUpload "$1") && echo false || echo true; }
