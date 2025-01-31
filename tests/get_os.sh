#!/bin/bash

OS=$(uname)

case $OS in
  Linux)
    echo "Linux"
    ;;
  Darwin)
    echo "MacOS"
    ;;
  *BSD)
    echo "BSD"
    ;;
  CYGWIN* | MINGW* | MSYS*)
    echo "Windows"
    ;;
  *)
    echo "Unknown OS"
    ;;
esac