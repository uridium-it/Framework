
artifact_url(){
  artifacts_repo_url | append "/releases/download/$(artifacts_repo_version)/$(artifact_name).tar.xz"
}

require artifact_url artifact_name

download_artifact(){
  (
    local packages
    download_single_artifact(){
      if artifact_path | file_exists ; then
        artifact_path | prefix "Using: "
        return 0
      else
        artifacts_home | pass mkdir -p
        file_fetcher "$(artifact_url)" "$(artifact_path)" || {
          echo "file_fetcher() : error" | to_stderr
          return 1
        }
      fi
      return 0
    }
    require download_single_artifact artifact_path artifacts_home artifact_url
    full_dependencies_list "${1}" | to_var packages
    if [[ ! "${packages}" ]] ; then
      echo "Nothing to install"
      return 0
    fi
    echo "Packages list:"
    echo "${packages}"
    worker(){
      load_package_json "${1}" || return 1
      download_single_artifact
    }
    echo "${packages}" | pass -until worker
  )
}

for i in artifact_url download_artifact ; do
  declare -f "${i}"
done
