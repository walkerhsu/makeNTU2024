import torch
import numpy as np
from config import Model


class Predictor:
    def __init__(self, k):
        self.model = Model()
        self.model.load_state_dict(torch.load('models/best.pt'))
        self.model.eval()
        self.predictions = []
        self.k = k

    def predict(self, landmarks):
        landmarks = np.array(landmarks).flatten()
        landmarks = np.append(landmarks, 1)
        landmarks = torch.tensor(landmarks, dtype=torch.float32)
        landmarks = landmarks.unsqueeze(0)
        result = self.model(landmarks).detach().numpy().flatten()
        self.predictions.append(result)
        if len(self.predictions) > self.k:
            self.predictions.pop(0)
        return np.mean(self.predictions, axis=0)
