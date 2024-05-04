import torch
import numpy as np
import sys
import os
sys.path.append(os.path.dirname(__file__))
from config import *
from collections import Counter


class Predictor:
    def __init__(self, pos_k=7, gc_k=5, aim_k = 9):
        self.shooting_model = Model()
        model_path = os.path.join(os.path.dirname(__file__), 'models/best.pt')
        self.shooting_model.load_state_dict(torch.load(model_path))
        self.shooting_model.eval()

        self.gc_model = GCModel()
        gc_model_path = os.path.join(os.path.dirname(__file__), 'gc_models/best.pt')
        self.gc_model.load_state_dict(torch.load(gc_model_path))
        self.gc_model.eval()
        self.positions = []
        self.predictions = []
        self.past_aims = []
        self.pos_k = pos_k
        self.gc_k = gc_k
        self.aim_k = aim_k

    def _most_common_string(self, lst):
        counter = Counter(lst)
        return counter.most_common(1)[0][0]

    def _update_predictions(self, pred):
        self.predictions.append(pred)
        if len(self.predictions) > self.gc_k:
            self.predictions.pop(0)

    def predict(self, landmarks):
        if not landmarks:
            self._update_predictions('idle')
            return 'idle', None
        landmarks = np.array(landmarks).flatten()
        landmarks = np.append(landmarks, 1)
        landmarks = torch.tensor(landmarks, dtype=torch.float32)
        landmarks = landmarks.unsqueeze(0)

        result = torch.argmax(self.gc_model(landmarks)).item()
        self._update_predictions(GESTURES[result])
        result = self._most_common_string(self.predictions)
        if result == 'aim':
            pos = self.shooting_model(landmarks).detach().numpy().flatten()
            self.positions.append(pos)
            if len(self.positions) > self.pos_k:
                self.positions.pop(0)
            pos = np.mean(self.positions, axis=0)
            self.past_aims.append(pos)
            if len(self.past_aims) > self.aim_k:
                self.past_aims.pop(0)
            return result, pos

        if result == 'shoot':
            if not self.past_aims:
                return 'idle', None
            pos = np.mean(self.past_aims, axis=0)
            k = len(self.past_aims)
            weights = np.array(range(k, 0, -1))
            weights = weights / np.sum(weights)
            pos = np.sum(np.array(self.past_aims) * weights[:, None], axis=0)
            return result, tuple(pos)
        
        return result, None
