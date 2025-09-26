
package_build_install(){
  echo 'get_source_path | append "/${1}" | convert_path' | to_function sqlite_source
  echo 'get_build_path | append "/${1}" | convert_path' | to_function sqlite_build

  is_windows &&
  sqlite_build_script(){
    echo -E "\$ENV:INCLUDE+=$(get_source_path | convert_path | prefix ';' | double_quote)"
    echo -E "cl $(sqlite_source shell.c | double_quote) $(sqlite_source sqlite3.c | double_quote) -Fesqlite3"
    echo -E "cl $(sqlite_source sqlite3.c | double_quote) -link -dll -out:sqlite3.dll"
    echo -E "lib sqlite3.obj"
  }

  is_linux &&
  sqlite_build_script(){
    echo -E "CFLAGS='-I$(project_root | append /include)'"
    echo -E "gcc -fPIC -c $(sqlite_source shell.c | double_quote) $(sqlite_source sqlite3.c | double_quote) -lpthread -ldl -lm"
    echo -E "gcc -fPIC -shared sqlite3.o -lpthread -ldl -lm -o libsqlite3.so"
    echo -E "gcc -fPIC shell.o sqlite3.o -lpthread -ldl -lm -o sqlite3"
    echo -E "ar cr libsqlite3.a sqlite3.o"
  }

  is_osx &&
  sqlite_build_script(){
    echo -E "CFLAGS='-I$(project_root | append /include)'"
    echo -E "clang -c $(sqlite_source shell.c | double_quote) $(sqlite_source sqlite3.c | double_quote)"
    echo -E "clang -shared sqlite3.o -lpthread -o libsqlite3.dylib"
    echo -E "clang shell.o sqlite3.o -lpthread -o sqlite3"
    echo -E "ar cr libsqlite3.a sqlite3.o"
  }

  sqlite_install(){
    if is_windows; then
      \cp "$(sqlite_build sqlite3.exe)" "$(sqlite_build sqlite3.dll)" "$(project_root | append /bin)"
      \cp "$(sqlite_build sqlite3.lib)" "$(project_root | append /lib)"
      \cp "$(sqlite_source sqlite3.h)" "$(sqlite_source sqlite3ext.h)" "$(project_root | append /include)"
    elif is_linux; then
      \cp "$(sqlite_build sqlite3)" "$(project_root | append /bin)"
      \cp "$(sqlite_build libsqlite3.so)" "$(sqlite_build libsqlite3.a)" "$(project_root | append /lib)"
      \cp "$(sqlite_source sqlite3.h)" "$(sqlite_source sqlite3ext.h)" "$(project_root | append /include)"
    elif is_osx; then
      \cp "$(sqlite_build sqlite3)" "$(project_root | append /bin)"
      \cp "$(sqlite_build libsqlite3.dylib)" "$(sqlite_build libsqlite3.a)" "$(project_root | append /lib)"
      \cp "$(sqlite_source sqlite3.h)" "$(sqlite_source sqlite3ext.h)" "$(project_root | append /include)"
    fi
  }

  sqlite_build_script | generate_build_script | execute_build_script || return 1
  sqlite_install
}
