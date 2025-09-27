#!/usr/bin/env zsh

function() {
  pm1(){ printf "The correct invocation is:\n\n  cd Framework\n  source ./install.sh\n\n" ; }
  if ! source ./loader.zsh ; then pm1 ; return 1 ; fi
  if ! root_dir | grep -q '/Framework$' ; then
    pm1 ; return 1
  fi
  f="Framework(){ cd '$(root_dir)' && source ./loader.zsh ; } ; Framework"
  [ -f "${HOME}/.zshrc" ] || touch "${HOME}/.zshrc"
  tee < "${HOME}/.zshrc" | grep -v "^Framework(){" >"${HOME}/.zshrc.orig"
  cat "${HOME}/.zshrc.orig" >"${HOME}/.zshrc"
  echo "${f}" >>"${HOME}/.zshrc"
  rm -f "${HOME}/.zshrc.orig"
  osx_brew_root(){ app_tools_dir | append /brew ; }
  if is_osx ; then
    [ -f /usr/bin/g++ ] || ( xcode-select --install ; )
    if osx_brew_root | append /bin/gsed | file_not_exists ; then
      git clone --depth=1 https://github.com/Homebrew/brew "$(osx_brew_root)" || return 1
    fi
    "$(osx_brew_root)/bin/brew" install gnu-sed grep gnu-tar awk findutils jq xz cmake
  fi
}
