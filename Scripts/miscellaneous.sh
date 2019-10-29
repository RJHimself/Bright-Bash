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
