DRONE ENVIRONMENT

Update system packages
------------------------------------------------------------------------------------------
```
sudo apt update && sudo apt -y dist-upgrade
```

OpenNISDK
------------------------------------------------------------------------------------
> copy OpenNI-Linux-Arm-2.3.0.63 from d:/orbbec-astra/OpenNI_2.3.0.63/Linux to ~/OpenNISDK
```
# on Raspberry Pi
mkdir OpenNISDK

# on Windows command prompt
scp -r d:/orbbec-astra/OpenNI_2.3.0.63/Linux/OpenNI-Linux-Arm-2.3.0.63 pi@dronetest.local:~/OpenNISDK/
```

> install OpenNI system-wide on Raspberry Pi
```
sudo apt-get install -y build-essential freeglut3 freeglut3-dev

ldconfig -p | grep libudev.so.1
cd /lib/arm-linux-gnueabihf
sudo ln -s libudev.so.x.x.x libudev.so.1

cd ~/OpenNISDK/OpenNI-Linux-Arm-2.3.0.63
sudo chmod 777 install.sh
sudo ./install.sh

# replug in the device for usb-register
lsusb

source OpenNIDevEnvironment
```

> build samples
```
cd Samples/SimpleRead
make
```

> run examples
```
cd Bin/Arm-Release
./SimpleRead
```

Install OpenCV system-wide
---------------------------------------------------------
```
sudo apt install -y python3-opencv
```

TFLite + SSD MobileNet V2 for 'person' detection
-----------------------------------------------------------------
> download TFLite model on Raspberry Pi
```
cd ~/drone
mkdir models && cd models
wget https://storage.googleapis.com/download.tensorflow.org/models/tflite/task_library/object_detection/lite-model_ssd_mobilenet_v2_fpnlite_320x320_1.tflite
```

