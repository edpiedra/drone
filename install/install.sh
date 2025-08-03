#!/bin/bash

# ----------------------------------------------------------------------------
# Args:
#   --force : force the reinstall of all packages
#   --ardupilot : force the reinstall of ArduPilot
#   --astra : force the reinstall of Astra
#   --detections : force the reinstall of detection packages
# ------------------------------------------------------------------------------

set -e

HOME="/home/pi"

# configuration
INSTALL_DIR="$HOME/drone/install"
NAVIO_INSTALL="$INSTALL_DIR/setup_navio2.sh"
ASTRA_INSTALL="$INSTALL_DIR/setup_orbbec_astra.sh"
DETECTIONS_INSTALL="$INSTALL_DIR/setup_detections.sh"
LOG_DIR="$INSTALL_DIR/logs"

if [ ! -d "$LOG_DIR" ]; then 
  mkdir -p $LOG_DIR 
fi

BUILD_LOG="$LOG_DIR/install.log"

# start logging
exec > >(tee "$BUILD_LOG") 2>&1

# parse flags
FORCE=false
ARDUPILOT=false
ASTRA=false
DETECTIONS=false

for arg in "$@"
do 
  case $arg in 
    --force) FORCE=true;;
    --detections) DETECTIONS=true;;
    --astra) ASTRA=true;;
    --ardupilot) ARDUPILOT=true;;
  esac
done 

cd "$HOME"

if [ ! -d "$HOME/ardupilot" ] || [ "$FORCE" ] || [ "$ARDUPILOT"]; then 
  sudo chmod +x "$NAVIO_INSTALL"
  if [ "$FORCE" ]; then 
    sudo "$NAVIO_INSTALL" --dual --force --verify
  else 
    sudo "$NAVIO_INSTALL" --dual --verify
  fi 
  read -p "ArduPilot installed.  Reboot now? (y/n): " RESP
  if [[ "$RESP" =~ ^[Yy]$ ]]; then
    sudo reboot
  fi
fi 

if [ ! -d "$HOME/OrbbecSDK" ] || [ ! -d "$ROOT/pyorbbecsdk" ] || [ "$FORCE" ] || [ "$ASTRA" ]; then 
  sudo chmod +x "$ASTRA_INSTALL"
  sudo "$ASTRA_INSTALL" --verify
fi 

if [ ! -d "$HOME/models" ] || [ "$DETECTIONS" ] || [ "$FORCE" ]; then 
  sudo chmod +x "$DETECTIONS_INSTALL"
  sudo "$DETECTIONS_INSTALL"
fi 

echo "✅ Setup complete.  Logs saved to: $BUILD_LOG"
exit 0