function executable-header {
    local file="$(Trim "$1")"

    local fileType_index="$((1 + $(IndexOf_Last "." "$file")))"
    local fileType="$(MidToEnd "$fileType_index" "$file")"


    case "$fileType" in
    "py") echo '#!/usr/bin/env python';;
    "bash") echo '#!/bin/bash';;
    "sh") echo '#!/bin/bash';;
    esac
}


function convert-to-cli {
    # EXAMPLE
    # convert-to-cli py "$PWD" "$PWD/__cli__"


    function allow-file {
        local file="$(Trim "$1")"


        if [[ "$(Left "$(Length "$fileHeader")" "$first_line")" != "$fileHeader" ]]; then echo false; return; fi
        if $(IsEmpty "$second_line"); then echo false; return; fi
        if [[ "$(Left "$(Length "$executable_name_after")" "$second_line")" != "$executable_name_after" ]]; then echo false; return; fi


        echo true
    }
    function convert-file {
        local cliName="$(Trim "$1")"
        local file="$(SwitchDirSymbols_File "$2")"

        local relativeDirectory="$(RelativePath_After "$originalDirectory" "$file")"
        local finalDirectory="$(SwitchDirSymbols_File "$endDiretory")/$relativeDirectory"


        CreateFolder "$finalDirectory"
        CreateFileLink "$file" "$finalDirectory/$cliName"
        # sudo chmod +x "$endDiretory/$cliName"
        # sudo chmod 777 "$endDiretory/$cliName"
    }


    local filetype="$(Trim "$1")"
    local originalDirectory="$(SwitchDirSymbols_Folder "$2")"
    local endDiretory="$(SwitchDirSymbols_Folder "$3")"


    if $(FolderNotExists "$originalDirectory");
    then echo "Original Directory doesn't exists"; return; fi


	local oldDir="$PWD"
    local newDir="$originalDirectory"
    cd "$newDir"
    local files="$(find -name "*.$filetype" -not -path "./.git")"
    cd "$oldDir"
    # local files="$(find "$originalDirectory"**/*."$filetype" -type f)"

    local fileHeader="$(executable-header ".py")"
    local executable
    local executable_name_after="#exe: "


    while IFS= read -r file; do
        local first_line="$(SmlGetLine_First "$(ReadFile "$file")")"
        local second_line="$(SmlGetLine 1 "$(ReadFile "$file")")"
        local second_line_content=""
        second_line="$(Trim "$second_line")"

        if $(allow-file "$file"); then
            second_line_content="$(Trim "$(MidToEnd "$(Length "$executable_name_after")" "$second_line")")"
            executable="$(ReplaceChar " " "-" "$(LCase "$second_line_content")")"


            convert-file "$executable" "$file"
        fi
    done <<< "$files"
}
