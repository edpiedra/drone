#!/bin/bash

set -e

# configuration
MODELS_DIR="$HOME/models"
PERSONS_DIR="$MODELS_DIR/person_detection"
COCO_FILE="coco_ssd_mobilenet_v2_1.0_quant_2018_06_29.zip"
PERSONS_MODEL="wget https://storage.googleapis.com/download.tensorflow.org/models/tflite/$COCO_FILE"
BODY_POSE_DIR="$MODELS_DIR/pose_detection"
BODY_POSE_MODEL="https://tfhub.dev/google/lite-model/movenet/singlepose/lightning/tflite/float16/4?tf-hub-format=compressed"
BODY_POSE_FILE="movenet_lightning.zip"
FACE_DETECT_DIR="$MODELS_DIR/face_detection"
FACE_DETECT_MODEL="https://github.com/google/mediapipe/raw/master/mediapipe/models/face_detection_front.tflite"

echo "===== Object Detection Setup Script ====="

# Step 1: Update and upgrade
echo "[1/5] Updating system..."
sudo apt update && sudo apt upgrade -y

# Step 2: Install system dependencies
echo "[2/5] Installing System Dependencies..."
sudo apt install -y python3-pip python3-opencv libatlas-base-dev python3-venv

# Step 3: Download TFLite SSD MobileNet V2 model for person detection
echo "[3/5] Downloading Person Detection..."

if [ -d "$PERSONS_DIR" ]; then 
  echo "removing $PERSONS_DIR ..."
  rm -rf "$PERSONS_DIR"
fi 

mkdir -p "$PERSONS_DIR"
cd "$PERSONS_DIR"
wget "$PERSONS_MODEL"
unzip "$COCO_FILE"
mv detect.tflite ssd_mobilenet_v2.tflite

# Step 4: Download MoveNet Lightning model (TFLite format)
echo "[4/5] Downloading Body Pose..."

if [ -d "$BODY_POSE_DIR" ]; then 
  echo "removing $BODY_POSE_DIR ..."
  rm -rf "$BODY_POSE_DIR"
fi 

mkdir -p "$BODY_POSE_DIR"
cd "$BODY_POSE_DIR"
wget "$BODY_POSE_MODEL" -O "$BODY_POSE_FILE"
unzip "$BODY_POSE_FILE"

# Step 5: Download FDLite face detection model
echo "[5/5] Downloading Face Detection..."

if [ -d "$FACE_DETECT_DIR" ]; then 
  echo "removing $FACE_DETECT_DIR ..."
  rm -rf "$FACE_DETECT_DIR"
fi 

mkdir -p "$FACE_DETECT_DIR"
cd "$FACE_DETECT_DIR"
wget "$FACE_DETECT_MODEL"


echo "Virtual environment created and packages installed. Models downloaded."
