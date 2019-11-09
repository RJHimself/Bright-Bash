function IsEmpty { if [[ -z "$1" ]]; then echo true; else echo false; fi }
function IsNotEmpty { if [[ ! -z "$1" ]]; then echo true; else echo false; fi }


function IsAnyEmpty {
    for var in "$@"; do
    if $(IsEmpty "$var"); then echo true; return; fi
    done

    echo false
}
function IsAnyNotEmpty {
    for var in "$@"; do
    if $(IsNotEmpty "$var"); then echo true; return; fi
    done

    echo false
}


function Trim  { echo "$(echo -e "$1" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"; }
function LTrim { echo "$(echo -e "$1" | sed -e 's/^[[:space:]]*//')"; }
function RTrim { echo "$(echo -e "$1" | sed -e 's/[[:space:]]*$//')"; }
function TrimAll { echo "$(echo -e "${FOO}" | tr -d '[:space:]')"; }


function Reverse { echo "$1" | rev; }


function TextAfter { MidToEnd_ByString "$@"; }


function Left {
    local length="$1"
    local string="$2"

    echo "${string: 0:$length}"
}
function Right {
    local length="$1"
    local string="$2"

    echo "${string: -$length}"
}
function Mid {
    local intLeft="$1"
    local intRight="$2"
    local string="$3"

    echo "${string: $intLeft:$intRight}"
}


function MidToStart {
    local length="$1"
    local string="$2"

    echo "${string: 0:$length}"
}
function MidToEnd {
    local length="$1"
    local string="$2"

    echo "${string: $length}"
}

function MidToEnd_ByString {
    local strBefore="$(Trim "$1")"
    local strEnglobber="$(Trim "$2")"
    local indexOfAfter="$(($(Length "$strBefore") + $(IndexOf "$strBefore" "$strEnglobber")))"
    local textAfter="$(MidToEnd $indexOfAfter "$strEnglobber")"

    echo "$textAfter"
}


function Exclude_First {
    local amount="$(Trim "$1")"
    local string="$(Trim "$2")"

    local strLength="$(Length "$string")"
    local finalString="${string: $amount:$strLength}"

    echo "$finalString"
}
function Exclude_Last {
    local amount="$(Trim "$1")"
    local string="$(Trim "$2")"

    local strLength="$(Length "$string")"
    local finalString="${string: 0:$(($strLength-$amount))}"

    echo "$finalString"
}
function Exclude_FirstLast {
    local amount="$(Trim "$1")"
    local string="$(Trim "$2")"

    local finalString="$string"


    finalString="$(Exclude_First "$amount" "$finalString")"
    finalString="$(Exclude_Last "$amount" "$finalString")"


    echo "$finalString"
}


function AddToEnd_IfNotContains {
    local strToFind="$1"
    local strEnglobber="$2"

    [[ $(Right $(Length "$strToFind") "$strEnglobber") != "$strToFind" ]] && strEnglobber="$strEnglobber""$strToFind"

    echo "$strEnglobber"
}


function Capitalize {
    local oldStr="$(LCase "$1")"
    local newStr

    local smlOldStr
    local smlNewStr


    for word in $oldStr; do
    $(IsEmpty "$smlOldStr") && smlOldStr="$word" || smlOldStr="$smlOldStr"$'\n'"$word"
    done
    for word in $oldStr; do
    firstChar=$(echo -n "${word:0:1}" | tr "[:lower:]" "[:upper:]")
    $(IsEmpty "$smlNewStr") && smlNewStr="$firstChar${word: 1}" || smlNewStr="$smlNewStr"$'\n'"$firstChar${word: 1}"
    done

    smlOldStr="$(SmlTrim "$smlOldStr")"
    smlNewStr="$(SmlTrim "$smlNewStr")"

    for (( i = 0; i < $(CountLines "$smlOldStr"); i++ )); do
    oldStr="$(Replace "$(SmlGetLine $i "$smlOldStr")" "$(SmlGetLine $i "$smlNewStr")" "$oldStr")"
    done


    [[ "${oldStr: 0:1}" == " " ]] && oldStr="${oldStr: 1}"
    echo "$oldStr"
}
function LCase { echo "$(echo "$1" | tr '[:upper:]' '[:lower:]')"; }
function UCase { echo "$(echo "$1" | tr '[:lower:]' '[:upper:]')"; }


function FirstLCase { echo "$(LCase "$(FirstUCase "$1")")"; }
function FirstUCase {
    local string="$(UCase "$(Trim "$1")")"
    string="$(Left 1 "$string")"

    echo "$string"
}


function Lacks { $(Contains "$@") && echo false || echo true; }
function Contains {
    local strtoFind="$1"
    local strEnglobber="$2"
    [[ $(echo "$strEnglobber" | grep "$strtoFind" | wc -l) > 0 ]] && echo true || echo false
}


function ContainsAny {
    local strEnglobber="$1"

    for toFind in "${@: 2}"; do
    if $(Contains "$toFind" "$strEnglobber"); then echo true; return; fi
    done

    echo false
}
function LacksAny {
    local strEnglobber="$1"

    for toFind in "${@: 2}"; do
    if $(Lacks "$toFind" "$strEnglobber"); then echo true; return; fi
    done

    echo false
}


function IsWord { [[ "$1" == "$2" ]] && echo true || echo false; }
function IsNotWord { $(IsWord "$@") && echo false || echo true; }

function IsChar { IsWord "$@"; }
function IsNotChar { $(IsChar "$@") && echo false || echo true; }


