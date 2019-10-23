function FunctionExists { [[ "$(type -t $1)" == "function" ]] && echo true || echo false; }
function FunctionNotExists { $(FunctionExists "$1") && echo false || echo true; }


function VariableExists { IsNotEmpty "$1"; }
function VariableNotExists { $(VariableExists "$1") && echo false || echo true; }
