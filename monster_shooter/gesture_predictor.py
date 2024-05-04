import sys
sys.path.append('..')
import threading
from mediapipe.tasks.python import vision
from mediapipe.tasks import python
import mediapipe as mp
import numpy as np
import cv2
from shooting_gesture import Predictor, HAND_LANMARKER_MODEL_PATH


class GesturePredictor:
    def __init__(self, camera_num=0, hide_camera=False) -> None:
        self.hide_camera = hide_camera
        self.predictor = Predictor(pos_k=8, gc_k=5)
        base_options = python.BaseOptions(
            model_asset_path=HAND_LANMARKER_MODEL_PATH)
        options = vision.HandLandmarkerOptions(base_options=base_options,
                                               num_hands=1)
        self.detector = vision.HandLandmarker.create_from_options(options)
        self.cap = cv2.VideoCapture(camera_num)
        self.CAM_WIDTH = int(self.cap.get(cv2.CAP_PROP_FRAME_WIDTH))
        self.CAM_HEIGHT = int(self.cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
        self.gesture = None
        self.pos = None
        self.frame = None

    def _get_landmarks(self, frame):
        # Convert the BGR image to RGB.
        rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        rgb_frame = mp.Image(image_format=mp.ImageFormat.SRGB, data=rgb_frame)

        # Process the frame with MediaPipe Hands.
        results = self.detector.detect(rgb_frame)
        landmark_list = results.hand_landmarks
        handedness_list = results.handedness
        if landmark_list:
            landmark_list = [(landmark.x * self.CAM_WIDTH, landmark.y * self.CAM_HEIGHT, landmark.z)
                             for landmark in landmark_list[0]]

        return landmark_list

    def _run_prediction(self):
        while self.running:
            ret, frame = self.cap.read()
            if not ret:
                return None, None

            landmark_list = self._get_landmarks(frame)
            gesture, pos = self.predictor.predict(landmark_list)
            self.gesture = gesture
            self.pos = pos
            if not self.hide_camera:
                for i, landmark in enumerate(landmark_list):
                    frame = cv2.circle(
                        frame, (int(landmark[0]), int(landmark[1])), 5, (0, 255, 0), -1)
                    # add index to image
                    frame = cv2.putText(frame, str(i), (int(landmark[0]), int(
                        landmark[1])), cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 0, 255), 2, cv2.LINE_AA)
            self.frame = frame


    def run(self):
        self.running = True
        t = threading.Thread(target=self._run_prediction)
        t.daemon = True
        t.start()
        

    def get_gesture(self, width=1920, height=1080):
        if self.pos is None:
            return self.gesture, None, self.frame
        return self.gesture, (self.pos[0]*width, self.pos[1]*height), self.frame

    def end(self):
        self.running = False
        self.cap.release()
        cv2.destroyAllWindows()
