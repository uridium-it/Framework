
require(){(
  local function
  an_invalid_function(){ invoke_function "$(tee)" | is_empty ; }
  require.valid_functions_decorator(){
    echo "${require}" | split_spaces | pass -if an_invalid_function | to_var invalid_functions
    echo "${invalid_functions}" | pass -first echo '(): invalid function' | to_stderr
    if echo "${invalid_functions}" | is_not_empty; then
      echo "requirements for ${0}() are not meet" | to_stderr
      return 1
    else
      return 0
    fi
  }
  echo "${1}(){
    (
      $(declare -f an_invalid_function)
      $(echo "${@:2}" | double_quote | prefix require=)
      $(get_function_body require.valid_functions_decorator)
    ) || return 1
    $(get_function_body "${1}")
  }"
  ) | pass -accumulate eval
}

declare -f require