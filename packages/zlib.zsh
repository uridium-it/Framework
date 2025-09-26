
package_build_install(){
  cmake_build_install -DZLIB_BUILD_EXAMPLES=OFF
}

package_update_source(){
  gnu_sed -i -e '/zlib\\.3/d' -e 's%"${CMAKE_INSTALL_PREFIX}/share/pkgconfig"%"${CMAKE_INSTALL_PREFIX}/lib/pkgconfig"%1' CMakeLists.txt
}