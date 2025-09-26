
function_exists(){ no_output declare -f "${1}" ; }
invoke_function(){ function_exists "${1}" &&  "${1}" "${@:2}" ; }

no_output(){ "${@}" >/dev/null ; }
no_error(){ "${@}" 2>/dev/null ; }
silent(){ "${@}" >/dev/null 2>/dev/null ; }
not(){ "${@}" || return 0 ; return 1 ; }

to_var(){ IFS=$'\n' read -r -d '' "${1}" ; return 0 ; }
to_stderr(){ tee >>/dev/stderr ; }
to_encoded_var(){ eval "${1}='$(tee | encode)'" ; }
encode(){ xxd -p ; }
decode(){ xxd -r -p ; }
decode_var(){ local cmd ; echo "${1}" | pass concatenate 'echo "${' '}"' | to_var cmd ; eval "${cmd}" | decode ; }

make_function(){ eval "${1}(){ ${2} ; }" ; }
to_function(){ make_function "${1}" "$(tee)" ; }
to_echo_function(){ pass concatenate 'echo -E "' \" | to_function "${1}" ; }
make_boolean_function(){ if eval "${2}"; then echo true ; else echo false ; fi | to_function "${1}" ; }

pass(){
  local i
  case "${1}" in
  '-accumulate-first') "${2}" "$(tee)" "${@:3}" ; return $? ;;
  '-accumulate') "${2}" "${@:3}" "$(tee)" ; return $? ;;
  '-pipe-to') while IFS= read -r i ; do [ -z "${i}" ] && continue ; echo -E "${i}" | "${2}" "${@:3}" ; done ;;
  '-pipe-to-until') while IFS= read -r i ; do [ -z "${i}" ] && continue ; echo -E "${i}" | "${2}" "${@:3}" || return 1 ; done ;;
  '-first') while IFS= read -r i ; do [ -z "${i}" ] && continue ; "${2}" "${i}" "${@:3}" ; done ;;
  '-first-until') while IFS= read -r i ; do [ -z "${i}" ] && continue ; "${2}" "${i}" "${@:3}" || return 1 ; done ;;
  '-until') while IFS= read -r i ; do [ -z "${i}" ] && continue ; "${2}" "${@:3}" "${i}" || return 1 ; done ;;
  '-if') while IFS= read -r i ; do [ -z "${i}" ] && continue ; echo -E "${i}" | silent "${2}" "${@:3}" && echo -E "${i}" ; done ;;
  '-if-not') while IFS= read -r i ; do [ -z "${i}" ] && continue ; echo -E "${i}" | silent "${2}" "${@:3}" || echo -E "${i}" ; done ;;
  *) while IFS= read -r i ; do [ -z "${i}" ] && continue ; "${1}" "${@:2}" "${i}" ; done ;;
  esac
}

run_if(){ local i ; to_var i ; echo "${i}" | "${1}" && "${2}" "${@:3}" "${i}" ; }

concatenate(){ echo -E "${1}${3}${2}" ; }
append(){ pass -first concatenate "${1}" ; }
prefix(){ pass concatenate "${1}" ; }
single_quote(){ pass concatenate \' \' ; }
double_quote(){ pass concatenate \" \" ; }

first_line(){ gnu_sed -n '1p' ; }
last_line(){ gnu_sed -n '$p' ; }
split_spaces(){ tr ' ' '\n' | gnu_sed '/^$/d' ; }

is_empty(){ [ -z "$(tee)" ] ; }
is_not_empty(){ [ -n "$(tee)" ] ; }
directory_exists(){ [ -d "$(tee)" ] ; }
directory_not_exists(){ [ ! -d "$(tee)" ] ; }
file_exists(){ [ -f "$(tee)" ] ; }
file_not_exists(){ [ ! -f "$(tee)" ] ; }

first_occurrence(){ gnu_awk '!a[$0]++' ; }

list_all_functions(){ declare -f | gnu_grep '^[a-zA-Z].* () {' | gnu_sed 's/ .*//1' ; }
get_function_body(){ declare -f "${1}" | gnu_sed '1d;$d' ; }

add_chain(){(
  tee
  encapsulate_function(){
    echo '(){'
    eval "get_function_body ${1}"
    echo '} "${@}" || return 1'
  }
  echo "(){
$(echo -E "${@}" | split_spaces | pass encapsulate_function)
}"
)}

add_final_statement(){
  tee
  echo -E "local error_code=\$?
$(get_function_body "${1}")
return \${error_code}"
}

add_function(){
  tee
  echo -E "$(get_function_body "${1}")"
}

for i in function_exists invoke_function no_output no_error silent not to_var \
  to_stderr to_encoded_var encode decode decode_var make_function to_function to_echo_function make_boolean_function \
  pass run_if concatenate append prefix single_quote double_quote first_line last_line \
  split_spaces is_empty is_not_empty directory_exists directory_not_exists file_exists file_not_exists \
  first_occurrence list_all_functions get_function_body add_chain add_final_statement add_function
do
  declare -f "${i}"
done