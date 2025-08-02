import cv2
import numpy as np
import tflite_runtime.interpreter as tflite

MODEL_PATH = "models/face_detection/face_detection_front.tflite"
interpreter = tflite.Interpreter(model_path=MODEL_PATH)
interpreter.allocate_tensors()

input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

camera = Astra()

while True:
    frame = camera.get_color_frame()
    _ = camera.get_depth_frame()
    
    img = cv2.resize(frame, (128, 128))
    input_data = np.expand_dims(img.astype(np.float32), axis=0)

    interpreter.set_tensor(input_details[0]['index'], input_data)
    interpreter.invoke()

    boxes = interpreter.get_tensor(output_details[0]['index'])[0]
    scores = interpreter.get_tensor(output_details[1]['index'])[0]

    for i in range(len(scores)):
        if scores[i] > 0.5:
            y1, x1, y2, x2 = boxes[i]
            h, w, _ = frame.shape
            x1, y1, x2, y2 = int(x1 * w), int(y1 * h), int(x2 * w), int(y2 * h)
            cv2.rectangle(frame, (x1, y1), (x2, y2), (0, 0, 255), 2)

    cv2.imshow("Face Detection", frame)
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break
camera.__destroy__()
cv2.destroyAllWindows()
