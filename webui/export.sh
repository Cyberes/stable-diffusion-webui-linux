#!/bin/bash
SOURCE=${BASH_SOURCE[0]}
while [ -L "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR=$(cd -P "$(dirname "$SOURCE")" >/dev/null 2>&1 && pwd)
  SOURCE=$(readlink "$SOURCE")
  [[ $SOURCE != /* ]] && SOURCE=$DIR/$SOURCE # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR=$(cd -P "$(dirname "$SOURCE")" >/dev/null 2>&1 && pwd)

source "$DIR/launch-config.sh"
mkdir -p "$EXPORT_STORAGE_DIR"

DATETIME_STR=$(date +"%m-%d-%Y_%H-%M-%S")

echo "Output directory: $EXPORT_STORAGE_DIR"

%cd "$EXPORT_STORAGE_DIR"
mkdir -p "$DATETIME_STR/log"

echo "Moving $DIR/log/* $EXPORT_STORAGE_DIR/$DATETIME_STR/log"
mv "$DIR"/log/* "$EXPORT_STORAGE_DIR/$DATETIME_STR/log"

echo "Moving $DIR/outputs to $EXPORT_STORAGE_DIR/$DATETIME_STR"
mv "$DIR"/outputs/* "$EXPORT_STORAGE_DIR/$DATETIME_STR"
7z a -t7z -m0=lzma2 -mx=9 -mfb=64 -md=32m -ms=on "$DATETIME_STR.7z" "$EXPORT_STORAGE_DIR/$DATETIME_STR"
