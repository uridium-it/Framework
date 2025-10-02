
package_build_install(){
  cmake_build_install -DBUILD_TESTS=OFF
}

package_update_source(){
  gnu_sed -i 's/(MSVC)/(FALSE)/' ./CMakeLists.txt
}