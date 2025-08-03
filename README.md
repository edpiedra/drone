Drone build

> image Raspian Bullseye 64-bit OS
  > with desktop: 2023-05-03-raspios-bullseye-arm64.img.xz

> clone drone respository
```
sudo apt update 
sudo apt install -y git
cd ~
sudo git clone https://github.com/edpiedra/drone.git
```

> ===== to update local repository =====
```
cd ~/drone
sudo git reset --hard
sudo git pull origin
```

# BASIC INSTALL
> install all packages
```
cd ~
sudo chmod +x ./drone/install/install.sh

sudo ./drone/install/install.sh
# args: --force : full re-install of all packages
#       --ardupilot : re-install ArduPilot
#       --detections : re-install detections

# Navio2 install will require a reboot after building kernel (step 4 of 10)
# restart install once rebooted.
sudo ./drone/install/install.sh
```

# TESTING INSTALLATIONS
> test ArduPilot
```
# adjust udp to ip address of machine running the ground control station (like Mission Planner)
sudo ~/ardupilot/build/navio2/bin/arducopter -A udp:192.168.1.3:14550
```

> test OrbbecSDK
```
cd ~/OrbbecSDK/build/bin
./OBMultiStream
```

> test pyorbbecsdk
```
cd ~/pyorbbecsdk
source venv/bin/activate
python3 examples/depth_viewer.py
```

# UPDATING DETECTION MODELS
```
sudo ./drone/install/install.sh --detections
```

# INDIVIDUAL PACKAGE INSTALLS
> install ArduPilot for Navio2
```
cd ~
chmod +x ./drone/install/setup_navio2.sh
./drone/install/setup_navio2.sh --dual --force --verify
sudo reboot
```

> install OrbbecSDK and pyorbbecsdk for Astra Mini S Pro
```
cd ~
chmod +x ./drone/install/setup_orbbec_astra.sh
./drone/install/setup_orbbec_astra.sh

# test sample
cd ~/OrbbecSDK/build/bin
./OBMultiStream

sudo udevadm control --reload-rules && sudo udevadm trigger
cd ~/pyorbbecsdk
source venv/bin/activate
python3 examples/depth_viewer.py

```

> install detection models
```
cd ~
chmod +x ./drone/install/setup_detections.sh
./drone/install/setup_detections.sh
```
