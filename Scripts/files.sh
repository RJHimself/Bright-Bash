function FileExists { [[ -f "$1" ]] && echo true || echo false; }
function FolderExists { [[ -d "$1" ]] && echo true || echo false; }

function FileNotExists { $(FileExists "$@") && echo false || echo true; }
function FolderNotExists { $(FolderExists "$@") && echo false || echo true; }


function IsFile { echo $(FileExists "$@"); }
function IsFolder { echo $(FolderExists "$@"); }


function TempFolder { echo "$(mktemp -d)"; }
function TempFile { echo "$(mktemp)"; }


function CountArguments { echo "$#"; }


function UpdateFileLink { echo $(CreateFileLink "$1"); }
function CreateFileLink {
    local File="$1"
    local Link="$2"

    #? Sudo / Admin / Root Support
    if $(IsAdmin); then sudo ln -sf "$File" "$Link"
    else ln -sf "$File" "$Link"
    fi
}


function ReadFile { cat "$1"; }
function CreateFile { sudo touch "$1"; }
function DeleteFile { sudo rm -rf "$1"; }
function UpdateFile {
    local file="$1"
    local content="$2"

    echo "$content" > "$file"
}


function GetFileName {
    local directory="$(Trim "$1")"
    local fileName_Index="$((1 + $(IndexOf_Last "/" "$directory")))"
    local fileName="$(MidToEnd $fileName_Index "$directory")"

    echo "$fileName"
}
function GetFileName_NoExtension {
    local directory="$(Trim "$1")"
    local fileName="$(GetFileName "$directory")"

    local extensionIndex="$(IndexOf_Last "." "$fileName")"

    # If File Name Lacks an Extension
    if $(Lacks "\." "$fileName"); then echo "$fileName"; return; fi

    # If File Name does Not have a name before the Extension
    if $(IsEmpty ${fileName: 0:$extensionIndex}); then echo "${fileName: $((1 + $extensionIndex))}"; return; fi

    # If file Name as a Name & an Extension
    echo "${fileName: 0:$extensionIndex}"
}
function RemoveFolderSlash {
    #? SML Support
    if $(IsSml "$1"); then echo "$(SmlExecute "$(FuncName)" "$@")"; return; fi

    local folderDir="$(Trim "$1")"

    [[ "$(Right 1 "$folderDir")" == "/" ]] && echo "${folderDir: 0:-1}" || echo "$folderDir"
}


function SwitchDirSymbols {
    #? SML Support
    if $(IsSml "$1"); then echo "$(SmlExecute "$(FuncName)" "$@")"; return; fi


    local tmpDir="$(Trim "$1")"

    [[ "$(Left 1 "$tmpDir")" == "~" ]] && tmpDir="$HOME${tmpDir: 1}"
    [[ "$(Left 1 "$tmpDir")" != "/" ]] && finalPath="/$tmpDir"

    echo "$tmpDir"
}


function ListDir {
    # Example:
    # ListDir "$HOME/Downloads/**" "D"

    #? SML Support
    if $(IsSml "$1"); then echo "$(SmlExecute "$(FuncName)" "$@")"; return; fi


    local tmpDir="$(SwitchDirSymbols "$(Trim "$1")")"
    local objType="$(LCase "$(Left 1 "$(Trim "$2")")")"
    local depth=0
    local list

    local hasType=true
    local hasLimit=true

    local finalPath
    local finalDepth
    local finalType


    # Var Treatment
    [[ "$objType" == "*" ]] && hasType=false


    # finalPath Result
    if [[ "$(Right 3 "$tmpDir")" == "/**" ]]; then hasLimit=false; finalPath="${tmpDir: 0:-2}"
    elif [[ "$(Right 2 "$tmpDir")" == "/*" ]]; then depth=1; finalPath="${tmpDir: 0:-1}"
    elif [[ "$(Right 1 "$tmpDir")" != "/" ]]; then depth=0; finalPath="$tmpDir/"
    else depth=0; finalPath="$tmpDir"
    fi
    # finalType Result
    $hasType && finalType=" -type $objType "
    # finalDepth Result
    $hasLimit && finalDepth=" -maxdepth $depth "


    # Return IF Folder does NOT Exist
    if $(FolderNotExists "$finalPath"); then echo ""; return;fi

    # Final Result
    #? Sudo / Admin / Root Support
    if $(IsAdmin); then list="$(sudo find "$finalPath" $(Trim "$finalDepth") $(Trim "$finalType"))"
    else list="$(find "$finalPath" $(Trim "$finalDepth") $(Trim "$finalType"))"
    fi

    list="$(CutLines_Empty "$list")"
    list="$(SmlTrim "$list")"


    echo "$list"
}


