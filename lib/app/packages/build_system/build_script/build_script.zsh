
generate_build_script(){
  if is_windows; then
    echo -E "& $(app_tools_dir | append '/vs_build_tools/Common7/Tools/Launch-VsDevShell.ps1' | convert_path | double_quote) -Arch \${Env:PROCESSOR_ARCHITECTURE}"
  elif is_osx; then
    echo -E 'CC=clang ; CXX=clang++ ; export CC CXX'
  elif is_linux; then
    echo -E 'CC=gcc ; CXX=g++ ; export CC CXX'
  fi
  echo -E "cd $(tmp_home | append /build_dir | convert_path | double_quote)"
  tee | convert_dots
}

require generate_build_script app_tools_dir

execute_build_script(){
  local tmp_file shell_script_extension execution_shell
  if is_windows; then
    echo 'ps1' | to_var shell_script_extension
    {
      no_error gnu_find "$(app_tools_dir | append /pwsh)" -name pwsh.exe -type f ||
      no_error gnu_find '/c/Windows/System32/WindowsPowerShell' -name powershell.exe -type f
    } | first_line | pass -if file_exists | convert_path | to_var execution_shell
  else
    echo 'zsh' | to_var shell_script_extension
    whence zsh | first_line | to_var execution_shell
  fi
  tmp_home | append "/execute_build_script" | pass clean_directory
  tmp_home | append "/execute_build_script" | append "/runscript.${shell_script_extension}" | to_var tmp_file
  tee >"${tmp_file}"
  if is_windows ; then
    echo -E 'if(! $?){ exit 1 }' >>"${tmp_file}"
  fi
  echo "Package $(package_name | single_quote), build install script:"
  cat "${tmp_file}"
  "${execution_shell}" "${tmp_file}" || {
    echo "execute_build_script() : the build script returned an error" | to_stderr
    return 1
  }
}

require execute_build_script package_name

declare -f generate_build_script
declare -f execute_build_script
