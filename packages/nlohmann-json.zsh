
package_build_install(){
  cmake_build_install -DJSON_BuildTests=OFF \
  -DJSON_MultipleHeaders=OFF \
  -DCMAKE_INSTALL_DATADIR=lib
}

package_update_source(){
  gnu_sed -i 's/(MSVC)/(FALSE)/' ./CMakeLists.txt
}