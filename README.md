Drone build

> image Raspian Bullseye 64-bit OS (with desktop if wanted)

> install ArduPilot for Navio2
```
sudo apt update && sudo apt -y dist-upgrade
sudo apt install -y git
cd ~
sudo git clone https://github.com/edpiedra/drone.git
chmod +x ./drone/install/setup_navio2.sh
./drone/install/setup_navio2.sh --dual --force --verify
sudo reboot
```

> test ArduPilot
```
# adjust udp to ip address of machine running the ground control station (like Mission Planner)
sudo ~/ardupilot/build/navio2/bin/arducopter -A udp:192.168.1.3:14550
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
