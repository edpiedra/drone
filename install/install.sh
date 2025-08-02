#!/bin/bash

set -e

# configuration
INSTALL_DIR="$HOME/drone/install"
NAVIO_INSTALL="$INSTALL_DIR/setup_navios2.sh"
ASTRA_INSTALL="$INSTALL_DIR/setup_orbbec_astra.sh"
DETECTIONS_INSTALL="$INSTALL_DIR/setup_detections.sh"

# parse flags
FORCE=false
DETECTIONS=false

for arg in "$@"
do 
  case $arg in 
    --force) FORCE=true;;
    --detections) DETECTIONS=true;;
  esac
done 

cd "$HOME"

if [ ! -d "$HOME/ardupilot" ] || [ "$FORCE" ]; then 
  chmod +x "$NAVIO_INSTALL"
  "$NAVIO_INSTALL" --dual --force --verify
  read -p "ArduPilot installed.  Reboot now? (y/n): " RESP
  if [[ "$RESP" =~ ^[Yy]$ ]]; then
    sudo reboot
  fi
fi 

if [ ! -d "$HOME/OrbbecSDK" ] || [ ! -d "$HOME/pyorbbecsdk" ] || [ "$FORCE" ]; then 
  chmod +x "$ASTRA_INSTALL"
  "$ASTRA_INSTALL"
fi 

if [ ! -d "$HOME/models" ] || [ "$DETECTIONS" ] || [ "$FORCE" ]; then 
  chmod +x "$DETECTIONS_INSTALL"
  "$DETECTIONS_INSTALL"
fi 

