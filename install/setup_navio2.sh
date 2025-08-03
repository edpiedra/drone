#!/bin/bash

set -e

# === Config ===
BUILD_32=0
BUILD_64=0
VERIFY_ONLY=0
CLEANUP_RPIO=0
FORCE_CLONE=0
USE_DUAL=0
KERNEL_BRANCH="rpi-5.10.11-navio"
LINUX_REPO="https://github.com/emlid/linux-rt-rpi.git"
RCIO_REPO="https://github.com/emlid/rcio-dkms.git"
ARDUPILOT_REPO="https://github.com/ArduPilot/ardupilot.git"
LOG_DIR="$HOME/drone/install/logs"

if [ ! -d "$LOG_DIR" ]; then 
  mkdir -p $LOG_DIR 
fi
BUILD_LOG="$LOG_DIR/setup_navio2.log"

exec > >(tee "$BUILD_LOG") 2>&1

# === Parse Flags ===
for arg in "$@"
do
  case $arg in
    --native64)
      BUILD_64=1
      ;;
    --dual)
      BUILD_32=1
      BUILD_64=1
      USE_DUAL=1
      ;;
    --verify)
      VERIFY_ONLY=1
      ;;
    --force)
      FORCE_CLONE=1
      ;;
  esac
done

cd "$HOME"
echo "[ 0/10] Navio2: Starting setup from \$PWD"

# === Step 1: Install prerequisites ===
echo "[ 1/10] Navio2: Installing dependencies..."
sudo dpkg --add-architecture armhf
sudo apt update
sudo apt install -y \
    git dkms build-essential bc libncurses-dev flex bison libssl-dev \
    libelf-dev crossbuild-essential-armhf gcc-aarch64-linux-gnu g++-aarch64-linux-gnu \
    python3 python3-pip python3-dev python-is-python3 \
    libc6:armhf libstdc++6:armhf libgcc1:armhf python3-empy python3-future

# Symlink for 32-bit interpreter
if [ ! -f "/lib/ld-linux-armhf.so.3" ]; then
    ARM_LD_SO=$(find /lib/arm-linux-gnueabihf -name "ld-*.so" | head -n 1)
    if [ -n "$ARM_LD_SO" ]; then
        sudo ln -s "$ARM_LD_SO" /lib/ld-linux-armhf.so.3
        echo "→ Created symlink: /lib/ld-linux-armhf.so.3 -> $ARM_LD_SO"
    fi
fi

# === Step 2: Clone Emlid kernel source ===
echo "[ 2/10] Navio2: Cloning Emlid linux-rt-rpi..."
if [ ! -d linux-rt-rpi ]; then
  git clone "$LINUX_REPO"
  cd linux-rt-rpi
  git checkout "$KERNEL_BRANCH" || { echo "Branch $KERNEL_BRANCH not found"; exit 1; }
  cd ..
else
  echo "linux-rt-rpi already exists. Skipping."
fi

# === Step 3: Patch kernel if not on 5.10.11-navio ===
echo "[ 3/10] Navio2: Patching kernel if needed..."
if [ "$KERNEL_BRANCH" != "rpi-5.10.11-navio" ]; then
  if [ ! -f navio2.patch ]; then
    wget https://gist.githubusercontent.com/cchen140/07159b29a21be929b545ad6c268ef3cc/raw/navio2-4.19.83.patch -O navio2.patch
  fi
  patch -d linux-rt-rpi -p1 < navio2.patch || echo "Patch may have been applied already."
else
  echo "Skipping patch for $KERNEL_BRANCH"
fi

# === Step 4: Build and install kernel ===
echo "[ 4/10] Navio2: Building kernel..."
cd linux-rt-rpi
if [ ! -f .config ]; then
  make bcm2711_defconfig
  make -j$(nproc)
  sudo make modules_install
  sudo make install
  read -p "→ Kernel installed. Reboot now? (y/n): " RESP
  if [[ "$RESP" =~ ^[Yy]$ ]]; then
    sudo reboot
  fi
