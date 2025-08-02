#!/bin/bash

set -e

ROOT="/home/pi"

# configuration
INSTALL_DIR="$ROOT/drone/install"
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

cd ~

if [ ! -d "$ROOT/ardupilot" ] || [ "$FORCE" ]; then 
  sudo chmod +x "$NAVIO_INSTALL"
  sudo "$NAVIO_INSTALL" --dual --force --verify
  read -p "ArduPilot installed.  Reboot now? (y/n): " RESP
  if [[ "$RESP" =~ ^[Yy]$ ]]; then
    sudo reboot
  fi
fi 

if [ ! -d "$ROOT/OrbbecSDK" ] || [ ! -d "$ROOT/pyorbbecsdk" ] || [ "$FORCE" ]; then 
  sudo chmod +x "$ASTRA_INSTALL"
  sudo "$ASTRA_INSTALL"
fi 

if [ ! -d "$ROOT/models" ] || [ "$DETECTIONS" ] || [ "$FORCE" ]; then 
  sudo chmod +x "$DETECTIONS_INSTALL"
  sudo "$DETECTIONS_INSTALL"
fi 

