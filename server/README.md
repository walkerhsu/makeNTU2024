# MakeNTU server

## Setup

### Production

```bash
# prepare for .env
docker compose up -d
```

### Local

```bash
# create conda env (python 3.9)
# prepare for .env

pip install -r requirements.txt

docker compose -f docker-compose-dev.yml up -d
python server.py
```
