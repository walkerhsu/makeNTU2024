import json
import os

data = []
for file in os.listdir('data'):
    if file.endswith('.json') and file != 'all_data.json':
        with open(os.path.join('data', file), 'r') as f:
            data += json.load(f)
            print(len(data))

with open('data/all_data.json', 'w') as f:
    json.dump(data, f)

data = {}
for file in os.listdir('gc_data'):
    if file.endswith('.json') and file != 'all_data.json':
        with open(os.path.join('gc_data', file), 'r') as f:
            new_data = json.load(f)
            for key in new_data:
                if key not in data:
                    data[key] = []
                data[key] += new_data[key]
for key in data:
    print(key, len(data[key]))
with open('gc_data/all_data.json', 'w') as f:
    json.dump(data, f)
