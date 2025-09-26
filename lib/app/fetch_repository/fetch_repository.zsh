
fetch_repository(){(
  local url version destination_dir filename working_directory
  destination_dir="${1}" ; version="${2}" ; url="${3}"
  dirname "${destination_dir}" | to_var working_directory
  echo "${url}" | pass basename | to_var filename
  case "${filename}" in
    *.tar.gz|*.tgz)
      invoke_function file_fetcher "${url}" "${working_directory}/${filename}" || {
        echo "fetch_repository() : error cannot fetch : ${url} into ${working_directory}/${filename}" | to_stderr
        return 1
      }
      gnu_tar xzf "${working_directory}/${filename}" -C "${working_directory}" || {
        echo "fetch_repository() : error decompressing the file : ${working_directory}/${filename}" | to_stderr
        return 1
      }
      rm -f "${working_directory}/${filename}"
      [ -d "${destination_dir}" ] || gnu_find "${working_directory}"/* -maxdepth 0 -type d | first_line | pass -first mv "${destination_dir}" || {
        echo "error finding files in this ${filename}, please verify the source tgz file" | to_stderr
        return 1
      }
      ;;
    *.git)
      git -c advice.detachedHead=false clone \
      --single-branch \
      --branch "${version}" \
      --progress \
      "${url}" "${destination_dir}" || {
        echo "fetch_repository() : git cannot fetch : ${url} branch : ${version}" | to_stderr
        return 1
      }
      ;;
    *)
      echo "fetch_repository() : url does not end in .git|.tar.gz|.tgz" | to_stderr
      return 1 ;;
  esac
)}

declare -f fetch_repository
