#!/bin/bash

INSTALL_DIR="$1"
if [[ -z "$INSTALL_DIR" ]] || [[ $INSTALL_DIR = "" ]] || [[ -f "$INSTALL_DIR" ]]; then
  echo "Please specify the path to your WebUI directory."
  exit
fi

if [[ ! -f "$INSTALL_DIR/venv/bin/activate" ]]; then
  echo "VENV does not exist!"
  exit
fi
source "$INSTALL_DIR/venv/bin/activate"

mkdir -p "$INSTALL_DIR/xformers-wheel"

pip install --upgrade ninja
pip wheel --wheel-dir="$INSTALL_DIR/xformers-wheel" git+https://github.com/facebookresearch/xformers@1d31a3a#egg=xformers
pip install "$INSTALL_DIR"/xformers-wheel/xformers-*
