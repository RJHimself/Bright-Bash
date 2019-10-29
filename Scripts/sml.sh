# SML - String Multi Line

function IsSml { (( $(CountLines "$1") > 1 )) && echo true || echo false; }


function SmlExecute  {
    local toExecute="$1"
    local thIsSml="$2"
    local finalSml="----"
    local lineResult


    while IFS= read -r line; do
        lineResult="$($toExecute "$line" "${@: 3}")"
        finalSml="$finalSml"$'\n'"$lineResult"
    done <<< "$thIsSml"

    finalSml="$(SmlCutLines_First "$finalSml")"


    echo "$finalSml"
}


function SmlTrim  { echo "$(SmlExecute "Trim" "$1")"; }
function SmlRTrim  { echo "$(SmlExecute "RTrim" "$1")"; }
function SmlLTrim  { echo "$(SmlExecute "LTrim" "$1")"; }


function SmlReverse  { echo "$(SmlExecute "Reverse" "$1")"; }
function ReverseLines { echo "$1" | awk '{a[i++]=$0} END {for (j=i-1; j>=0;) print a[j--] }'; }


function SmlSplit { echo "$(Replace "$1" "$nl" "$2")"; }
function SmlJoin {
    local joiner="$1"
    local string="$2"
    local finalResult

    while IFS= read -r element; do
    $(IsEmpty "$finalResult") && finalResult="$element" || finalResult="$finalResult""$joiner""$element"
    done <<< "$string"

    echo "$finalResult"
}


function CountLines { wc -l <<< "$1"; }


function SmlMerge {
    local SmlAmount="$#"
    local MainSml="$1"


    for NextSml in "$@"; do
    MainSml="$(SmlLacks "$MainSml" "$NextSml")"
    MainSml="$MainSml"$'\n'"$NextSml"
    done


    echo "$MainSml"
}
function SmlLacks {
    local elsContained
    local arrToFind="$1"
    local arrToCheck="$2"

    local found=false


    while IFS= read -r elToFind; do
        found=false

        while IFS= read -r elToCheck; do
        if [[ "$elToFind" == "$elToCheck" ]] && [[ $found == false ]]; then found=true; fi
        done <<< "$arrToCheck"

        if [[ $found == false ]]; then
        $(IsEmpty "$elsContained") && elsContained="$elToFind" || elsContained="$elsContained"$'\n'"$elToFind"
        fi
    done <<< "$arrToFind"


    echo "$elsContained"
}
function SmlContains {
    local elsContained
    local arrToFind="$1"
    local arrToCheck="$2"

    local found=false


    while IFS= read -r elToFind; do
        found=false

        while IFS= read -r elToCheck; do
        if [[ "$elToFind" == "$elToCheck" ]] && [[ $found == false ]]; then found=true; fi
        done <<< "$arrToCheck"

        if $found; then
        $(IsEmpty "$elsContained") && elsContained="$elToFind" || elsContained="$elsContained"$'\n'"$elToFind"
        fi
    done <<< "$arrToFind"


    echo "$elsContained"
}


function SmlReplace { echo "$(SmlExecute "Replace" "$1" "$2" "$3")"; }


function Top {
    local linesQty="$(Trim "$1")"
    local fullSml="$2"
    local stopAtLine="$linesQty"

    local currentLine=0
    local finalSml


    while IFS= read -r element; do

        if (( $currentLine < $stopAtLine )); then
        [[ $currentLine == 0 ]] && finalSml="$element" || finalSml="$finalSml"$'\n'"$element"
        fi

        let "currentLine++"
    done <<< "$fullSml"


    echo "$finalSml"
}
function Bottom {
    local linesQty="$(Trim "$1")"
    local fullSml="$2"
    local finalSml

    finalSml="$(ReverseLines "$fullSml")"
    finalSml="$(Top "$linesQty" "$finalSml")"
    finalSml="$(ReverseLines "$finalSml")"

    echo "$finalSml"
}


function SmlGetLine {
    local intLine="$1"
    local fullString="$2"
    local tmpIntLine=0


    while IFS= read -r line; do
    [[ $tmpIntLine == $intLine ]] && echo "$line"
    let "tmpIntLine++"
    done <<< "$fullString"
}
function SmlAddLines {
    local lineToAdd="$(Trim "$1")"
    local strNewLine="$2"
    local fullSml="$3"
    local finalSml

    local currentLine=0


    while IFS= read -r line; do
    if [[ $lineToAdd != $currentLine ]]; then
    [[ $currentLine != 0 ]] && finalSml="$finalSml"$'\n'"$line" || finalSml="$line"
    else
    [[ $currentLine != 0 ]] && finalSml="$finalSml"$'\n'"$strNewLine"$'\n'"$line" || finalSml="$strNewLine"$'\n'"$line"
    fi
    let "currentLine++"
    done <<< "$fullSml"


    echo "$finalSml"
}
function SmlCutLines {
    local lineToCut="$(Trim "$1")"
    local fullSml="$2"
    local finalSml

    local currentLine=0


    while IFS= read -r line; do
    if [[ $lineToCut != $currentLine ]]; then
    [[ $currentLine != 0 ]] && finalSml="$finalSml"$'\n'"$line" || finalSml="$line"
    fi
    let "currentLine++"
    done <<< "$fullSml"


    echo "$finalSml"
}
function SmlReplaceLine {
    local lineToReplace="$(Trim "$1")"
    local strToReplace="$2"
    local fullSml="$3"
    local finalSml

    local currentLine=0


    while IFS= read -r line; do
    if [[ $lineToReplace != $currentLine ]]; then
    [[ $currentLine != 0 ]] && finalSml="$finalSml"$'\n'"$line" || finalSml="$line"
    else
    [[ $currentLine != 0 ]] && finalSml="$finalSml"$'\n'"$strToReplace" || finalSml="$strToReplace"
    fi
    let "currentLine++"
    done <<< "$fullSml"


    echo "$finalSml"
}

