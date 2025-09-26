
source_package_path(){
  app_data_dir | append "/source_packages/$(package_name)-$(package_version).tar.xz"
}

require source_package_path package_name package_version app_data_dir

download_source_package(){
  local error_code
  if source_package_path | file_exists ; then
    echo "Using file: $(source_package_path)" | to_stderr
    return 0
  fi
  (){
    local destination_dir
    tmp_home | append "/download_source_package/$(package_name)" | to_var destination_dir
    tmp_home | append /download_source_package | pass clean_directory
    include lib/app/fetch_repository/fetch_repository.zsh
    fetch_repository "${destination_dir}" "$(package_version)" "$(package_source_url)" || {
      echo "download_source_package() : cannot fetch the repository" | to_stderr
      return 1
    }
    if function_exists package_update_source ; then
      ()( cd "${destination_dir}" ; invoke_function package_update_source ; ) || {
        echo "download_source_package() : error executing package_update_source()" | to_stderr
        return 1
      }
    fi
    source_package_path | pass dirname | pass mkdir -p
    gnu_tar c -C "${destination_dir}" --no-xattrs . | xz -T0 >"$(source_package_path)"
  }
  error_code=$?
  tmp_home | append /download_source_package | pass remove_directory
  return ${error_code}
}

require download_source_package package_name source_package_path tmp_home

declare -f source_package_path
declare -f download_source_package
