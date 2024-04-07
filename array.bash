# convenience functions for working with arrays
function std_array_remove {
  # Remove needle from haystack
  local needle="$1"
  local -n haystack="$2"

  local found=$std_false
  local -i i

  for ((i=0; i<${#haystack[@]}; i+=1)); do
    if [[ "${haystack[$i]}" == "$needle" ]]; then
      unset haystack[$i]
      found=$std_true
    fi
  done

  if [[ $found -eq $std_true ]]; then
    haystack=("${haystack[@]}") # remove any gaps
  fi
  return $found
}

function std_array_is_in {
  # Return if needle is in haystack
  local needle="$1"
  local -n haystack="$2"

  for hay in "${haystack[@]}"; do
    if [[ "$hay" == "$needle" ]]; then
      return $std_true
    fi
  done

  return $std_false
}

function std_array_dedupe {
  # ensure all entries of an array are unique
  local -n array="$1"

  local -a tmp
  for item in "${array[@]}"; do
    if ! std_array_is_in "$item" tmp; then
      tmp+=("$item")
    fi
  done

  array=("${tmp[@]}")
}

function std_array_join {
  # join entries of array with sep
  local -i i
  local sep="$1"
  local -n array="$2"
  
  printf "${array[0]}"
  for ((i=1; i<${#array[@]}; i+=1)); do
    printf "$sep${array[$i]}"
  done
}

