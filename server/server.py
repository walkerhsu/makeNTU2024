#!/usr/bin/env python
from typing import List
from fastapi import FastAPI, Form, Response, HTTPException, File, UploadFile
import os
from openai import OpenAI
from dotenv import load_dotenv
from contextlib import asynccontextmanager
import pymongo
import numpy as np
import json
from pydantic import BaseModel
from gridfs import GridFS

class Status(BaseModel):
    status: str

col, row = 1, 2

@asynccontextmanager
async def lifespan(app: FastAPI):
    MONGO_URL = os.environ.get('MONGO_URL')
    try:
        app.client = OpenAI()
        app.thread = app.client.beta.threads.create()
        app.story_assistant_id = os.environ.get('GEN_STORY_ASSISTANT_ID')
        app.outline_assistant_id = os.environ.get('GEN_OUTLINE_ASSISTANT_ID')
        app.summary_assistant_id = os.environ.get('GEN_SUMMARY_ASSISTANT_ID')
        app.idx = [0, 0]
        app.model = "gpt-4-turbo"
        app.mongodb_client = pymongo.MongoClient(MONGO_URL, serverSelectionTimeoutMS = 1000)
        app.mongodb_client.server_info()
        print(f"MongoDB connected at {MONGO_URL}")
    except:
        raise Exception(f'Cannot connect to {MONGO_URL}')
    
    app.db = app.mongodb_client['db']
    app.db['user'].drop()
    app.db['is_battle'].drop()
    app.db['status'].drop()
    app.db['monsters'].drop()
    app.db['chat_history'].drop()
    app.db['cur_ele'].drop()
    app.db['cur_img'].drop()
    
    app.db['is_battle'].insert_one({
        'is_battle': False
    })
    app.db['user'].insert_one({
        "HP": 0,
        "ATK": 0,
        "MAXAMMO": 0,
        "RELTIME": 0
    })
    app.img_db = app.mongodb_client['img_db']
    # app.db.is_battle.find_one_and_update({}, {}, {})
    yield
    
    app.mongodb_client.close()
    
load_dotenv()
# client = OpenAI()
app = FastAPI(lifespan=lifespan)

@app.get('/')
async def main():
    return Response(content='<h1>This is a makentu server.</h1>', media_type='text/html')

@app.get('/create_story')
async def create_story(category: str = "冒險", start: str = '台北', dest: str = "高雄"):
    # create outline or read existing outline
    f = open('outlines/outline.json')
    app.outline = json.load(f)
    f.close()
    
    # outline_content = {
    #     "Type": category, 
    #     "Starting Point": start, 
    #     "Ending Point": dest
    # }
    # app.client.beta.threads.messages.create(
    #     thread_id=app.thread.id,
    #     role="user",
    #     content=json.dumps(outline_content),
    # )
    # outline_run = app.client.beta.threads.runs.create_and_poll(
    #     thread_id=app.thread.id,
    #     assistant_id=app.outline_assistant_id,
    # )
    # if outline_run.status == 'completed': 
    #     messages = app.client.beta.threads.messages.list(
    #         thread_id=app.thread.id
    #     )
    #     response = messages.data[0].content[0].text.value
    #     # print(response)
    #     app.outline = json.loads(response)
    # else:
    #     print(outline_run.status)
    
    print(app.outline, flush=True)
    app.idx = [0, 0]
    
    user_input = {
        "previous choice": "",
        "current outline": app.outline['outline'][list(app.outline['outline'].keys())[app.idx[0]]][app.idx[1]],
        "next outline": app.outline['outline'][list(app.outline['outline'].keys())[app.idx[0]]][app.idx[1]+1],
        "elements": "",
        "status": "start"
    },
    
    app.client.beta.threads.messages.create(
        thread_id=app.thread.id,
        role="user",
        content=json.dumps(user_input),
    )
    run = app.client.beta.threads.runs.create_and_poll(
        thread_id=app.thread.id,
        assistant_id=app.story_assistant_id,
    )
    response = ''
    if run.status == 'completed':
        messages = app.client.beta.threads.messages.list(
            thread_id=app.thread.id
        )
        response = messages.data[0].content[0].text.value
    else:
        raise Exception(f"{run.status} is not 'completed'")
    
    print(response)
    story = json.loads(response)['story']
    app.db['chat_history'].insert_one({
        'story': story, 'timestamp': app.idx
    })
    
    app.idx[1] += 1
    return Response(response, headers={"Content-Type": "text/json;charset=UTF-8"})

