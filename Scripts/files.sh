function FileExists { [[ -f "$1" ]] && echo true || echo false; }
function FolderExists { [[ -d "$1" ]] && echo true || echo false; }
function DirectoryExists {
    local dir="$(Trim "$1")"
    if $(FileNotExists "$dir") && $(FolderNotExists "$dir"); then echo false; return; fi
    echo true
}

function FileNotExists { $(FileExists "$@") && echo false || echo true; }
function FolderNotExists { $(FolderExists "$@") && echo false || echo true; }
function DirectoryNotExists { $(DirectoryExists "$@") && echo false || echo true; }


function RelativePath_After {
    local afterPath="$(Trim "$1")"
    local file="$(SwitchDirSymbols_File "$2")"

    local originalfileName="$(GetFileName "$file")"

    local relativePath_start=$(($(Length "$afterPath") + $(IndexOf "$afterPath" "$file")))
    local relativePath_end=$(($(Length "$file") - $(Length "$originalfileName")))
    local relativePath="$(MidAbsolute $relativePath_start $relativePath_end "$file")"


    [[ "$(Left 1 "$relativePath")" == "/" ]] && relativePath="$(Exclude_First 1 "$relativePath")"
    [[ "$(Right 1 "$relativePath")" == "/" ]] && relativePath="$(Exclude_Last 1 "$relativePath")"


    echo "$relativePath"
}


function IsFile { echo $(FileExists "$@"); }
function IsFolder { echo $(FolderExists "$@"); }


function ExeOnDir {
    local toExe="$(Trim "$1")"
    local dir="$(Trim "$2")"
    local oldDir="$PWD"


    $(IsEmpty "$dir") && dir="$PWD"
    dir="$(SwitchDirSymbols_Folder "$dir")"
    CreateFolder_IfNotExists "$dir"


    eval "cd \"$dir\"; $toExe; cd \"$oldDir\""
}


function TempFolder { echo "$(mktemp -d)"; }
function TempFile { echo "$(mktemp)"; }
function StatusFile {
    local statusBool="$(IfTrimNotEmpty "$1" "true")"
    local file="$(IfTrimNotEmpty "$2" "$(TempFile)")"
    file="$(SwitchDirSymbols_File "$file")"

    StatusFile_WriteStatus "$statusBool" "$file";

    echo "$file"
}
function StatusFile_GetStatus {
    local file="$(SwitchDirSymbols_File "$1")"
    local statusBool

    if $(FileNotExists "$file"); then echo false; return; fi

    statusBool="$(ReadFile "$file")"
    statusBool="$(SmlCutLines_Empty "$statusBool")"
    statusBool="$(SmlGetLine_First "$statusBool")"
    statusBool="$(Trim "$statusBool")"
    statusBool="$(LCase "$statusBool")"

    [[ "$statusBool" == "true" ]] && echo true || echo false
}
function StatusFile_WriteStatus {
    local statusBool="$(LCase "$(IfTrimNotEmpty "$1" "true")")"
    local file="$(SwitchDirSymbols_File "$2")"

    if $(FileNotExists "$file"); then return; fi
    if [[ "$statusBool" != "true" ]] && [[ "$statusBool" != "false" ]]; then statusBool="true"; fi

    WriteFile "$file" "$statusBool";
}


function CountArguments { echo "$#"; }


function UpdateFolderLink { echo $(CreateFolderLink "$1"); }
function CreateFolderLink {
    local file="$(SwitchDirSymbols "$1")"
    local link="$(SwitchDirSymbols "$2")"

    sudo rm -rf "$link"

    #? Sudo / Admin / Root Support
    if $(IsAdmin); then sudo ln -s "$file" "$link"
    else ln -s "$file" "$link"
    fi
}
function UpdateFileLink { echo $(CreateFileLink "$1"); }
function CreateFileLink {
    local file="$(SwitchDirSymbols "$1")"
    local link="$(SwitchDirSymbols "$2")"

    sudo rm -rf "$link"

    #? Sudo / Admin / Root Support
    if $(IsAdmin); then sudo ln -sf "$file" "$link"
    else ln -sf "$file" "$link"
    fi
}


function GetFolderLinks { GetSymbolicLinks "$1" "folder"; }
function GetFileLinks { GetSymbolicLinks "$1" "file"; }
function GetSymbolicLinks {
    local directory="$(Trim "$1")"
    local linkType="$(Trim "$2")"
    local recursive="$(IfTrimNotEmpty "$3" false)"

    local symbolicLinks
    local links


    if $recursive;
    then links="$(find -L "$(Trim "$directory")" -xtype l)"
    else links="$(find "$(Trim "$directory")" -type l)"
    fi


    while IFS= read -r link; do
        if [[ "$linkType" == "folder" ]]; then
        $(IsFolder "$link") && symbolicLinks="$symbolicLinks"$'\n'"$link"
        elif [[ "$linkType" == "file" ]]; then
        $(IsFile "$link") && symbolicLinks="$symbolicLinks"$'\n'"$link"
        fi
    done <<< "$links"
    symbolicLinks="$(SmlCutLines_Empty "$symbolicLinks")"


    echo "$symbolicLinks"
}
function GetFolderLinks_Recursive { GetSymbolicLinks_Recursive "$1" "folder"; }
function GetFileLinks_Recursive { GetSymbolicLinks_Recursive "$1" "file"; }
function GetSymbolicLinks_Recursive { GetSymbolicLinks "$@" true; }


