from gesture_predictor import GesturePredictor
import cv2
import time
g = GesturePredictor()
g.run()
start_time = time.time()
while time.time()-start_time < 10:
    gesture, pos, frame =  g.get_gesture()
    print(gesture, pos)
g.end()

