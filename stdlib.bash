readonly std_true=0
readonly std_false=1

declare -a std_sourced=()

function std_source {
  # keeps std_sourced in sync with what has been sourced
  # you probably want std_require instead
  readonly target="$(realpath "$1")"
  if source "$target"; then
    std_sourced+=("$target")
    return $std_true
  fi

  return $std_false
}

function std_require {
  local needle="$1"
  local -a lib_path
  local lib_dir
  local sourced
  local target

  IFS=':' read -a lib_path <<<"${XDG_DATA_HOME:-"$HOME/.local/share"}:$XDG_DATA_DIRS"
  for lib_dir in "${lib_path[@]}"; do
    local lib="$lib_dir/bash/lib/$needle"
    if [[ -s "$lib" ]]; then
      target="$lib"
      break
    fi
  done

  # final fallback to filepath
  if [[ -z "$target" && -s "$needle" ]]; then
    target="$(realpath "$needle")"
  fi

  # unable to source
  if [[ -z "$target" ]]; then
    return $std_false
  fi

  for sourced in "${std_sourced[@]}"; do
    if [[ "$sourced" == "$target" ]]; then
      return $std_true
    fi
  done
  
  if std_source "$target"; then
    return $std_true
  else
    return $std_false
  fi
}