@app.get('/story_response')
async def story_response(choice: str = ''):        
    # check whether game should be triggered
    print(app.idx, flush=True)
    cur_ele = list(app.db['cur_ele'].find({}, {'_id': 0}))
    ele = [dic['desc'] for dic in cur_ele]
    app.db['cur_ele'].drop()
    
    if choice != '':
        if app.idx[1] == row - 1:
            user_input = {
                "previous choice": choice,
                "current outline": app.outline['outline'][list(app.outline['outline'].keys())[app.idx[0]]][app.idx[1]],
                "next outline": "",
                "elements": f"{ele}",
                "status": "final" if app.idx[0] == col-1 else "battle"
            },
            
            print(user_input, flush=True)
            
            app.client.beta.threads.messages.create(
                thread_id=app.thread.id,
                role="user",
                content=json.dumps(user_input),
            )
            run = app.client.beta.threads.runs.create_and_poll(
                thread_id=app.thread.id,
                assistant_id=app.story_assistant_id,
            )
            response = ''
            if run.status == 'completed':
                messages = app.client.beta.threads.messages.list(
                    thread_id=app.thread.id
                )
                response = messages.data[0].content[0].text.value
            else:
                raise Exception(f"{run.status} is not 'completed'")
            
            print(response)
            story = json.loads(response)['story']
            app.db['chat_history'].insert_one({
                'story': story, 'timestamp': app.idx
            })
            
            # generate monsters
            app.db.monsters.drop()
            app.db.status.drop()
            monster_response = json.loads(response)['monsters']
            # print(monster_response.choices[0].message.content)
            app.db.monsters.insert_many(monster_response)
            app.idx[0] += 1
            app.idx[1] = 0
            
        else:
            user_input = {
                "previous choice": choice,
                "current outline": app.outline['outline'][list(app.outline['outline'].keys())[app.idx[0]]][app.idx[1]],
                "next outline": app.outline['outline'][list(app.outline['outline'].keys())[app.idx[0]]][app.idx[1]+1],
                "elements": f"{ele}",
                "status": ""
            }
            print(user_input, flush=True)
            
            app.client.beta.threads.messages.create(
                thread_id=app.thread.id,
                role="user",
                content=json.dumps(user_input),
            )
            run = app.client.beta.threads.runs.create_and_poll(
                thread_id=app.thread.id,
                assistant_id=app.story_assistant_id,
            )
            response = ''
            if run.status == 'completed':
                messages = app.client.beta.threads.messages.list(
                    thread_id=app.thread.id
                )
                response = messages.data[0].content[0].text.value
            else:
                raise Exception(f"{run.status} is not 'completed'")
            
            print(response)
            story = json.loads(response)['story']
            app.db['chat_history'].insert_one({
                'story': story, 'timestamp': app.idx
            })
            
            app.idx[1] += 1
    elif app.idx[0] <= col - 1:
        user_input = {
            "previous choice": "",
            "current outline": app.outline['outline'][list(app.outline['outline'].keys())[app.idx[0]]][app.idx[1]],
            "next outline": app.outline['outline'][list(app.outline['outline'].keys())[app.idx[0]]][app.idx[1]+1],
            "elements": f"{ele}",
            "status": ""
        },
        
        app.client.beta.threads.messages.create(
            thread_id=app.thread.id,
            role="user",
            content=json.dumps(user_input),
        )
        run = app.client.beta.threads.runs.create_and_poll(
            thread_id=app.thread.id,
            assistant_id=app.story_assistant_id,
        )
        response = ''
        if run.status == 'completed':
            messages = app.client.beta.threads.messages.list(
                thread_id=app.thread.id
            )
            response = messages.data[0].content[0].text.value
        else:
            raise Exception(f"{run.status} is not 'completed'")
        
        story = json.loads(response)['story']
        app.db['chat_history'].insert_one({
            'story': story, 'timestamp': app.idx
        })
        
        app.idx[1] += 1
    else:
        user_input = {
            "previous choice": "",
            "current outline": "",
            "next outline": "",
            "elements": f"{ele}",
            "status": "end"
        },
        
        app.client.beta.threads.messages.create(
            thread_id=app.thread.id,
            role="user",
            content=json.dumps(user_input),
        )
        run = app.client.beta.threads.runs.create_and_poll(
            thread_id=app.thread.id,
            assistant_id=app.story_assistant_id,
        )
        response = ''
        if run.status == 'completed':
            messages = app.client.beta.threads.messages.list(
                thread_id=app.thread.id
            )
            response = messages.data[0].content[0].text.value
        else:
            raise Exception(f"{run.status} is not 'completed'")
        
        story = json.loads(response)['story']
        app.db['chat_history'].insert_one({
            'story': story, 'timestamp': app.idx
        })
        
        app.idx[1] += 1
            
    return Response(response, headers={"Content-Type": "text/json;charset=UTF-8"})
    
