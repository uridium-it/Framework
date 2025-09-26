
package_build_install(){
  cmake_build_install -Wno-dev \
    -DRESTINIO_EXPLICIT_CPPSTD=20 \
    -DRESTINIO_ASIO_SOURCE=boost \
    -DRESTINIO_SAMPLE=OFF \
    -DRESTINIO_TEST=OFF \
    -DRESTINIO_WITH_SOBJECTIZER=OFF \
    -DRESTINIO_BENCHMARK=OFF \
    -DRESTINIO_DEP_LLHTTP=system \
    -DRESTINIO_DEP_FMT=system \
    -DRESTINIO_DEP_EXPECTED_LITE=system \
    -DRESTINIO_DEP_CATCH2=system
}

package_update_source(){
  find . -maxdepth 1 -type f | pass rm
  mv dev/* .
  rmdir dev
}
