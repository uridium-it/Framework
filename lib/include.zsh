
include(){
  local cache_file cache_dir include_file
  include_file="$(root_dir)/${1}"
  cache_file="$(root_dir)/.cache/include/${1}"
  if [ -f "${cache_file}" ] ; then
    if [ "${include_file}" -nt "${cache_file}" ] ; then
      source "${include_file}" >"${cache_file}"
    else
      source "${cache_file}"
    fi
  else
    [ ! -f "${include_file}" ] && {
      echo "${include_file} : file not found" >/dev/stderr
      return 1
    }
    cache_dir="$(dirname "${cache_file}")"
    [ -d "${cache_dir}" ] || mkdir -p "${cache_dir}"
    source "${include_file}" >"${cache_file}"
  fi
}
