
make_basic_directories(){
  {
    tmp_home
    app_data_dir
    app_tools_dir
    project_root | append /etc/packages
    project_root | append /bin
    project_root | append /lib
    project_root | append /include
  } | silent pass mkdir -p
}

return_ok_if_already_installed(){
  [[ "${1}" != "-f" ]] &&
  if manifest_path | file_exists ; then
    echo "Package $(package_name | double_quote) is already installed"
    return 0
  fi
}

make_before_build_file(){
  if manifest_path | file_not_exists ; then
    project_root | pass -first gnu_find -type f >"$(tmp_home | append /before_build)"
  fi
}

prepare_source_dir(){
  if source_package_path | file_not_exists ; then
    download_source_package || {
      echo "prepare_source_dir() : error downloading source code" | to_stderr
      return 1
    }
  fi
  { tmp_home | append /source_dir ; tmp_home | append /build_dir ; } | pass clean_directory
  source_package_path | pass xz -T0 -dc | tar x -C "$(tmp_home | append /source_dir)" || {
    echo "prepare_source_dir() : error while compressing the source code repository" | to_stderr
    return 1
  }
}

invoke_package_build_install(){(
  tmp_home | append /build_dir | pass cd || return 1
  get_source_path(){ tmp_home | append /source_dir ; }
  get_build_path(){ tmp_home | append /build_dir ; }
  invoke_function package_build_install
)}

make_manifest(){
  if manifest_path | file_not_exists ; then
    if tmp_home | append /after_build | file_not_exists ; then
      project_root | pass -first gnu_find -type f >"$(tmp_home | append /after_build)"
    fi
    root_dir | append /etc/packages | pass mkdir -p
    sort "$(tmp_home | append /before_build)" "$(tmp_home | append /after_build)" | uniq -u | remove_project_root >"$(manifest_path)"
    manifest_path | remove_project_root >>"$(manifest_path)"
  fi
}

final(){
  { tmp_home | append /source_dir ; tmp_home | append /build_dir ; tmp_home | append /execute_build_script ; } | pass remove_directory
  { tmp_home | append /before_build ; tmp_home | append /after_build ; } | pass rm -f
}

echo | add_function make_basic_directories | add_function return_ok_if_already_installed | add_chain make_before_build_file prepare_source_dir \
invoke_package_build_install make_manifest | add_final_statement final | to_function build_install

declare -f build_install
