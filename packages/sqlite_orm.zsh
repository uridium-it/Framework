
package_build_install(){
  cmake_build_install -DBUILD_TESTING=OFF -DSQLITE_ORM_ENABLE_CXX_20=ON
}