function GetPermissions { echo $(stat -c "%a" "$1"); }
function ReadPermissions { GetFilePerm "$1"; }


function MkExecutable { chmod +x "$@"; }
function Executable { chmod +x "$@"; }


function PrepareForSed {
    local strPrepare="$1"

    strPrepare="$(Replace '/' '\/' "$strPrepare")"
    strPrepare="$(Replace '"' '\"' "$strPrepare")"
    strPrepare="$(Replace '$' '\$' "$strPrepare")"

    echo "$strPrepare"
}


function ReadXMLValue {
    local element="$1"
    local file="$2"

    cat "$file" | grep -oPm1 "(?<=<$element>)[^<]+"
}


function ReplaceLine {
    local lineIndex="$((1 + $(Trim "$1")))"
    local lineContent="$(Trim "$2")"
    local file="$(Trim "$3")"

    DeleteLine "$lineIndex" "$file"
    AddLine "$lineIndex" "$lineContent" "$file"
}
function AddLine {
    local lineIndex="$((1 + $(Trim "$1")))"
    local lineContent="$(Trim "$2")"
    local file="$(Trim "$3")"

    local fileLinesAmount="$(CountLines "$(ReadFile "$file")")"


    if $(IsEmpty "$lineContent"); then return; fi
    lineContent="$(PrepareForSed "$lineContent")"


    if (( $lineIndex > $fileLinesAmount )); then sed -i "$fileLinesAmount""a""$lineContent" "$file"
    else sed -i "$lineIndex""s/^/$lineContent\n/" "$file"
    fi
}
function DeleteLine {
    local lineIndex="$((1 + $(Trim "$1")))"
    local file="$(Trim "$2")"

    sed -i -e "$lineIndex""d" "$file"
}
function DeleteLinesFrom {
    local start="$((1 + $(Trim "$1")))"
    local end="$((1 + $(Trim "$2")))"
    local file="$(Trim "$3")"

    sed -i -e "$start,$end""d" "$file"
}


function GetFileTypeLong { file --mime-type -b "$1"; }
function ShortenTypeName {
    local deafultValue="$1"

    case "$deafultValue" in
        image/jpeg)         echo "jpeg";;
        text/plain)         echo "txt";;
        text/x-shellscript) echo "sh";;
        application/xml)    echo "xml";;
        application/zip)    echo "zip";;
        *)                  echo "$deafultValue";;
    esac
}

function GetFileType {
    local fileDir="$(Trim "$1")"
    local fileType="$(ShortenTypeName "$(GetFileTypeLong "$fileDir")")"
    local fileType_index
    local correctedType


    # CorrectTypeName
    if $(IsAny "$fileType" "txt"); then
        fileType_index="$((1 + $(IndexOf_Last "." "$fileDir")))"
        correctedType="$(MidToEnd $fileType_index $fileDir)"
        $(IsAny "$correctedType" "sh" "zsh" "fish" "bash") && fileType="$correctedType"
    fi


    echo "$fileType"
}


function CountCodeBlocks {
    local file="$1";
    local blockName="$2"
    local blockStart="$(GetCodeBlockComment_Start "$file" "$blockName")"

    blockStart="$(SmlTrim "$blockStart")"

    CountBlocks "$blockStart" "$(ReadFile "$file")";
}
function ContainsCodeBlocks { [[ $(CountCodeBlocks "$1") != 0 ]] && echo true || echo false; }
function LacksCodeBlocks { $(ContainsCodeBlocks "$@") && echo false || echo true; }


function GetCodeBlockComment_Start { echo "$(GetCodeBlockComment "START" "$@")"; }
function GetCodeBlockComment_End { echo "$(GetCodeBlockComment "End" "$@")"; }
function GetCodeBlockComment {
    local blockPart="$(UCase "$(Trim "$1")")"
    local fileType="$(GetFileType "$2")"
    local blockName="$(Trim "$3")"

    local blockComment
    local blockStart
    local blockEnd


    if $(IsAny "$fileType" "txt" "sh" "bash" "zsh" "fish"); then
    blockStart="#========================{ START BLOCK }========================
    # $blockName"
    blockEnd="#========================={ END BLOCK }========================="

    elif $(IsAny "$fileType" "js" "ts" "jsx" "tsx"); then
    blockStart="//========================{ START BLOCK }========================
    # $blockName"
    blockEnd="//========================={ END BLOCK }========================="
    fi


    [[ "$blockPart" == "START" ]] && blockComment="$blockStart" || blockComment="$blockEnd"


    echo "$blockComment"
}


