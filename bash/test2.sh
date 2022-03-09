#!/bin/bash

evaluate () {
  eval "declare -A args="${1#*=}
  echo "${args[options]}"
  echo "${args[destination]}"
  
  value="$1"
}
declare -A sio=([directory]="2" [options]="3" [destination]="6" [filename]="4" );

evaluate "$(declare -p sio)"
