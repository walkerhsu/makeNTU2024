import json
import os

data = []
for file in os.listdir('data'):
    if file.endswith('.json'):
        with open(os.path.join('data', file), 'r') as f:
            data += json.load(f)
            print(len(data))

with open('data/all_data.json', 'w') as f:
    json.dump(data, f)
