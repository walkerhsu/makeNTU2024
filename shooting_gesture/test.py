import cv2
import numpy as np
import mediapipe as mp
from mediapipe.tasks import python
from mediapipe.tasks.python import vision
from predictor import Predictor

SELF_VIEW = True

data = []

base_options = python.BaseOptions(model_asset_path='hand_landmarker.task')
options = vision.HandLandmarkerOptions(base_options=base_options,
                                       num_hands=1)
detector = vision.HandLandmarker.create_from_options(options)
cap = cv2.VideoCapture(0)
CAM_WIDTH = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
CAM_HEIGHT = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
predictor = Predictor(10)


def get_landmarks(frame):
    # Convert the BGR image to RGB.
    rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
    rgb_frame = mp.Image(image_format=mp.ImageFormat.SRGB, data=rgb_frame)

    # Process the frame with MediaPipe Hands.
    results = detector.detect(rgb_frame)
    landmark_list = results.hand_landmarks
    handedness_list = results.handedness
    if landmark_list:
        landmark_list = [(landmark.x * CAM_WIDTH, landmark.y * CAM_HEIGHT, landmark.z)
                         for landmark in landmark_list[0]]

    return landmark_list


cv2.namedWindow('main', cv2.WINDOW_NORMAL)
WIDTH, HEIGHT = 1920, 1080

running = True
while running:

    ret, frame = cap.read()
    if not ret:
        continue

    landmark_list = get_landmarks(frame)
    if landmark_list:
        circle_radius = 100
        circle_pos = predictor.predict(landmark_list)
        circle_pos = (int(circle_pos[0]*WIDTH), int(circle_pos[1]*HEIGHT))

        screen = np.zeros((HEIGHT, WIDTH, 3), np.uint8)
        cv2.circle(screen, circle_pos, circle_radius, (255, 0, 0), -1)
        cv2.imshow('main', screen)

    if SELF_VIEW:
        for i, landmark in enumerate(landmark_list):
            frame = cv2.circle(
                frame, (int(landmark[0]), int(landmark[1])), 5, (0, 255, 0), -1)
            # add index to image
            frame = cv2.putText(frame, str(i), (int(landmark[0]), int(
                landmark[1])), cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 0, 255), 2, cv2.LINE_AA)

        # Display the frame with detected landmarks.
        cv2.imshow('Hand Landmarks', frame)

    # Exit the loop if 'q' is pressed or Exit windows is pressed.
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()