function IsAny {
    local strEnglobber="$1"

    for toFind in "${@: 2}"; do
    if [[ "$toFind" == "$strEnglobber" ]]; then echo true; return; fi
    done

    echo false
}
function IsNotAny {
    local strEnglobber="$1"

    for toFind in "${@: 2}"; do
    if [[ "$toFind" != "$strEnglobber" ]]; then echo true; return; fi
    done

    echo false
}


function Length { local thisVar="$1"; echo ${#thisVar}; }


function CountTimes {
    local count=0
    local strToFind="$1"
    local strEnglober="$2"


    while IFS= read -r line; do
        qty="$(echo "${line}" | awk -F"${strToFind}" '{print NF-1}')"

        [[ $qty != "-1" ]] && [[ $qty != "0" ]] && let "count+=$qty"
    done <<< "$strEnglober"

    echo $count
}
function CountTimesAfter {
    local after="$1"
    local strToFind="$2"
    local strEnglober="$3"

    echo "$(CountTimes "$strToFind" "${strEnglober: $after}")";
}
function CountTimesBefore {
    local before="$1"
    local strToFind="$2"
    local strEnglober="$3"

    echo "$(CountTimes "$strToFind" "${strEnglober: 0:$before}")";
}


function IndexOf { echo "$(IndexOfAt 0 "$@")"; }
function IndexOf_Last {
    local strToFind="$1"
    local strEnglobber="$2"
    local lastOccurr="$(($(CountTimes "$strToFind" "$strEnglobber") - 1))"

    echo $(IndexOfOccur $lastOccurr "$strToFind" "$strEnglobber");
}
function IndexOfAt {
    local intStart="$1"
    local strToFind="$2"
    local strEnglobber="$3"

    local strFirst
    local strRest


    strEnglobber="${strEnglobber: $intStart}"
    strRest="${strEnglobber#*"$strToFind"}"
    strFirst="${strEnglobber%"$strRest"}"

    strToFindIndex=$(( ${#strFirst} - ${#strToFind} + $intStart ))


    $(Contains "$strToFind" "$strEnglobber") && echo "$strToFindIndex" || echo -1
}
function IndexOfOccurrences {
    local strToFind="$1"
    local strEnglober="$2"

    local times="$(CountTimes "$strToFind" "$strEnglober")"
    local lastIndex=-1
    local occurences


    for (( i = 0; i < $times; i++ )); do
    lastIndex="$(IndexOfAt $(($lastIndex + 1)) "$strToFind" "$strEnglober")"
    occurences="$occurences"$'\n'"$lastIndex"
    done

    occurences="$(SmlCutLines_Empty "$occurences")"
    occurences="$(SmlTrim "$occurences")"


    echo "$occurences"
}
function IndexOfOccur {
    local occurrTime="$1"
    local strToFind="$2"
    local strEnglober="$3"


    echo $(SmlGetLine $occurrTime "$(IndexOfOccurrences "$strToFind" "$strEnglober")")
}
function IndexOf_Multiple {
    local strEnglobber="$1"
    local indexes

    for toFind in "${@: 2}"; do
    indexes="$indexes"$'\n'"$(IndexOf "$toFind" "$strEnglobber")"
    done
    indexes="$(SmlCutLines_Empty "$indexes")"

    echo "$indexes"
}
function IndexOf_Lowest {
    local indexes="$(IndexOf_Multiple "$@")"
    local lowestIndex

    indexes="$(Sort "$indexes")"
    lowestIndex="$(Trim "$(SmlGetLine_First "$indexes")")"

    echo "$lowestIndex"
}


function ListBeforeIndexesOf {
    local strToFind="$1"
    local strEnglober="$2"
    local indexes="$(IndexOfOccurrences "$strToFind" "$strEnglober")"
    local list

    while IFS= read -r index; do
    list="$list"$'\n'"$(Left $index "$strEnglober")"
    done <<< "$indexes"

    list="$(SmlCutLines_Empty "$list")"
    echo "$list"
}
function ListAfterIndexesOf {
    local strToFind="$1"
    local strEnglober="$(Reverse "$2")"
    local list="$(SmlReverse "$(ListBeforeIndexesOf "$strToFind" "$strEnglober")")"

    echo "$list"
}


function Replace {
    local strToFind="$1"
    local strReplacer="$2"
    local strEnglobber="$3"
    local qty=$(CountTimes "$strToFind" "$strEnglobber")
    local restOfEnglobber

    local tmpStart=0
    local tmpEnd="${#strEnglobber}"
    local tmpPortion

    local finalResult


    for (( i = 0; i <= $qty; i++ )); do
        [[ $i != $qty ]] && tmpEnd=$(IndexOfAt $tmpStart "$strToFind" "$strEnglobber") || tmpEnd="${#strEnglobber}"
        tmpPortion="${strEnglobber: $tmpStart:$(($tmpEnd - $tmpStart))}"


        $(IsEmpty "$finalResult") && finalResult="$tmpPortion" || finalResult="$finalResult""$strReplacer""$tmpPortion"

        tmpStart=$(($tmpEnd + $(Length "$strToFind")))
    done


    $(Contains "$strToFind" "$strEnglobber") && echo "$finalResult" || echo "$strEnglobber"
}
function ReplaceChar {
    local strToFind="$1"
    local strReplacer="$2"
    local strEnglobber="$3"

    local finalResult="$(echo "$strEnglobber" | tr "$strToFind" "$strReplacer")"


    echo "$finalResult"
}


function GetChar {
    local index=$(Trim "$1")
    local strEnglobber="$2"

    echo "${strEnglobber: $index:1}"
}
