
package_dependencies(){
  if is_windows ; then
    echo "perl zlib"
  else
    echo "zlib"
  fi
}

package_build_install(){
  get_perl_exe(){(
    load_package perl &&
    invoke_function package_perl_root | append /bin/perl.exe
  )}
  openssl_build_install_script(){
    if is_windows ; then
      invoke_function get_perl_exe | pass -if file_exists | to_echo_function perl_exe_file
      invoke_function perl_exe_file | is_empty && return 1
      echo -E "\$ENV:INCLUDE+=$(project_root | append /include | convert_path | prefix ';' | double_quote)"
      echo -E "& $(perl_exe_file | convert_path | double_quote) ..."
    else
      echo -E "export CFLAGS='-I$(project_root | append /include) -L$(project_root | append /lib)'"
      echo -E "perl ..."
    fi
    echo -E "$(get_source_path | append /Configure | convert_path | double_quote) ..."
    echo -E "--prefix=$(project_root | convert_path | double_quote) ..."
    echo -E "--libdir=lib --openssldir=etc no-asm no-deprecated no-legacy no-tests no-docs shared zlib-dynamic"
    if is_windows ; then
     echo -E 'nmake /NOLOGO /S build_sw ; if(! $?){ exit 1 }'
     echo -E 'nmake /NOLOGO /S install_sw'
    else
     echo -E "make -j $(nproc | double_quote) build_sw"
     echo -E "make install_sw"
    fi
  }
  if openssl_build_install_script | generate_build_script | execute_build_script ; then
    if is_windows ; then
      find "$(project_root | append /bin)" -type f -name '*.pdb' | pass -if file_exists | pass rm
    fi
    project_root | append /lib/engines-3 | pass -if directory_exists | pass rmdir
    project_root | append /lib/ossl-modules | pass -if directory_exists | pass rmdir
    return 0
  else
    return 1
  fi
}
