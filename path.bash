# Convenience functions for working with PATH
std_require "array.bash"
std_require "termcolors.bash"

function std_path_print {
  # pretty print PATH
  local -a path
  local directory
  IFS=':' read -a path <<<"$PATH"
  for directory in "${path[@]}"; do
    if [[ ! -d "$directory" ]]; then
      printf "$std_colors_fg_red"
    fi
    printf "${directory}${std_colors_reset}\n"
  done
}

function std_path_dedupe {
  # make PATH only contain unique entries
  local -a path
  IFS=':' read -a path <<<"$PATH"
  std_array_dedupe path
  export PATH="$(std_array_join : path)"
}

function __std_path_remove_or_verify {
  # internal function for the override option of std_path_{append,prepend}
  local directory="$1"
  local -i override
  if [[ -z "$2" ]]; then
    override=$std_false
  else
    override=$std_true
  fi

  if [[ $override -eq $std_false ]] && \
    std_array_is_in "$directory" path
  then
    return $std_false
  fi

  std_array_remove "$directory" path
  return $std_true
}

function std_path_append {
  local directory="${1:?USAGE: std_path_append <directory> [overwrite]}"
  local override="$2"

  local -a path
  IFS=':' read -a path <<<"$PATH"
  std_path_remove_or_verify "$directory" "$override" || return $std_true
  path+=("$directory")
  export PATH="$(std_array_join : path)"
}

function std_path_prepend {
  local directory="${1:?USAGE: std_path_prepend <directory> [overwrite]}"
  local override="$2"

  local -a path
  IFS=':' read -a path <<<"$PATH"
  std_path_remove_or_verify "$directory" "$override" || return $std_true
  path=("$directory" "${path[@]}")
  export PATH="$(std_array_join : path)"
}

function path {
  # user interface to this lib
  case "$1" in
    'append' | '+=') std_path_append "$2" "$3" ;;
    'prepend') std_path_prepend "$2" "$3" ;;
    'depupe') std_path_dedupe ;;
    '') std_path_print ;;
    '*') return 1 ;;
  esac
}
