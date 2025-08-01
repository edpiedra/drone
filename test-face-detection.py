from src.utilities.orbbec_astra import Astra 
from src.utilities.face_detection import TFFaceDetection

camera = Astra()
face_detect = TFFaceDetection()

while True:
    try:
        depth = camera.get_depth_frame()
        color = camera.get_color_frame()
        
        targets = face_detect.detect_faces(color)
        print(targets)
    except KeyboardInterrupt:
        break
    
camera.__destroy__()