#!/bin/bash

declare -A weapons=(
  ['Straight Sword']=75
  ['Tainted Dagger']=54
  ['Imperial Sword']=90
  ['Edged Shuriken']=25
)

function print_array {
    eval "declare -A arg_array="${1#*=}
    for i in "${!arg_array[@]}"; do
       printf "%s\t%s\n" "$i ==> ${arg_array[$i]}"
    done
}

print_array "$(declare -p weapons)" 

