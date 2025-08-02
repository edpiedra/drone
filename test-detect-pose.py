import cv2
import numpy as np
import tflite_runtime.interpreter as tflite

MODEL_PATH = "models/pose_detection/lite-model_movenet_singlepose_lightning_tflite_float16_4.tflite"
interpreter = tflite.Interpreter(model_path=MODEL_PATH)
interpreter.allocate_tensors()

input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

def draw_keypoints(frame, keypoints, confidence_threshold):
    h, w, _ = frame.shape
    for kp in keypoints[0, 0, :, :]:
        y, x, c = kp
        if c > confidence_threshold:
            cx, cy = int(x * w), int(y * h)
            cv2.circle(frame, (cx, cy), 3, (255, 0, 0), -1)

camera = Astra()
while True:
    frame = camera.get_color_frame()
    _ = camera.get_depth_frame()
    
    img = cv2.resize(frame, (192, 192))
    input_data = np.expand_dims(img.astype(np.float32), axis=0)

    interpreter.set_tensor(input_details[0]['index'], input_data)
    interpreter.invoke()
    keypoints = interpreter.get_tensor(output_details[0]['index'])

    draw_keypoints(frame, keypoints, 0.3)
    cv2.imshow('Pose Detection', frame)
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break
camera.__destroy__()
cv2.destroyAllWindows()
