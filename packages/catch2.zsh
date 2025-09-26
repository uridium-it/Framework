
package_build_install(){
  cmake_build_install -DCATCH_INSTALL_DOCS=OFF -DCATCH_INSTALL_EXTRAS=OFF -DCMAKE_INSTALL_DATAROOTDIR=lib
}
