
artifacts_home(){
  echo "$(app_data_dir)/artifacts"
}

artifact_path(){
  artifact_name | pass concatenate "$(artifacts_home)/" ".tar.xz"
}

artifact_name(){(
  architecture=$(uname -m)
  if function_exists package_platform ; then
    os="$(package_platform)"
  else
    if is_linux ; then
      make_boolean_function is_redhat '[ -f /etc/redhat-release ]'
      make_boolean_function is_arch '[ -f /etc/arch-release ]'
      make_boolean_function is_ubuntu 'cat /etc/os-release | gnu_grep -q ubuntu'
      if is_redhat; then
        os=redhat-${architecture}
      elif is_arch; then
        os=arch-${architecture}
      elif is_ubuntu; then
        os=ubuntu-${architecture}
      else
        os=unknown-${architecture}
      fi
    elif is_windows ; then
      os=windows-${architecture}
    elif is_osx ; then
      os=osx-${architecture}
    fi
  fi
  echo "$(package_name)-${os}-$(package_version)-$(package_build_type)"
)}

require artifact_name package_name package_version package_build_type

make_artifact(){
  if [[ "${1}" != "-f" ]] ; then
    artifact_path | file_exists && {
      echo "the artifact is already present in the repo"
      return 0
    }
  fi
  if manifest_path | file_not_exists ; then
    echo "make_artifact() : can't make an artifact without the manifest, manifest file is missing" | to_stderr
    return 1
  fi
  if tee < "$(manifest_path)" | is_empty ; then
    echo "make_artifact() : error, the manifest file is empty, can't make an empty artifact" | to_stderr
    return 1
  fi
  artifact_path | pass dirname | pass mkdir -p
  echo gnu_tar c -C "$(project_root | single_quote)" --no-xattrs "$(tee < "$(manifest_path)" | single_quote | tr '\n' ' ')"\| xz -T0 \>"$(artifact_path | double_quote)" | pass eval
}

require make_artifact manifest_path project_root artifact_path

install_artifact(){
  (
    local packages
    install_single_artifact(){
      project_root | pass mkdir -p
      tar xCvf "$(project_root)" "$(artifact_path)"
    }
    require install_single_artifact manifest_path artifact_path project_root
    full_dependencies_list "${1}" | to_var packages
    if [[ ! "${packages}" ]] ; then
      echo "Nothing to install"
      return 0
    fi
    echo "Packages list:"
    echo "${packages}"
    worker(){(
      load_package_json "${1}" || return 1
      install_single_artifact
    )}
    echo "${packages}" | pass -until worker
  )
}

for i in artifacts_home artifact_path artifact_name make_artifact install_artifact ; do
    declare -f "${i}"
done