function SmlGetLine_First { SmlGetLine 0 "$@"; }
function SmlGetLine_Last {
    local fullString="$1"

    local linesQty="$(CountLines "$fullString")"
    local lastLine="$(SmlGetLine $(($linesQty - 1)) "$fullString")"

    echo "$lastLine";
}
function SmlCutLines_First { echo "$1" | sed '1d'; }
function SmlCutLines_FirstLast { echo "$1" | sed '1d; $d; s/^ *//'; }
function SmlCutLines_Empty {
    local thIsSml="$1"
    local finalSml

    while IFS= read -r element; do
        if $(IsNotEmpty "$(Trim "$element")"); then
        $(IsEmpty $finalSml) && finalSml="$(Trim "$element")" || finalSml="$finalSml"$'\n'"$(Trim "$element")"
        fi
    done <<< "$thIsSml"

    echo "$finalSml"
}
function SmlCutLines_Clones {
    local thIsSml="$1"
    local finalSml


    while IFS= read -r element; do
    $(IsEmpty $finalSml) && finalSml="$(Trim "$element")" || finalSml="$finalSml"$'\n'"$(SmlLacks "$(Trim "$element")" "$finalSml")"
    done <<< "$thIsSml"

    finalSml="$(SmlCutLines_Empty "$finalSml")"


    echo "$finalSml"
}


function SmlIndexOf { echo "$(SmlIndexOfAt 0 "$1" "$2")"; }
function SmlIndexOfAt {
    local IntStart="$(Trim "$1")"
    local StrToFind="$2"
    local SmlEnglobber="$3"
    local CurrentLineIndex=0


    while IFS= read -r line; do
        if (( $CurrentLineIndex >= $IntStart )) && $(Contains "$StrToFind" "$line"); then
        echo "$CurrentLineIndex"; return;
        fi

        let "CurrentLineIndex++"
    done <<< "$SmlEnglobber"
}


