
package_build_install(){
  cmake_build_install -Wno-dev
}

package_update_source(){
  git submodule update --depth 1 --init --recursive
}
