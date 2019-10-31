function FunctionExists { [[ "$(type -t $1)" == "function" ]] && echo true || echo false; }
function FunctionNotExists { $(FunctionExists "$1") && echo false || echo true; }


function VariableExists { IsNotEmpty "$1"; }
function VariableNotExists { $(VariableExists "$1") && echo false || echo true; }


function QuoteVariables {
    # Quoting Every Variable with Spaces or Multi Lines
    local varGroup

    for element in $@; do
        if $(Contains " " "$element") || $(IsSml "$element");
        then varGroup="$varGroup "'"'"$element"'"';
        else varGroup="$varGroup ""$element";
        fi
    done

    echo "$varGroup"
}


function DebugToFile {
    local message="$(Trim "$1")"
    local file="$(Trim "$2")"

    if $(IsEmpty "$DebuggingFile") && $(IsEmpty "$file"); then return; fi
    $(IsEmpty "$file") && file="$DebuggingFile"
    DebuggingFile="$file"

    CreateFile_IfNotExists "$file"
    sudo su -c "echo "$message" >> "$file""
    chmod 777 "$file"

    echo "---------------------"
    echo "$message"
    echo "---------------------"
}
function DebugToFile_Clear { $(FileExists "$DebuggingFile") && sudo rm -f "$DebuggingFile"; }
