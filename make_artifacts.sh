#!/usr/bin/env zsh
#
#source ./lib/loader.sh || exit 1
#
#make_artifact_worker(){(
#  echo "Loading package: ${1}"
#  load_package "${1}"
#  echo "Creating the artifact: ${1}"
#  make_artifact -f
#)}
#
#echo "Evaluating installation order"
#get_installation_order restinio nlohmann-json sqlite_orm | to_var bom_list_ordered
#echo "${bom_list_ordered}"
#
#printf "\nMaking artifacts..."
#echo "${bom_list_ordered}" | pass -until make_artifact_worker
