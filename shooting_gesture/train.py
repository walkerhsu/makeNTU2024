from datetime import datetime
import random
import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import DataLoader
from config import *
import numpy as np

import json
import os

with open('data/all_data.json', 'r') as f:
    data = json.load(f)

data = [(np.append(np.array(x, np.float32).flatten(), 1), np.array(y))
        for x, y in data]
# to dtype float32
data = [(torch.tensor(x, dtype=torch.float32), torch.tensor(y, dtype=torch.float32))
        for x, y in data]

print(len(data))
print(data[0][0].shape)
print(data[0][1].shape)

# Split the data into training and validation sets.
split = int(TRAIN_SPLIT_PERCENTAGE * len(data))
random.shuffle(data)
train_data = data[:split]
val_data = data[split:]


# Define the loss function and optimizer.
model = Model()
criterion = nn.MSELoss()
optimizer = optim.Adam(model.parameters(), lr=LEARNING_RATE)

# Define the data loader.
train_loader = DataLoader(train_data, batch_size=BATCH_SIZE, shuffle=True)
val_data = DataLoader(val_data, batch_size=BATCH_SIZE, shuffle=True)

best_loss = float('inf')
best_model = None

# Train the model.
for epoch in range(EPOCHS):
    model.train()
    total_loss = 0
    for i, batch in enumerate(train_loader):
        optimizer.zero_grad()
        x, y = batch
        y_pred = model(x)
        loss = criterion(y_pred, y)
        loss.backward()
        optimizer.step()
        total_loss += loss.item()
    print(f'Epoch {epoch}, train loss: {total_loss / len(train_loader)}')

    model.eval()
    with torch.no_grad():
        total_loss = 0
        for i, batch in enumerate(val_data):
            x, y = batch
            y_pred = model(x)
            loss = criterion(y_pred, y)
            total_loss += loss.item()
        print(f'Epoch {epoch}, validation loss: {total_loss / len(val_data)}')
        if total_loss < best_loss:
            best_loss = total_loss
            best_model = model.state_dict()

# Save the model.
now = datetime.now()
time_string = now.strftime("%Y-%m-%d_%H-%M-%S")

torch.save(best_model, os.path.join('models', f'{time_string}.pt'))
