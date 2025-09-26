eval "root_dir(){ echo '$(realpath .)' ; }"

source lib/include.zsh

include lib/functional.zsh
include lib/os.zsh
include lib/app/annotations/require.zsh

package_system_loader(){
  include lib/app/packages/packages.zsh
  load_json_file etc/configuration.json
  unset -f package_system_loader
}

build_system_loader(){
  invoke_function package_system_loader
  include lib/app/packages/source_packages/source_packages.zsh
  include lib/app/packages/build_system/build_install.zsh
  include lib/app/packages/build_system/build_script/build_script.zsh
  include lib/app/packages/build_system/build_script/cmake/cmake.zsh
  unset -f build_system_loader
}

artifacts_system_loader(){
  invoke_function package_system_loader
  include lib/app/packages/artifacts_system/artifacts_system.zsh
  include lib/app/packages/artifacts_system/github_integration/github.zsh
  unset -f artifacts_system_loader
}
