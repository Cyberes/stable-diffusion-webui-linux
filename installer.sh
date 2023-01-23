#!/bin/bash

SOURCE=${BASH_SOURCE[0]}
while [ -L "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR=$(cd -P "$(dirname "$SOURCE")" >/dev/null 2>&1 && pwd)
  SOURCE=$(readlink "$SOURCE")
  [[ $SOURCE != /* ]] && SOURCE=$DIR/$SOURCE # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR=$(cd -P "$(dirname "$SOURCE")" >/dev/null 2>&1 && pwd)

INSTALL_DIR="$1"
if [[ -z "$INSTALL_DIR" ]] || [[ $INSTALL_DIR = "" ]] || [[ -f "$INSTALL_DIR" ]]; then
  echo "Please specify the install directory."
  exit
fi

if [[ -d "$INSTALL_DIR/stable-diffusion-webui" ]]; then
  echo "WebUI directory exists: $INSTALL_DIR/stable-diffusion-webui"
  echo "Not overwriting manager existing files. Do it yourself with \`cp -r \"$DIR\"/webui/* \"$INSTALL_DIR/stable-diffusion-webui\"\`"
  COPY_MANAGER=false
else
  mkdir -p "$INSTALL_DIR/stable-diffusion-webui"
  git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui "$INSTALL_DIR/stable-diffusion-webui"
  COPY_MANAGER=true
fi

if $COPY_MANAGER; then
  cp -r "$DIR"/webui/* "$INSTALL_DIR/stable-diffusion-webui"
fi

cd "$INSTALL_DIR/stable-diffusion-webui"

python3 -m venv venv
source ./venv/bin/activate

pip install --upgrade pip
pip install --upgrade wheel setuptools
pip install triton

python3 -c "import launch;launch.prepare_environment()"

# Install things for this notebook
pip install requests gdown bs4 markdownify

sudo apt update
sudo apt install -y p7zip-full
