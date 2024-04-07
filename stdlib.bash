declare -ir std_true=0
declare -ir std_false=1

declare -a std_sourced

function std_source {
  # keeps std_sourced in sync with what has been sourced
  # you probably want std_require instead
  local target="$1"
  target="$(realpath "$target")"
  source "$target"
  std_sourced+=("$target")
}

function std_require {
  local target="$1"
  local -a lib_path
  local lib_dir

  IFS=':' read -a lib_path <<<"${XDG_DATA_HOME:-"$HOME/.local/share"}:$XDG_DATA_DIRS"
  for lib_dir in "${lib_path[@]}"; do
    local lib="$lib_dir/bash/lib/$target"
    if [[ -s "$lib" ]]; then
      std_source "$lib"
      return $std_true
    fi
  done

  # final fallback to current dir
  if [[ -s "$target" ]]; then
    std_source "$target"
    return $std_true
  fi

  return $std_false
}

