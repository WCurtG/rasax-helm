#!/bin/bash 

set -e

has() {
  command -v "$1" 1>/dev/null 2>&1
}

if has brew; then
    echo brew is installed
else
    echo brew is not installed
fi