function GetCodeBlockIndexesOccurr {
    local blockNumber="$(Trim "$1")"
    local file="$(Trim "$2")"

    local blockStart="$(SmlTrim "$(GetCodeBlockComment_Start "$file")")"
    local blockEnd="$(SmlTrim "$(GetCodeBlockComment_End "$file")")"

    local fileContent="$(ReadFile "$file")"

    local blockIndexes="$(GetBlockIndexesOccurr $blockNumber "$blockStart" "$blockEnd" "$fileContent")"


    echo "$blockIndexes"
}


function NewCodeBlock {
    local block="$1"
    local file="$2"
    local blockName="$3"

    local newBlock
    local newBlockStart="$(GetCodeBlockComment_Start "$file" "$blockName")"
    local newBlockEnd="$(GetCodeBlockComment_End "$file")"


    newBlock="$(SmlTrim "
    $newBlockStart
    $block
    $newBlockEnd
    ")"

    echo "$newBlock"
}
function AddCodeBlock {
    # EXAMPLE:
    # AddCodeBlock 3 "$file" "source \"$HOME/bin/bright-bash.sh\"" "I've Doin things Buddy"

    local blockIndex="$(Trim "$1")"
    local file="$(Trim "$2")"
    local block="$(Trim "$3")"
    local blockName="$(Trim "$4")"

    local newBlock="$(NewCodeBlock "$block" "$file" "$blockName")"
    local currentLine="$blockIndex"


    while IFS= read -r line; do
    AddLine $currentLine "$line" "$file"
    let "currentLine++"
    done <<< "$newBlock"
}
function DeleteCodeBlock {
    # EXAMPLE:
    # DeleteCodeBlock 2 "$HOME/MEGA/Documents/Tests/Shell/Bash/file.sh"

    local blockNumber="$(Trim "$1")"
    local file="$(Trim "$2")"

    local blockIndexes


    # Return IF There is No Code Block
    if $(LacksCodeBlocks "$file"); then return; fi
    if (( $blockNumber >= $(CountCodeBlocks "$file") )); then return; fi


    blockIndexes="$(GetCodeBlockIndexesOccurr "$blockNumber" "$file")"

    blockStart="$(GetLine_First "$blockIndexes")"
    blockEnd="$(GetLine_Last "$blockIndexes")"


    DeleteLinesFrom "$blockStart" "$blockEnd" "$file"
}


function AddCodeBlock_Top {
    local file="$(Trim "$1")"
    local block="$(Trim "$2")"
    local blockName="$(Trim "$3")"

    local fileContent="$(ReadFile "$file")"

    AddCodeBlock 0 "$file" "$block" "$blockName"
}
function AddCodeBlock_Bottom {
    local file="$(Trim "$1")"
    local block="$(Trim "$2")"
    local blockName="$(Trim "$3")"

    local fileContent="$(ReadFile "$file")"
    local blockIndex="$(CountLines "$fileContent")"

    AddCodeBlock "$blockIndex" "$file" "$block" "$blockName"
}


function TransferFiles {
    local transferWay="$(Trim "$(UCase "$1")")"
    local useGitRepo="$(Trim "$2")"
    local target="$(Trim "$3")"
    local backupDir="$(Trim "$4")"
    local sourceDir="$(Trim "$5")"


    backupDir="$(SwitchDirSymbols "$backupDir")"
    sourceDir="$(SwitchDirSymbols "$sourceDir")"

    [[ "$(Right 1 "$target")" == "/" ]] && target="$(Exclude_Last 1 "$target")"
    [[ "$(Right 1 "$backupDir")" != "/" ]] && backupDir="$backupDir/"
    [[ "$(Right 1 "$sourceDir")" != "/" ]] && sourceDir="$sourceDir/"


    if [[ "$transferWay" == "DOWNLOAD" ]]; then DownloadFiles "$useGitRepo" "$target" "$backupDir" "$sourceDir"
    elif [[ "$transferWay" == "UPLOAD" ]]; then UploadFiles "$useGitRepo" "$target" "$backupDir" "$sourceDir"
    fi
}
function DownloadFiles {
    local useGitRepo="$2"
    local target="$3"
    local backupDir="$4"
    local sourceDir="$5"


}
function UploadFiles {


}
