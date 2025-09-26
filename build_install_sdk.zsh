#!/usr/bin/env zsh

source loader.zsh || exit 1

invoke_function build_system_loader
invoke_function artifacts_system_loader

build_install_and_make_artifact_worker(){(
  echo "Loading package: ${1}"
  load_package "${1}" || return 1
  echo "Building and installing the package: ${1}"
  build_install || return 1
  echo "Creating the artifact"
  make_artifact || return 1
)}

echo "Evaluating installation order"
installation_order restinio nlohmann-json sqlite_orm | to_var list
echo "${list}"
echo "Building..."
echo "${list}" | pass -until build_install_and_make_artifact_worker