function FolderHierarchy {
    if $(VariableNotExists "$1"); then return; fi


    local thisFolder="$(SwitchDirSymbols_Folder "$1")"
    local hierarchy="$(ListBeforeIndexesOf "/" "$thisFolder")"


    echo "$hierarchy"
}


function CreateFolder {
    local folder="$(Trim "$1")"
    local folderHierarchy="$(FolderHierarchy "$folder")"
    local permissions="777"

    while IFS= read -r tmpFolder; do
    if $(FolderNotExists "$tmpFolder"); then

        sudo mkdir -p -m $permissions "$folder"
        sudo chmod -R $permissions "$tmpFolder"
        return
    fi
    done <<< "$folderHierarchy"
}
function CreateFolder_IfNotExists { CreateFolder "$@"; }


function CreateFile {
    local file="$(Trim "$1")"
    local content="$2"
    local folder="$(GetFolder "$file")"
    local permissions="777"

    CreateFolder_IfNotExists "$folder"
    $(FileNotExists "$file") && sudo su -c "echo \"$content\" > \"$file\""; sudo chmod "$permissions" "$file"
}
function CreateFile_IfNotExists { CreateFile "$@"; }
function ReadFile { sudo cat "$(Trim "$1")"; }
function DeleteFile { sudo rm -rf "$(Trim "$1")"; }
function WriteFile {
    local file="$(Trim "$1")"
    local content="$2"

    local permissions
    local tmpFile="$(TempFile)"


    CreateFile_IfNotExists "$file"
    permissions="$(GetPermissions "$file")"


    echo "$content" > "$tmpFile"
    sudo mv "$tmpFile" "$file"
    ChangePermissions 777 "$file"
}
function UpdateFile { WriteFile "$@"; }


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

