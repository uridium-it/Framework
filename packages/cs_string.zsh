
package_build_install(){
  cmake_build_install -DBUILD_TESTS=OFF
}

package_update_source(){
  gnu_sed -i 's#set(PKG_PREFIX "cmake/CsString")#set(PKG_PREFIX "${CMAKE_INSTALL_LIBDIR}/cmake/CsString")#' ./CMakeLists.txt
}