@app.post('/ready_battle')
async def ready_battle():
    monsters = [*app.db.monsters.find()]
    if len(monsters) > 0:
        app.db.is_battle.find_one_and_update({}, {
            '$set':{'is_battle': True}
        })
        return Response("Ready battle successful")
    return HTTPException(403, "Monsters size is not positive!!")

@app.get('/is_battle')
async def is_battle():
    is_battle = app.db.is_battle.find_one({}, {'_id': 0})
    return Response(str(is_battle['is_battle']))

@app.get('/get_db')
async def get_db_data(col_name: str = 'chat_history'):
    data = app.db[col_name].find({}, {'_id': 0})
    return Response(json.dumps([*data], ensure_ascii=False), headers={"Content-Type": "text/json;charset=UTF-8"})

# @app.get('/get_db_one')
# async def get_db_data(db_name: str = 'chat_history'):
#     app.db[db_name].insert_one({
#         'status': 'win'
#     })
#     data = app.db[db_name].find_one({}, {'_id': 0})
    
#     print(data is not None)
#     return Response(json.dumps(data, ensure_ascii=False), headers={"Content-Type": "text/json;charset=UTF-8"})

@app.get('/clear_db_data')
async def clear_db_data(col_name: str = 'chat_history'):
    app.db[col_name].drop()
    return Response(f"Deleted Collection {col_name} successfully")

@app.get('/clear_db')
async def clear_db(db_name: str = 'img_db'):
    app.mongodb_client.drop_database(db_name)
    return Response(f"Deleted database {db_name} successfully")

@app.get('/get_user_info')
async def get_user_info():
    user = app.db.user.find({}, {"_id": 0})
    return Response(json.dumps([*user]), headers={"Content-Type": "text/json;charset=UTF-8"})

@app.get('/get_monsters_info')
async def get_monster_info():
    monsters = app.db.monsters.find({}, {"_id": 0})
    return Response(json.dumps([*monsters]), headers={"Content-Type": "text/json;charset=UTF-8"})
    
@app.get("/game_is_ended")
async def game_is_ended():
    status = app.db.status.find_one({}, {'_id': 0})
    print(status)
    if status is not None:
        return Response(status['status'], headers={"Content-Type": "text/plain;charset=UTF-8"})
    else:
        return Response("playing")

@app.post("/game_ended")
async def game_ended(status:Status):
    if status.status.lower() == 'win' or status.status.lower() == 'lose':
        app.db.status.insert_one({
            'status': status.status.lower()
        })
        app.db.is_battle.find_one_and_update({}, {'$set': {'is_battle': False}})
        return Response("Status updated successfully", 200)
    else:
        return HTTPException(403, "Status is invalid")