function IndexOfBlock { IndexOfBlockAt 0 "$@"; }
function IndexOfBlockAt {
    # Example
    # IndexOfBlockAt 0 "Some
    # Things Come
    # In Blocks XDDD" "$(ReadFile ./some.sh)"


    local intStart="$(Trim "$1")"
    local smlBlockToFind="$2"
    local smlEnglobber="$3"

    local -A blockToFind
    local currentLineIndex=0
    local blockLineIndex=1
    local blockIndex=-1
    local blockLinesQty="$(CountLines "$smlBlockToFind")"


    currentLineIndex=1
    while IFS= read -r line; do
        blockToFind[$currentLineIndex]="$line"
        let "currentLineIndex++"
    done <<< "$smlBlockToFind"


    function AllowPassage {
        local line="$1"


        if (( $currentLineIndex < $intStart)); then echo false; return; fi

        if $(IsNotEmpty "$(Trim "$blockLine")") &&
        $(IsEmpty "$(Trim "$line")"); then echo false; return; fi

        if $(IsEmpty "$(Trim "$blockLine")") &&
        $(IsNotEmpty "$(Trim "$line")"); then echo false; return; fi

        if $(Lacks "$blockLine" "$line"); then echo false; return; fi

        echo true
    }

    currentLineIndex=0
    while IFS= read -r line; do
        local blockLine="${blockToFind[$blockLineIndex]}"


        if $(AllowPassage "$line"); then
            [[ $blockLineIndex == 1 ]] && blockIndex="$currentLineIndex"
            if [[ $blockLinesQty == $blockLineIndex ]]; then echo "$blockIndex"; return; fi
            let "blockLineIndex++"
        else blockLineIndex=1;
        fi

        let "currentLineIndex++"
    done <<< "$smlEnglobber"


    echo -1
}
function IndexOfAllBlocks { IndexOfAllBlocksAt 0 "$@"; }
function IndexOfAllBlocksAt {
    # Example
    # IndexOfBlockAt 0 "Some
    # Things Come
    # In Blocks XDDD" "$(ReadFile ./some.sh)"


    local intStart="$(Trim "$1")"
    local smlBlockToFind="$2"
    local smlEnglobber="$3"

    local -A blockToFind
    local currentLineIndex=0
    local blockLineIndex=1
    local blockIndex=-1
    local blockLinesQty="$(CountLines "$smlBlockToFind")"

    local allBlocks


    currentLineIndex=1
    while IFS= read -r line; do
        blockToFind[$currentLineIndex]="$line"
        let "currentLineIndex++"
    done <<< "$smlBlockToFind"


    function AllowPassage {
        local line="$1"


        if (( $currentLineIndex < $intStart)); then echo false; return; fi

        if $(IsNotEmpty "$(Trim "$blockLine")") &&
        $(IsEmpty "$(Trim "$line")"); then echo false; return; fi

        if $(IsEmpty "$(Trim "$blockLine")") &&
        $(IsNotEmpty "$(Trim "$line")"); then echo false; return; fi

        if $(Lacks "$blockLine" "$line"); then echo false; return; fi

        echo true
    }

    currentLineIndex=0
    while IFS= read -r line; do
        local blockLine="${blockToFind[$blockLineIndex]}"


        if $(AllowPassage "$line"); then
            [[ $blockLineIndex == 1 ]] && blockIndex="$currentLineIndex"
            if [[ $blockLinesQty == $blockLineIndex ]]; then allBlocks="$allBlocks"$'\n'"$blockIndex"; fi
            let "blockLineIndex++"
        else blockLineIndex=1;
        fi

        let "currentLineIndex++"
    done <<< "$smlEnglobber"

    allBlocks="$(SmlTrim "$(SmlCutLines_Empty "$allBlocks")")"

    $(IsNotEmpty "$allBlocks") && echo "$allBlocks" || echo -1
}
function CountBlocks { CountBlocksAt 0 "$@"; }
function CountBlocksAt {
    # Example
    # IndexOfBlockAt 0 "Some
    # Things Come
    # In Blocks XDDD" "$(ReadFile ./some.sh)"


    local intStart="$(Trim "$1")"
    local smlBlockToFind="$2"
    local smlEnglobber="$3"

    local -A blockToFind
    local currentLineIndex=0
    local blockLineIndex=1
    local blockIndex=-1
    local blockLinesQty="$(CountLines "$smlBlockToFind")"
    local blocksAmount=0


    currentLineIndex=1
    while IFS= read -r line; do
        blockToFind[$currentLineIndex]="$line"
        let "currentLineIndex++"
    done <<< "$smlBlockToFind"


    function AllowPassage {
        local line="$1"


        if (( $currentLineIndex < $intStart)); then echo false; return; fi

        if $(IsNotEmpty "$(Trim "$blockLine")") &&
        $(IsEmpty "$(Trim "$line")"); then echo false; return; fi

        if $(IsEmpty "$(Trim "$blockLine")") &&
        $(IsNotEmpty "$(Trim "$line")"); then echo false; return; fi

        if $(Lacks "$blockLine" "$line"); then echo false; return; fi

        echo true
    }

    currentLineIndex=0
    while IFS= read -r line; do
        local blockLine="${blockToFind[$blockLineIndex]}"


        if $(AllowPassage "$line"); then
            [[ $blockLineIndex == 1 ]] && blockIndex="$currentLineIndex"
            [[ $blockLinesQty == $blockLineIndex ]] && let "blocksAmount++"
            let "blockLineIndex++"
        else blockLineIndex=1;
        fi

        let "currentLineIndex++"
    done <<< "$smlEnglobber"


    echo $blocksAmount
}


function GetBlockIndexes { GetBlockIndexesAt 0 "$@"; }
function GetBlockIndexesAt {
    local startAt="$(Trim "$1")"
    local blockStart="$2"
    local blockEnd="$3"
    local content="$4"

    local blockStartAt=$(IndexOfBlockAt $startAt "$blockStart" "$content")
    [[ $blockStartAt != -1 ]] && startAt="$blockStartAt"
    local blockEndAt=$(IndexOfBlockAt $startAt "$blockEnd" "$content")

    local blockIndexes="$blockStartAt"$'\n'"$blockEndAt"


    echo "$blockIndexes"
}
function GetBlockIndexesOccurr {
    # EXAMPLE:
    # GetBlockIndexesOccurr 1 "Have" "things" "
    # At It
    # things
    # Have
    # Today
    # things
    # fry
    # Have
    # Oh ****

    # things
    # At It
    # "


    local occurrence=$(Trim "$1")
    local blockStart="$2"
    local blockEnd="$3"
    local content="$4"

    local allBlockStartIndex="$(IndexOfAllBlocks "$blockStart" "$content")"
    local startAt="$(SmlGetLine $occurrence "$allBlockStartIndex")"

    local blockIndexes="$(GetBlockIndexesAt "$startAt" "$blockStart" "$blockEnd" "$content")"


    echo "$blockIndexes"
}
