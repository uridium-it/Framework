
# This package is intended for Windows only, OSX has its own perl distribution, and so it does Linux

package_build_install(){
  if ! is_windows; then
    return 0
  fi
  if invoke_function package_perl_root | append /bin/perl.exe | file_exists ; then
    echo "Perl found, skipping package_build_install" | to_stderr
    return 0
  fi
  perl_build_install_script(){
    echo -E "cd $(get_source_path | append /win32 | convert_path | double_quote)"
    echo -E "nmake /S /NOLOGO INST_TOP=$(package_perl_root | convert_path | convert_to_backward_slash | double_quote) CCTYPE=MSVC143 install"
  }
  invoke_function perl_build_install_script | generate_build_script | execute_build_script || return 1
}
