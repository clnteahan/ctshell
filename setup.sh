#!/bin/bash

WD="$(pwd)"
FORCE=false
DEPSMET=true

check_have() {
  local RES
  RES="$(which -a "$1" 2>/dev/null)"
  if [ -z "$RES" ]; then
    echo "Executable '$1' missing."
    DEPSMET=false
  fi
}

if [ "$1" == '-f' ]; then
  FORCE=true
fi

if [ $FORCE == false ]; then
  echo "Resolving dependencies..."
  check_have "quickshell"
  check_have "ln"
fi

if [ $DEPSMET == false ]; then
  echo "Please check the install section in README.md for dependencies."
  exit 1
fi

echo "Dependencies met."
echo "Creating symlinks..."

ln -s $WD ~/.config/quickshell

echo "Setup complete!"
