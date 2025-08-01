import tflite_runtime.interpreter as tflite
from fdlite import FaceDetection, FaceDetectionModel
import numpy as np 
from typing import Tuple
from PIL import Image
import cv2 

class TFFaceDetection:
    def __init__(self):
        self.face_detector = FaceDetection(model_type=FaceDetectionModel.BACK_CAMERA)        

    def detect_faces(self, frame: np.ndarray) -> tuple[int|None, int|None]:
        h, w = frame.shape[:2]
        # Convert to PIL image for face-detection-tflite
        image = Image.fromarray(cv2.cvtColor(frame, cv2.COLOR_BGR2RGB))
        faces = self.face_detector(image)
        targets = []
        
        for face in faces:
            box = face.bbox
            left = int(box.xmin * w)
            top = int(box.ymin * h)
            right = int(box.xmax * w)
            bottom = int(box.ymax * h)
            targets.append((left, top, right, bottom))
            
        return targets 
    
        