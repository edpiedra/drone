import cv2 
from typing import Sequence

class BodyCascade:
    def __init__(self):
        self.upper_body = cv2.CascadeClassifier(cv2.data.haarcascades + 'haarcascade_upperbody.xml')
        self.full_body = cv2.CascadeClassifier(cv2.data.haarcascades + 'haarcascade_fullbody.xml')
        
    def detect_bodies(self, frame: cv2.Mat) -> tuple[Sequence[Sequence[int]], Sequence[Sequence[int]]]:
        '''
        Detects upper and full bodies in a frame.
        
        Args:
            frame : video frame
        Returns:
            upper_bodies, lower_bodies : a sequence of tuples with (x, y, w, h) for each detection.
        '''
        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        
        upper_bodies = self.upper_body.detectMultiScale(gray, 1.1, 3)
        full_bodies = self.full_body.detectMultiScale(gray, 1.1, 3)
        
        return upper_bodies, full_bodies