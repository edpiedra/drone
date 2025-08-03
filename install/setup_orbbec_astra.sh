#!/bin/bash/

set -e

# configuration
ORBBECSDK_REPO="https://github.com/orbbec/OrbbecSDK.git"
PYORBBECSDK_REPO="https://github.com/orbbec/pyorbbecsdk.git"
LOG_DIR="$HOME/drone/install/logs"

if [ ! -d "$LOG_DIR" ]; then 
  mkdir -p $LOG_DIR 
fi
BUILD_LOG="$LOG_DIR/setup_orbbec_astra.log"

exec > >(tee "$BUILD_LOG") 2>&1

# Always operate from the user's home directory
cd "$HOME"

# parse flags
VERIFY=false 

for arg in "$@"; do
  case $arg in
    --verify) VERIFY=true ;;
  esac
  shift
done

echo "===== ObbecSDK and pyorbbecsdk Setup Script for Atra Mini S Pro ====="

# STEP 1: Update system
echo "[ 1/10] Astra: Updating system..."
sudo apt update && sudo apt upgrade -y

# STEP 2: Clone OrbbecSDK
echo "[ 2/10] Astra: Checking for OrbbecSDK source..."
ORBBECSDK_DIR="$HOME/OrbbecSDK"

if [ -d "$ORBBECSDK_DIR" ]; then 
  echo "Removing existing OrbbecSDK directory..."
  rm -rf "$ORBBECSDK_DIR"
fi 

git clone "$ORBBECSDK_REPO"

# Step 3: Update udev rules
echo "[ 3/10] Astra: Updating udev rules..."
cd "$ORBBECSDK_DIR/misc/scripts"
sudo chmod +x ./install_udev_rules.sh
sudo ./install_udev_rules.sh
sudo udevadm control --reload && sudo udevadm trigger

# Step 4: Build OrbbecSDK
echo "[ 4/10] Astra: Building OrbbecSDK..."
cd "$ORBBECSDK_DIR"
mkdir "build"
cd "build"
cmake ..
cmake --build .--config Release

# Step 5: Clone pyorbbecsdk
echo "[ 5/10] Astra: Cloning pyorbbecsdk..."
PYORBBECSDK_DIR="$HOME/pyorbbecsdk"

if [ -d "$PYORBBECSDK_DIR" ]; then 
  echo "Removing existing pyorbbecsdk directory..."
  rm -rf "$PYORBBECSDK_DIR"
fi 

cd "$HOME"
git clone "$PYORBBECSDK_REPO" -b main

# Step 6: Installing system packages
echo "[ 6/10] Astra: Installing system packages..."
sudo apt-get install python3-dev python3-venv python3-pip python3-opencv

# Step 7: Build pyorbbecsdk
echo "[ 7/10] Astra: Building pyorbbecsdk..."

cd "$PYORBBECSDK_DIR"
python3 -m venv ./venv
source venv/bin/activate
pip3 install -r requirements.txt
mkdir "build"
cd "build"
cmake -Dpybind11_DIR=`pybind11-config --cmakedir` ..
make -j4
make install

pip3 install wheel
python3 setup.py bdist_wheel

# Step 8: Setup environment
echo "[ 8/10] Astra: Setting Up Environment..."
cd "$PYORBBECSDK_DIR"
export PYTHONPATH=$PYTHONPATH:$(pwd)/install/lib/
sudo bash ./scripts/install_udev_rules.sh
sudo udevadm control --reload-rules && sudo udevadm trigger

# Step 9: Generate Python stubs
echo "[ 9/10] Astra: Generating Python Stubs..."
source env.sh
pip3 install pybind11-stubgen
pybind11-stubgen pyorbbecsdk

# Step 10: Verifying files
EXAMPLE_FILE="examples/depth_viewer.py"
WHEEL_FILE="dist/*.whl"

if [ "$VERIFY" = true ]; then
  echo "[10/10] Astra: Verifying Files..."
  if [ -f "$EXAMPLE_FILE" ]; then 
    file "$EXAMPLE_FILE"
  fi 
  if [ -f "$WHEEL_FILE" ]; then 
    file "$WHEEL_FILE"
  fi   
fi 

echo "===== ✅ OrbbecSDK Setup Complete! ====="
exit 0