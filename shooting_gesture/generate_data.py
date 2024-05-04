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

SELF_VIEW = False
WIDTH, HEIGHT = 1920, 1080

data = []

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
    text_x = (frame.shape[1] - text_size[0]) // 2
    text_y = (frame.shape[0] + text_size[1]) // 2
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


cv2.namedWindow('main', cv2.WINDOW_NORMAL)
screen = np.zeros((HEIGHT, WIDTH, 3), np.uint8)
starting_screen = put_multiple_text(screen, [
    'Instructions',
    '1. Maximize your screen',
    '2. Press q and Start drawing path with mouse',
    '3. Press q to start following the path with your finger',
], int(WIDTH/2), int(HEIGHT/2))


while True:
    cv2.imshow('main', starting_screen)
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break
    if cv2.getWindowProperty('main', cv2.WND_PROP_VISIBLE) < 1:
        sys.exit(0)

path = []


def draw_path(event, x, y, flags, param):
    global screen
    global path
    if event == cv2.EVENT_LBUTTONDOWN:
        cv2.circle(screen, (x, y), 5, (0, 0, 255), -1)
        print(x, y)
        path.append((x, y))
    elif event == cv2.EVENT_MOUSEMOVE and flags == cv2.EVENT_FLAG_LBUTTON:
        cv2.circle(screen, (x, y), 5, (0, 0, 255), -1)
        print(x, y)
        path.append((x, y))


# draw path with mouse
screen = np.zeros((HEIGHT, WIDTH, 3), np.uint8)
cv2.imshow('main', screen)
cv2.setMouseCallback('main', draw_path)
while True:
    cv2.imshow('main', screen)
    screen[:40, :400] = 0
    cv2.putText(screen, f'Path length: {len(path)}', (10, 30),
                cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 0, 255), 2, cv2.LINE_AA)
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break
    if cv2.getWindowProperty('main', cv2.WND_PROP_VISIBLE) < 1:
        sys.exit(0)
cv2.setMouseCallback('main', lambda *args: None)

circle_radius = 100
circle_pos = path[0]
circle_index = 0

# count down
for i in range(3, 0, -1):
    screen = np.zeros((HEIGHT, WIDTH, 3), np.uint8)
    screen = cv2.circle(screen, circle_pos, circle_radius, (255, 0, 0), -1)
    screen = put_text(screen, str(i), WIDTH//2, HEIGHT//2, font_size=10)
    cv2.imshow('main', screen)
    time.sleep(1)


def update_circle_pos():
    global circle_pos
    global circle_index
    global circle_radius
    global path
    circle_index += 1
    if circle_index >= len(path):
        return False
    circle_pos = path[circle_index]
    return True


data = []
running = True
while running:

    screen = np.zeros((HEIGHT, WIDTH, 3), np.uint8)
    cv2.circle(screen, circle_pos, circle_radius, (255, 0, 0), -1)
    cv2.putText(screen, f'Data length: {len(data)}', (10, 30),
                cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 0, 255), 2, cv2.LINE_AA)
    cv2.imshow('main', screen)
    running = update_circle_pos()

    ret, frame = cap.read()
    if not ret:
        continue

    landmark_list = get_landmarks(frame)
    if landmark_list:
        data.append(
            (landmark_list, (circle_pos[0]/WIDTH, circle_pos[1]/HEIGHT)))

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

now = datetime.now()
time_string = now.strftime("%Y-%m-%d_%H-%M-%S")
print(time_string)
with open(os.path.join('data', f'{time_string}.json'), 'w') as f:
    json.dump(data, f)
print(f'{len(data)} data saved')
