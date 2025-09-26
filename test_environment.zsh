#!/usr/bin/env zsh

source loader.zsh || exit 1

print_ok(){ echo ' --> OK' ; }

print_error(){ echo " --> ERROR${1}" ; }

make_function fatal_error false

fatal_exit(){
  echo -e '\nCannot continue, please fix the problem first'
  exit 1
}

echo -e 'Testing configuration'

required_commands="gnu_sed gnu_grep gnu_tar gnu_awk gnu_find jq xz cmake zsh wget git make curl"

if is_osx ; then
  echo "${required_commands} clang clang++" | to_var required_commands
elif is_linux ; then
  echo "${required_commands} gcc g++" | to_var required_commands
fi

test_cmd(){
  local cmd
  if function_exists "${1}" ; then
    get_function_body "${1}" | sed 's/^[\t ]*//;s/ .*//' | to_var cmd
  else
    cmd="${1}"
  fi
  echo -n "${cmd} ($1): "
  if silent whence "${cmd}" ; then
    print_ok
  else
    print_error ": Required but not installed"
    make_function fatal_error true
  fi
}

echo "${required_commands}" | split_spaces | pass test_cmd

fatal_error && fatal_exit
