
make_boolean_function is_windows 'uname | grep -q MSYS'
make_boolean_function is_osx 'uname | grep -q Darwin'
make_boolean_function is_linux 'uname | grep -q Linux'

if is_windows ; then
  gnu_sed(){ sed "${@}" ; }
  gnu_grep(){ grep "${@}" ; }
  gnu_tar(){ tar "${@}" ; }
  gnu_awk(){ awk "${@}" ; }
  gnu_find(){ find "${@}" ; }
elif is_linux; then
  gnu_sed(){ sed "${@}" ; }
  gnu_grep(){ grep "${@}" ; }
  gnu_tar(){ tar "${@}" ; }
  gnu_awk(){ awk "${@}" ; }
  gnu_find(){ find "${@}" ; }
elif is_osx; then
  osx_brew_root(){ app_tools_dir | append /brew ; }
  make_alias(){
    if osx_brew_root | append "/bin/${2}" | file_exists ; then
      eval "${1}(){ $(osx_brew_root)/bin/${2}"' "${@}" ; }'
    fi
  }
  make_alias 'gnu_sed' 'gsed'
  make_alias 'gnu_grep' 'ggrep'
  make_alias 'gnu_tar' 'gtar'
  make_alias 'gnu_find' 'gfind'
  make_alias 'jq' 'jq'
  make_alias 'xz' 'xz'
  make_alias 'cmake' 'cmake'
  nproc(){ sysctl -n hw.physicalcpu ; }
fi

convert_path_msys_to_windows(){ gnu_sed 's%^\(/\)\([a-z]\)/%\U\2:/%1' ; }
convert_to_forward_slash(){ gnu_sed 's%\\%/%g' ; }
convert_to_backward_slash(){ gnu_sed 's%/%\\%g' ; }
convert_path_windows_to_msys(){ convert_to_forward_slash | gnu_sed 's%^\([A-z]\)\(:/\)%/\L\1/%1' ; }

if is_windows ; then
  echo -E "${USERPROFILE}" | convert_path_windows_to_msys | to_echo_function home
  echo -E "${APPDATA}/Framework" | convert_path_windows_to_msys | to_echo_function app_data_dir
  echo -E "${APPDATA}/Framework/tools" | convert_path_windows_to_msys | to_echo_function app_tools_dir
  echo -E "${ORIGINAL_TMP}/Framework" | convert_path_windows_to_msys | to_echo_function tmp_home
  convert_path(){ convert_path_msys_to_windows ; }
  convert_back(){ convert_path_windows_to_msys ; }
  convert_dots(){ gnu_sed 's%\.\.\.$%`%' ; }
else
  echo -E "${HOME}" | to_echo_function home
  app_data_dir(){ echo -E "$(home)/Framework.data" ; }
  app_tools_dir(){ echo -E "$(home)/Framework.data/tools" ; }
  tmp_home(){ echo -E "/tmp/Framework" ; }
  convert_path(){ tee ; }
  convert_back(){ tee ; }
  convert_dots(){ gnu_sed 's%\.\.\.$%\\%' ; }
fi

remove_directory(){
  echo "${1}" | pass -if directory_exists | pass rm -rf
}

clean_directory(){
  remove_directory "${1}"
  echo "${1}" | pass mkdir -p
}

remove_project_root(){ gnu_sed "s%^$(project_root)%%;s%^/%%" ; }

load_json_file(){(
  json_to_zsh(){
    local json
    pass cat | to_var json
    a(){ echo "${json}" | jq -r ".${1}|keys[]" | pass b "${1}"; }
    b(){ echo "${json}" | jq -r ".${1}.${2}" | pass c "${1}_${2}" ; }
    c(){ eval "echo \"${2}\"" | pass concatenate "${1}(){ echo -E '" "' ; }"; }
    echo "${json}" | jq -r "keys[]" | pass a
  }
  (){
    local json_file_path json_file_name cache_file_path
    json_file_path="$(root_dir)/${1}"
    make_cache_file(){ echo "${json_file_path}" | json_to_zsh >"${cache_file_path}" ; }
    root_dir | append "/.cache/json" | run_if directory_not_exists mkdir -p
    basename "${json_file_path}" | to_var json_file_name
    root_dir | append "/.cache/json/${json_file_name}.zsh" | to_var cache_file_path
    echo "${cache_file_path}" | run_if file_not_exists make_cache_file
    [ "${json_file_path}" -nt "${cache_file_path}" ] && make_cache_file
    echo "${cache_file_path}"
  } "${1}"
  ) | pass cat | pass -accumulate eval
}

file_fetcher(){
  dirname "${2}" | pass mkdir -p
  curl -k -L -o "${2}" "${1}" ||
  wget -nd -O "${2}" "${1}"
}

for i in is_windows is_osx is_linux convert_path_msys_to_windows convert_to_forward_slash convert_to_backward_slash \
convert_path_windows_to_msys home app_data_dir app_tools_dir tmp_home convert_path convert_back convert_dots \
remove_directory clean_directory remove_project_root load_json_file gnu_sed gnu_grep gnu_tar gnu_awk gnu_find jq xz cmake nproc file_fetcher ; do
  declare -f "${i}"
done