
cmake_build_install(){
  {
    (){
        echo -E "cmake ${*} ..."
        echo -E "-B $(tmp_home | append /build_dir | convert_path | double_quote) ..."
        echo -E "-DCMAKE_INSTALL_PREFIX=$(project_root | convert_path | double_quote) ..."
        echo -E "$(tmp_home | append /source_dir | convert_path | double_quote)"
      } "${@}"
    (){
        echo -E "cmake --build $(tmp_home | append /build_dir | convert_path | double_quote) ..."
        echo -E "--config $(package_build_type) ..."
        echo -E "--parallel $(nproc) ..."
        echo -E "--target install"
      }
  } | generate_build_script | execute_build_script
}

make_manifest(){
  [ $? -ne 0 ] && return 1
  if manifest_path | file_not_exists ; then
    echo >> "$(tmp_home | append /build_dir/install_manifest.txt)"
    project_root | append /etc/packages | pass mkdir -p
    tmp_home | append /build_dir/install_manifest.txt | pass cat | gnu_sed 's%\r%%g' | convert_back | remove_project_root >"$(manifest_path)"
    manifest_path | remove_project_root >>"$(manifest_path)"
  fi
  return 0
}

echo | add_function cmake_build_install | add_function make_manifest | to_function cmake_build_install

declare -f cmake_build_install