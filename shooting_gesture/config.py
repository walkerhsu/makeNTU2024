import torch.nn as nn

TRAIN_SPLIT_PERCENTAGE = 0.8
LEARNING_RATE = 0.0001
BATCH_SIZE = 16
EPOCHS = 160
WIDTH = 1920
HEIGHT = 1080
GESTURES = ['aim', 'shoot', 'observe', 'idle']


class Model(nn.Module):
    def __init__(self):
        super(Model, self).__init__()
        self.func = nn.Sequential(
            nn.Linear(64, 128),
            nn.ReLU(),
            nn.Linear(128, 128),
            nn.Sigmoid(),
            nn.Linear(128, 2)
        )

    def forward(self, x):
        x = self.func(x)
        return x


class GCModel(nn.Module):
    def __init__(self):
        super(GCModel, self).__init__()
        self.func = nn.Sequential(
            nn.Linear(64, 128),
            nn.ReLU(),
            nn.Linear(128, 128),
            nn.Sigmoid(),
            nn.Linear(128, 4)
        )

    def forward(self, x):
        x = self.func(x)
        return x
