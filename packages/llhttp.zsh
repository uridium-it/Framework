
package_build_install(){
  cmake_build_install -DBUILD_STATIC_LIBS=ON -DBUILD_SHARED_LIBS=OFF
}