@app.post("/save_pic")
async def save_pic(description: str = Form(...),file: UploadFile = File(...)):
    fs = GridFS(app.img_db)
    print(description)
    contents = await file.read()
    fs.put(contents, filename=file.filename)
    # record filename, desc, timestamp (for memories)
    app.db['pic_info'].insert_one({
        "filename": file.filename, "desc": description, "timestamp": app.idx
    })
    app.db['cur_ele'].insert_one({"desc": description})
    app.db['cur_img'].insert_one({"filename": file.filename})
    return Response(f"Filename {file.filename} saved successfully")

@app.get('/get_cur_pics')
async def get_cur_pics():
    filenames = list(app.db['cur_img'].find({}, {"_id":0}))
    return Response("\n".join([filename['filename'] for filename in filenames]), headers={'Content-Type': 'text/plain;charset=UTF-8'})

@app.get("/get_all_pics")
async def get_all_pics():
    fs = GridFS(app.img_db)
    try:
        images = []
        for file in fs.find():
            print(file.filename)
            images.append(file.filename)
        return Response('\n'.join(images), headers={'Content-Type': 'text/plain;charset=UTF-8'})
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    
@app.get("/image/{filename}")
async def image(filename:str):
    fs = GridFS(app.img_db)
    try:
        file = fs.find_one({'filename': filename})
        # print(file)
        return Response(file.read(), media_type='image/png')
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get('/image_desc/{filename}')
async def image_desc(filename:str):
    desc = app.db['pic_info'].find_one({'filename': filename})
    if desc is not None:
        return Response(desc['desc'], headers={'Content-Type': 'text/plain;charset=UTF-8'})
    else:
        return HTTPException(403, f"Filename {filename} is not in database!!")
    
@app.post('/save_memory/{title}')
async def save_memory(title: str):
    stories = list(app.db['chat_history'].find({}, {"_id":0}))
    user_input = "".join([story['story'] for story in stories])
    print(user_input)
    
    cur_img_files = list(app.db['cur_img'].find({},{'_id':0}))
    cur_img_files = [img['filename'] for img in cur_img_files]
    
    app.client.beta.threads.messages.create(
        thread_id=app.thread.id,
        role="user",
        content=json.dumps(user_input),
    )
    run = app.client.beta.threads.runs.create_and_poll(
        thread_id=app.thread.id,
        assistant_id=app.summary_assistant_id,
    )
    response = ''
    if run.status == 'completed':
        messages = app.client.beta.threads.messages.list(
            thread_id=app.thread.id
        )
        response = messages.data[0].content[0].text.value
    else:
        raise Exception(f"{run.status} is not 'completed'")
    
    app.db['memories'].insert_one({
        "title": title,
        "story": response,
        "images": cur_img_files
    })
    
    app.db['chat_history'].drop()
    app.db['cur_img'].drop()
    
    return Response(f"Memories {title} saved successfully", headers={'Content-Type': 'text/plain;charset=UTF-8'})
    
@app.get('/retrieve_memories_title')
async def retrieve_memories():
    memories = list(app.db['memories'].find({}, {'_id':0, 'title':1}))
    return Response("\n".join([memory['title'] for memory in memories]), headers={'Content-Type': 'text/plain;charset=UTF-8'})

@app.get('/retrieve_memory/{title}')
async def retrieve_memory(title: str):
    memory = app.db['memories'].find_one({'title': title}, {'_id':0})
    return Response(json.dumps(memory),  headers={'Content-Type': 'text/json;charset=UTF-8'})

if __name__ == "__main__":
    import uvicorn
    import argparse
    
    parser = argparse.ArgumentParser(description='Server settings')
    parser.add_argument("-H", "--host", help="host", type=str, default="localhost")
    parser.add_argument("-p", "--port", help="port", type=int, default="8000")
    args = parser.parse_args()
    # print(f"🚀🚀 Listening on http://{args.host}:{args.port}!!")
    
    uvicorn.run("server:app", host=args.host, port=args.port, reload=True)
    
