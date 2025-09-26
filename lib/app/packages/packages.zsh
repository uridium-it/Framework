
manifest_path(){ project_root | append "/etc/packages/$(package_name).manifest.txt" ; }

require manifest_path package_name

load_package(){
  silent unset -f package_build_install package_build_type package_dependencies package_update_source \
    package_name package_source_url package_version
  (){
      local sh_file json_file
      root_dir | append "/packages/${1}.zsh" | to_var sh_file
      [[ ! -f "${sh_file}" ]] && {
        echo "load_package() : ${sh_file} : file not found" | to_stderr
        return 1
      }
      root_dir | append "/packages/${1}.json" | to_var json_file
      [[ ! -f "${json_file}" ]] && {
        echo "load_package() : $(root_dir)/packages/${1}.json : file not found" | to_stderr
        return 1
      }
      load_json_file "packages/${1}.json" || {
       echo "load_package() : ${json_file} : error loading file" | to_stderr
       return 1
      }
      source "${sh_file}" || {
        echo "load_package() : ${sh_file} : error loading file" | to_stderr
        return 1
      }
      return 0
  } "${1}" || {
    silent unset -f package_build_install package_build_type package_dependencies package_update_source \
      package_name package_source_url package_version
      echo "load_package() : no package loaded" | to_stderr
    return 1
  }
}

load_package_json(){
  silent unset -f package_build_type package_dependencies \
    package_name package_source_url package_version
  (){
      local json_file
      root_dir | append "/packages/${1}.json" | to_var json_file
      [[ ! -f "${json_file}" ]] && {
        echo "load_package_json() : $(root_dir)/packages/${1}.json : file not found" | to_stderr
        return 1
      }
      load_json_file "packages/${1}.json" || {
       echo "load_package_json() : ${json_file} : error loading file" | to_stderr
       return 1
      }
      return 0
  } "${1}" || {
    silent unset -f package_build_type package_dependencies \
      package_name package_source_url package_version
      echo "load_package_json() : no package loaded" | to_stderr
    return 1
  }
}

installation_order(){
  invoke_package_name_recursively(){(
   load_package "${1}" || return 1
   invoke_function package_dependencies | split_spaces | pass invoke_package_name_recursively &&
   invoke_function package_name
  )}
  echo "${@}" | split_spaces | pass -until invoke_package_name_recursively | first_occurrence
}

full_dependencies_list(){
  local list
  invoke_package_name_recursively(){(
    load_package "${1}" || return 1
    invoke_function package_dependencies | split_spaces | pass -until invoke_package_name_recursively &&
    invoke_function package_name
  )}
  if list="$(invoke_package_name_recursively "${1}")" ; then
    echo -E "${list}"
    return 0
  else
    return 1
  fi
}

declare -f load_package load_package_json package_system_loader manifest_path installation_order full_dependencies_list
