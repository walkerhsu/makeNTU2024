import torch
import numpy as np
from config import *
from collections import Counter


class Predictor:
    def __init__(self, pos_k=5, gc_k=5):
        self.shooting_model = Model()
        self.shooting_model.load_state_dict(torch.load('models/best.pt'))
        self.shooting_model.eval()

        self.gc_model = GCModel()
        self.gc_model.load_state_dict(torch.load('gc_models/best.pt'))
        self.gc_model.eval()
        self.positions = []
        self.predictions = []
        self.pos_k = pos_k
        self.gc_k = gc_k

    def most_common_string(self, lst):
        counter = Counter(lst)
        return counter.most_common(1)[0][0]

    def update_predictions(self, pred):
        self.predictions.append(pred)
        if len(self.predictions) > self.gc_k:
            self.predictions.pop(0)

    def predict(self, landmarks):
        if not landmarks:
            self.update_predictions('idle')
            return 'idle', None
        landmarks = np.array(landmarks).flatten()
        landmarks = np.append(landmarks, 1)
        landmarks = torch.tensor(landmarks, dtype=torch.float32)
        landmarks = landmarks.unsqueeze(0)

        result = torch.argmax(self.gc_model(landmarks)).item()
        self.update_predictions(GESTURES[result])
        result = self.most_common_string(self.predictions)
        if result == 'aim':
            pos = self.shooting_model(landmarks).detach().numpy().flatten()
            self.positions.append(pos)
            if len(self.positions) > self.pos_k:
                self.positions.pop(0)
            pos = np.mean(self.positions, axis=0)
            return result, pos
        return result, None
