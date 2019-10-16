function Entitle { Divider; echo "$1"; Divider; }

function Divider {
    local divider="\e[92m"

    for (( i=1; i<=$(tput cols); i++ )); do divider="$divider-"; done
    divider="$divider\e[0m"

    echo -e "$divider"
}
