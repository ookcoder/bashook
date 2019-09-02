#!/bin/bash
declare -a ooks
declare -a chars
ooks=("oO" "Oooo" "OoOo" "Ooo" "o" "ooOo" "OOo" "oooo" "oo" "oOOO" "OoO" "oOoo" "OO" "Oo" "OOO" "oOOo" "OOoO" "oOo" "ooo" "O" "ooO" "oooO" "oOO" "OooO" "OoOO" "OOoo" "OOOOO" "oOOOO" "ooOOO" "oooOO" "ooooO" "ooooo" "Ooooo" "OOooo" "OOOoo" "OOOOo" "k ")
chars=("a" "b" "c" "d" "e" "f" "g" "h" "i" "j" "k" "l" "m" "n" "o" "p" "q" "r" "s" "t" "u" "v" "w" "x" "y" "z" "0" "1" "2" "3" "4" "5" "6" "7" "8" "9" " ")
nflag=""
eflag=""
space="k "
sep="0"

usage() { 
  echo "Usage: $0 ...strings [-n] [-e]" 1>&2; 
  echo "By defaul strings that looks encoded will be decoded." 1>&2;
  exit 1; 
  }

find() {
  local i=0
  if [[ "$1" = "ooks" ]]; 
  then
    for i in "${!ooks[@]}"; 
    do
      if [[ ${ooks[$i]} = $2 ]]; 
      then
        return $i
      fi
    done
  else
    for i in "${!chars[@]}"; 
    do
      if [[ ${chars[$i]} = $2 ]]; 
      then
        return $i
      fi
    done
  fi

  return -1
}


while getopts "ne" opt; do
  case $opt in
    n) nflag="true";;
    e) eflag="true";;
    *) 
       usage
        #echo "Unexpected flag ${opt}" >&2
       exit 1
  esac
done
shift $((OPTIND-1))

if [[ $# -eq 0 ]]; 
then
  usage
  exit 1
fi

s=""
if [[ $1 =~ ^([Oo0k\s])+$ ]] && [[ ! $eflag = "true" ]]; 
then
  numWords=$#
  for (( i=1; i<=$numWords; i++ )); 
  do
    str=${!i}
    str=$(echo $str | sed "s/0/ /g")
    IFS=" " read -a codes <<< "$str"
    numCodes=${#codes[*]}
    for (( j=0; j<$numCodes; j++ )); 
    do
      code=${codes[$j]}
      if [[ $code = "k" ]]; then
        code="k "
      fi
      find "ooks" "$code"
      res=$?
      s="$s${chars[$res]}"
    done
  done
else
  # encode
  # word
  numWords=$#
  for (( i=1; i<=$numWords; i++ )); 
  do
    var=${!i}
    varLen=${#var}
    # prepend 0 if we need
    if [[ $i -gt 1 ]]; 
    then
      s="$s$sep"
    fi
    # char
    for (( j=0; j<$varLen; j++ )); 
    do
      find "chars" "${var:$j:1}"
      res=$?
      s="$s${ooks[$res]}"
      s="$s$sep"
    done
    s="$s$space"
  done
fi

if [[ ! $nflag = "true" ]]; then
  echo -e $s | pbcopy 
fi

echo $s