function SwitchDirSymbols_Folder {
    local thisFolder="$(SwitchDirSymbols "$1")"
    [[ "$(Right 1 "$thisFolder")" != "/" ]] && thisFolder="$thisFolder/"

    echo "$thisFolder"
}
function SwitchDirSymbols_File {
    local thisFile="$(SwitchDirSymbols "$1")"
    [[ "$(Right 1 "$thisFile")" == "/" ]] && thisFile="$(Exclude_Last 1 "$thisFile")"

    echo "$thisFile"
}
function SwitchDirSymbols {
    #? SML Support
    if $(IsSml "$1"); then echo "$(SmlExecute "$(FuncName)" "$@")"; return; fi


    local tmpDir="$(Trim "$1")"

    [[ "$(Left 1 "$tmpDir")" == "~" ]] && tmpDir="$HOME${tmpDir: 1}"
    [[ "$(Left 1 "$tmpDir")" == "." ]] && tmpDir="$PWD${tmpDir: 1}"
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
    local recursive="$3"

    local depth=0
    local list

    local hasType=true
    local hasLimit=true

    local finalPath
    local finalDepth
    local finalType


    # Var Treatment
    $(IsEmpty "$tmpDir") && tmpDir="$PWD"
    $(IsEmpty "$objType") && objType="*"
    [[ "$objType" == "*" ]] && hasType=false


    # finalPath Result
    if [[ "$(Right 3 "$tmpDir")" == "/**" ]]; then hasLimit=false; finalPath="${tmpDir: 0:-2}"
    elif [[ "$(Right 2 "$tmpDir")" == "/*" ]]; then depth=1; finalPath="${tmpDir: 0:-1}"
    elif [[ "$(Right 1 "$tmpDir")" != "/" ]]; then depth=0; finalPath="$tmpDir/"
    else depth=0; finalPath="$tmpDir"
    fi
    # finalType Result
    $hasType && finalType=" $($(IsRecursive "$recursive") && echo "-xtype $objType" || echo "-type $objType") "
    # finalDepth Result
    $hasLimit && finalDepth=" -maxdepth $depth "


    # Return IF Folder does NOT Exist
    if $(FolderNotExists "$finalPath"); then echo ""; return;fi

    # Final Result
    #? Sudo / Admin / Root Support
    if $(IsAdmin); then list="$(sudo find $(if $(IsRecursive "$recursive"); then echo "-L"; fi;) "$finalPath" $(Trim "$finalDepth") $(Trim "$finalType"))"
    else list="$(find "$finalPath" $(Trim "$finalDepth") $(Trim "$finalType"))"
    fi

    list="$(SmlCutLines_Empty "$list")"
    list="$(SmlTrim "$list")"


    echo "$list"
}
function ListFiles {
    local dir="$(IfTrimNotEmpty "$1" "$PWD")"
    find "$dir"/* -type d -o \( -name .git -prune \) -o -print
}
function ListFolders {
    local dir="$(IfTrimNotEmpty "$1" "$PWD")"
    find "$dir"/* -type f -o \( -name .git -prune \) -o -print
}


function GetPermissions { echo $(stat -c "%a" "$1"); }
function ReadPermissions { GetFilePerm "$1"; }
function ChangePermissions {
    local permissions="$(IfTrimNotEmpty "$1" "777")"
    local location="$(IfTrimNotEmpty "$2" "$PWD")"

    sudo chmod "$permissions" "$location";
}


function MkExecutable { chmod +x "$@"; }
function Executable { chmod +x "$@"; }
function MkExecutable_AllDir {
    local dir="$(IfTrimNotEmpty "$1" "$PWD")"
    local filesList="$(ListFiles "$dir")"


    while IFS= read -r file; do
    sudo chmod +x "$file"
    done <<< "$filesList"
}


function ExecFile {
    local file="$(Trim "$1")"
    local permissions="$(GetPermissions "$file")"


    sudo chmod +x "$file"
    sudo chmod $permissions "$file"
    "$file"
}


function ChangePermissions_AllDir {
    local permissions="$1"
    local dir="$2"


    while IFS= read -r file; do
    ChangePermissions "$permissions" "$file"
    done <<< "$(ListFiles "$dir")"

    while IFS= read -r folder; do
    ChangePermissions "$permissions" "$folder"
    done <<< "$(ListFolders "$dir")"
}


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
    local lineIndex="$(Trim "$1")"
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


function AddLine_First { AddLine 0 "$@"; }
function AddLine_Last {
    local lineContent="$1"
    local file="$(Trim "$2")"

    echo "$lineContent" >> "$file"
}
function ReplaceLine_ByString {
    local strToFind=$(Trim "$1")
    local lineContent="$(Trim "$2")"
    local file="$(Trim "$3")"

    local lineIndex="$(SmlIndexOf "$strToFind" "$(ReadFile "$file")")"

    ReplaceLine "$lineIndex" "$lineContent" "$file";
}
function ReplaceLine_First { ReplaceLine 0 "$@"; }


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

    blockStart="$(SmlGetLine_First "$blockIndexes")"
    blockEnd="$(SmlGetLine_Last "$blockIndexes")"


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


function Directory { GetFolder "$@"; }
function GetFolder { echo "$(dirname "$(Trim "$1")")"; }


function TransferFiles_Git { TransferFiles "git" "$@"; }
function TransferFiles_Normal { TransferFiles "normal" "$@"; }
function TransferFiles {
    local transferType="$(LCase "$(Trim "$1")")"
    local fromDir="$(SwitchDirSymbols_File "$2")"
    local toDir="$(SwitchDirSymbols_Folder "$3")"


    if $(DirectoryNotExists "$fromDir"); then return; fi


    local fromDirPermissions="$(GetPermissions "$(Directory "$fromDir")")"
    local target="$toDir""$(GetFileName "$fromDir")"


    $(DirectoryNotExists "$toDir") && CreateFolder "$toDir"
    if [[ "$transferType" == "git" ]]; then
    GitSync "$fromDir" "$toDir"
    elif $(IsAny "$transferType" "normal" "default"); then
    sudo rsync -aAXv "$fromDir" "$toDir"
    fi
    sudo chmod "$fromDirPermissions" "$target"
}


function Wait_EndOfChanges {
    # EXAMPLE: Waiting 5 Min / 30 Seconds to end this Changes
    # Wait_EndOfChanges 300


    local waitTime=$(IfTrimNotEmpty "$1" "30")
    local folder="$(IfTrimNotEmpty "$2" "$PWD")"
    folder="$(SwitchDirSymbols_Folder "$folder")"

    local fileStatus="$(StatusFile true)"
    local keepWaiting=true


    onchange "$folder**/*" -- sed -i "1 s/^.*$/true/" "$fileStatus" &
    StatusFile_WriteStatus "true" "$fileStatus"

    while $keepWaiting; do
        StatusFile_WriteStatus "false" "$fileStatus"
        sleep $waitTime
        keepWaiting=$(StatusFile_GetStatus "$fileStatus")
    done


    # Removing Temp Data
    KillProcessesPID "onchange"
    sudo rm -f "$fileStatus"
    # There were No changes for this Amount of Time: $waitTime
}

function Wait_EndOfChanges_File {
    # EXAMPLE: Waiting 5 Min / 30 Seconds to end this Changes
    # Wait_EndOfChanges 300


    local waitTime=$(IfTrimNotEmpty "$1" "30")
    local file="$(IfTrimNotEmpty "$2" "$PWD")"
    file="$(SwitchDirSymbols_File "$file")"

    local fileStatus="$(StatusFile true)"
    local keepWaiting=true


    onchange "$file" -- sed -i "1 s/^.*$/true/" "$fileStatus" &
    StatusFile_WriteStatus "true" "$fileStatus"

    while $keepWaiting; do
        StatusFile_WriteStatus "false" "$fileStatus"
        sleep $waitTime
        keepWaiting=$(StatusFile_GetStatus "$fileStatus")
    done


    # Removing Temp Data
    KillProcessesPID "onchange"
    sudo rm -f "$fileStatus"
    # There were No changes for this Amount of Time: $waitTime
}
