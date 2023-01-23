#!/bin/bash
SOURCE=${BASH_SOURCE[0]}
while [ -L "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR=$(cd -P "$(dirname "$SOURCE")" >/dev/null 2>&1 && pwd)
  SOURCE=$(readlink "$SOURCE")
  [[ $SOURCE != /* ]] && SOURCE=$DIR/$SOURCE # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR=$(cd -P "$(dirname "$SOURCE")" >/dev/null 2>&1 && pwd)

if [[ ! -f "$DIR/venv/bin/activate" ]]; then
  echo "VENV does not exist!"
  exit
fi

source "$DIR/venv/bin/activate"
source "$DIR/launch-config.sh"

# Make sure important directories exists
mkdir -p "$MODEL_STORAGE_DIR/hypernetworks"
mkdir -p "$MODEL_STORAGE_DIR/vae"
mkdir -p "$DIR/models/hypernetworks"
mkdir -p "$DIR/models/VAE"
mkdir -p "$DIR/log/images"

if $LINK_NOVELAI_ANIME_VAE; then
  LINK_NAI_VAE="--link-novelai-anime-vae"
else
  LINK_NAI_VAE=""
fi

python3 "$DIR/manager/linker.py" "$MODEL_STORAGE_DIR" "$DIR" $LINK_NAI_VAE
echo ""

if $ACTIVATE_DEEPDANBOORU; then
  DD_ARG="--deepdanbooru"
  pip install "git+https://github.com/KichangKim/DeepDanbooru.git@v3-20211112-sgd-e28#egg=deepdanbooru[tensorflow]"
else
  DD_ARG=""
fi
if $ACTIVATE_MEDVRAM; then
  MVRAM_ARG="--medvram"
else
  MVRAM_ARG=""
fi
if $DISABLE_PICKLE_CHECK; then
  PICKLED="--disable-safe-unpickle"
else
  PICKLED=""
fi
if [[ $GRADIO_PORT != false ]]; then
  PORT="--port $GRADIO_PORT"
else
  PORT="--share"
fi
if [[ $GRADIO_AUTH != false ]]; then
  AUTH="--gradio-auth $GRADIO_AUTH --enable-insecure-extension-access"
else
  AUTH=""
fi
if [[ $UI_THEME != false ]]; then
  THEME="--theme $UI_THEME"
else
  THEME=""
fi
if $INSECURE_EXTENSION_ACCESS; then
  INSC_ARG="--enable-insecure-extension-access"
else
  INSC_ARG=""
fi

# Launch args go below:
python3 "$DIR/webui.py" --xformers $DD_ARG $MVRAM_ARG $PICKLED $PORT $AUTH $THEME $INSC_ARG --gradio-debug
