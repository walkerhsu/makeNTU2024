import cv2
import mediapipe as mp
from mediapipe.tasks import python
from mediapipe.tasks.python import vision
from mediapipe.framework.formats import landmark_pb2

# Initialize MediaPipe Hands.
base_options = python.BaseOptions(model_asset_path='hand_landmarker.task')
options = vision.HandLandmarkerOptions(base_options=base_options,
                                       num_hands=2)
detector = vision.HandLandmarker.create_from_options(options)

# Initialize OpenCV's VideoCapture.
cap = cv2.VideoCapture(0)
w = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
h = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))


def get_landmarks(frame):
    # Convert the BGR image to RGB.
    rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
    rgb_frame = mp.Image(image_format=mp.ImageFormat.SRGB, data=rgb_frame)

    # Process the frame with MediaPipe Hands.
    results = detector.detect(rgb_frame)
    landmark_list = results.hand_landmarks
    handedness_list = results.handedness
    if landmark_list:
        landmark_list = [(landmark.x * w, landmark.y * h, landmark.z)
                         for landmark in landmark_list[0]]

    return landmark_list


while cap.isOpened():
    ret, frame = cap.read()
    if not ret:
        continue

    landmark_list = get_landmarks(frame)

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
    elif cv2.getWindowProperty('Hand Landmarks', cv2.WND_PROP_VISIBLE) < 1:
        break


# Release resources.
cap.release()
cv2.destroyAllWindows()