fi
cd ..

# === Step 5: Install RCIO DKMS module ===
echo "[ 5/10] Navio2: Installing Navio2 kernel modules..."
if [ ! -d "$HOME/rcio-dkms" ] || [ ! -f "$HOME/rcio-dkms/src/Makefile" ]; then
    echo "Cloning RCIO DKMS repository..."
    rm -rf "$HOME/rcio-dkms"
    git clone "$RCIO_REPO" "$HOME/rcio-dkms"
else
    echo "rcio-dkms already cloned and structure verified."
fi

cd "$HOME/rcio-dkms"
if dkms status | grep -q rcio; then
  sudo dkms remove rcio/0.0.1 --all || true
fi

make clean || true
make
sudo make install
cd "$HOME"

# === Step 6: Create overlays if needed ===
echo "[ 6/10] Navio2: Creating overlays..."
mkdir -p overlays && cd overlays
echo "→ overlays step placeholder"
cd "$HOME"

# === Step 7: Clone ArduPilot ===
echo "[ 7/10] Navio2: Checking ArduPilot source..."
if [ "$FORCE_CLONE" -eq 1 ]; then
  rm -rf ardupilot
fi
if [ ! -d ardupilot ]; then
  git clone --recurse-submodules "$ARDUPILOT_REPO"
fi
cd ardupilot

# === Step 8: Install Python requirements ===
echo "[ 8/10] Navio2: Installing Python requirements..."
if [ -f Tools/requirements.txt ]; then
  pip3 install --user -r Tools/requirements.txt || true
else
  echo "Tools/requirements.txt not found. Installing known ArduPilot dependencies manually..."
  pip3 install --user future pymavlink MAVProxy
fi

# === Step 9: Build ArduPilot ===
echo "[ 9/10] Navio2: Building ArduPilot..."
if [ "$BUILD_64" -eq 1 ]; then
  echo "→ Building 64-bit ArduPilot..."
  ./waf configure --board=navio2 --toolchain=native
  ./waf copter
  mkdir -p build/navio2-64/bin
  cp build/navio2/bin/arducopter build/navio2-64/bin/arducopter-64
fi
if [ "$BUILD_32" -eq 1 ]; then
  echo "→ Building 32-bit ArduPilot..."
  ./waf configure --board=navio2
  ./waf copter
fi

# === Step 10: Post-build summary ===
echo "[10/10] Navio2: Post-build summary:"
if [ -f "$HOME/ardupilot/build/navio2/bin/arducopter" ]; then
  echo "✅ Testing 32-bit ArduPilot binary: $HOME/ardupilot/build/navio2/bin/arducopter"
  file "$HOME/ardupilot/build/navio2/bin/arducopter"
  "$HOME/ardupilot/build/navio2/bin/arducopter" --help >/dev/null || echo "[ERROR] Failed to run 32-bit binary"
else
  echo "❌ 32-bit ArduPilot binary missing"
fi
if [ -f "$HOME/ardupilot/build/navio2-64/bin/arducopter-64" ]; then
  echo "✅ Testing 64-bit ArduPilot binary: $HOME/ardupilot/build/navio2-64/bin/arducopter-64"
  file "$HOME/ardupilot/build/navio2-64/bin/arducopter-64"
  "$HOME/ardupilot/build/navio2-64/bin/arducopter-64" --help >/dev/null || echo "[ERROR] Failed to run 64-bit binary"
fi
else
  echo "❌ 64-bit ArduPilot binary missing"
fi

# === Step 11: Verification ===
if [ "$VERIFY_ONLY" -eq 1 ]; then
  echo "→ Running post-setup verification..."
  file "$HOME/ardupilot/build/navio2/bin/arducopter" || true
  file "$HOME/ardupilot/build/navio2-64/bin/arducopter-64" || true
  dkms status | grep rcio || echo "❌ RCIO module not loaded"
fi

echo "✅ Setup complete. Use --verify to validate binaries or RCIO module."
exit 0
