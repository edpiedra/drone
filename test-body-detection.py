from src.utilities.orbbec_astra import Astra 
from src.utilities.body_cascade import BodyCascade

camera = Astra()
body_cascade = BodyCascade()

while True:
    try:
        depth_frame = camera.get_depth_frame()
        color_frame = camera.get_color_frame()
        
        upper_bodies, full_bodies = body_cascade.detect_bodies(color_frame)
        
        print('upper bodies: ', upper_bodies)
        print('full bodies: ', full_bodies)
    except KeyboardInterrupt:
        break
    
camera.__destroy__()