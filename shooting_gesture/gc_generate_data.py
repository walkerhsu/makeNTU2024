import time
import os
from datetime import datetime
import json
import sys
import cv2
import numpy as np
import mediapipe as mp
from mediapipe.tasks import python
from mediapipe.tasks.python import vision

SELF_VIEW = True
WIDTH, HEIGHT = 1920, 1080

data = {}
DATA_COUNT = 100
BREAKTIME = 0.5

base_options = python.BaseOptions(model_asset_path='hand_landmarker.task')
options = vision.HandLandmarkerOptions(base_options=base_options,
                                       num_hands=1)
detector = vision.HandLandmarker.create_from_options(options)
cap = cv2.VideoCapture(0)
CAM_WIDTH = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
CAM_HEIGHT = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))


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


def put_text(frame, text, x, y, font_size=1, color=(255, 255, 255)):
    font = cv2.FONT_HERSHEY_SIMPLEX
    font_scale = 1
    font_thickness = 2
    text_size, _ = cv2.getTextSize(text, font, font_scale, font_thickness)
    text_x = x - text_size[0] // 2
    text_y = y - text_size[1] // 2
    return cv2.putText(frame, text, (text_x, text_y), font,
                       font_scale, color, font_thickness, cv2.LINE_AA)


def put_multiple_text(frame, text_list, x, y, font_size=1, color=(255, 255, 255)):
    font = cv2.FONT_HERSHEY_SIMPLEX
    font_scale = 1
    font_thickness = 2
    for i, text in enumerate(text_list):
        text_size, _ = cv2.getTextSize(
            text, font, font_scale, font_thickness)
        text_height = text_size[1] + 20
        half_lines = len(text_list)/2
        text_x = x - text_size[0] // 2
        text_y = y - text_size[1] // 2 + (i-half_lines)*text_height
        frame = cv2.putText(frame, text, (int(text_x), int(text_y)), font,
                            font_scale, color, font_thickness, cv2.LINE_AA)
    return frame


GESTURES = ['aim', 'shoot', 'observe', 'idle']
last_time = time.time()
for gesture in GESTURES:
    data[gesture] = []
    running = True
    while running:

        ret, frame = cap.read()
        if not ret:
            continue
        frame = cv2.putText(frame, gesture, (10, 30),
                            cv2.FONT_HERSHEY_SIMPLEX, 1, (255, 255, 255), 2, cv2.LINE_AA)

        landmark_list = get_landmarks(frame)
        if landmark_list and time.time() - last_time > BREAKTIME:
            data[gesture].append(landmark_list)
            last_time = time.time()
        for i, landmark in enumerate(landmark_list):
            frame = cv2.circle(
                frame, (int(landmark[0]), int(landmark[1])), 5, (0, 255, 0), -1)
            # add index to image
            frame = cv2.putText(frame, str(i), (int(landmark[0]), int(
                landmark[1])), cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 0, 255), 2, cv2.LINE_AA)

        # Display the frame with detected landmarks.
        frame = cv2.putText(frame, f'{len(data[gesture])}/{DATA_COUNT}', (10, 60),
                            cv2.FONT_HERSHEY_SIMPLEX, 1, (255, 255, 255), 2, cv2.LINE_AA)
        cv2.imshow('Hand Landmarks', frame)

        if len(data[gesture]) >= DATA_COUNT:
            break

        # Exit the loop if 'q' is pressed or Exit windows is pressed.
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break
        if cv2.getWindowProperty('Hand Landmarks', cv2.WND_PROP_VISIBLE) < 1:
            sys.exit(0)
    screen = np.zeros((HEIGHT, WIDTH, 3), np.uint8)
    screen = put_text(screen, 'Please change your gesture',
                      WIDTH//2, HEIGHT//2)
    cv2.imshow('Hand Landmarks', screen)
    cv2.waitKey(1000)

cap.release()
cv2.destroyAllWindows()

now = datetime.now()
time_string = now.strftime("%Y-%m-%d_%H-%M-%S")
print(time_string)
with open(os.path.join('gc_data', f'{time_string}.json'), 'w') as f:
    json.dump(data, f)
print(f'{len(data)} data saved')
