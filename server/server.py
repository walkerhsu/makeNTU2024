#!/usr/bin/env python
from fastapi import FastAPI, Response, HTTPException
import os
from openai import OpenAI
from dotenv import load_dotenv
from contextlib import asynccontextmanager
import pymongo
import numpy as np
import json
from pydantic import BaseModel

class Status(BaseModel):
    status: str

@asynccontextmanager
async def lifespan(app: FastAPI):
    MONGO_URL = os.environ.get('MONGO_URL')
    try:
        app.client = OpenAI()
        app.model = "gpt-3.5-turbo-0125"
        app.mongodb_client = pymongo.MongoClient(MONGO_URL, serverSelectionTimeoutMS = 1000)
        app.mongodb_client.server_info()
        print(f"MongoDB connected at {MONGO_URL}")
    except:
        raise Exception(f'Cannot connect to {MONGO_URL}')
    
    app.db = app.mongodb_client['db']
    app.db['user'].drop()
    app.db['user'].insert_one({
        "HP": 0,
        "ATK": 0,
        "MAXAMMO": 0,
        "RELTIME": 0
    })
    yield
    
    app.mongodb_client.close()
    
load_dotenv()
client = OpenAI()
app = FastAPI(lifespan=lifespan)


"""db types
    user: HP, previous stories, pictures, 
    monster: HP, ATK, MOVEMENT SPEED, ATK SPEED, NAME (generated by ChatGPT)
    """

@app.get('/')
async def main():
    return Response(content='<h1>This is a makentu server.</h1>', media_type='text/html')

@app.get('/create_story')
async def create_story(category: str = "冒險", dest: str = "台北"):
    # style, destination
    response = app.client.chat.completions.create(
        model=app.model,
        response_format={ "type": "json_object" },
        messages=[
            # {"role": "system", "content": "You are a helpful assistant."},
            {"role": "system", "content": "你是一位生成故事的得力的助手。請用繁體中文並且如果有JSON回覆的提示，請以JSON回覆。"},
            # {"role": "user", "content": "Please create an RPG story and give four short choices of future outcomes."}
            {"role": "user", "content": f"請創造一個主題為「{category}」並且根據目的地「{dest}」的長情節RPG故事(200字)，\
並且生成4種可能的未來發展的選項。選項字數請少於10個字。請用「story」和「options」當作JSON的鍵值。"}
        ]
    )
    
    app.db.chat_history.drop()
    app.db.chat_history.insert_many([
        {"role": "system", "content": "你是一位生成故事的得力的助手。請用繁體中文並且如果有JSON回覆的提示，請以JSON回覆。"},
        {"role": "user", "content": f"請創造一個主題為「{category}」並且根據目的地「{dest}」的長情節RPG故事(200字)，\
並且生成4種可能的未來發展的選項。選項字數請少於10個字。請根據目的地請用「story」和「options」當作JSON的鍵值。"},
        {"role": "assistant", "content": response.choices[0].message.content}
    ])
    
    return Response(response.choices[0].message.content, headers={"Content-Type": "text/json;charset=UTF-8"})

@app.get('/story_response')
async def story_response(choice: str = '0'):
    chat_history = app.db.chat_history.find({}, {"_id": 0})
    # for chat in chat_history:
    #     print(chat)
    # print([*chat_history])
    # print(choice)
        
    # check whether game should be triggered
    if choice != '0':
        is_battle = ""
        i = 0
        response = None
        while '是' not in is_battle and '否' not in is_battle and i < 5:
            response = app.client.chat.completions.create(
                model=app.model,
                messages=[
                    *chat_history,
                    {"role": "user", "content": f"我選擇「{choice}」。請問這個選項是否要觸發戰鬥？請回覆「是」或「否」。"},
                ]
            )
            is_battle = response.choices[0].message.content
            i += 1
            
        app.db.chat_history.insert_many([
            {"role": "user", "content": f"我選擇「{choice}」。根據語意，請問這個選項是否要觸發戰鬥？請回覆「是」或「否」。"},
            {"role": "assistant", "content": is_battle},
        ])
        
        if '是' in is_battle:
            response = app.client.chat.completions.create(
                model=app.model,
                response_format={ "type": "json_object" },
                messages=[
                    *chat_history,
                    {"role": "user", "content": "請根據以上故事發展及所選的選項，生成關於戰鬥的故事。請用繁體中文，並用「story」和「options」當作JSON的鍵值，並且將options設成空的陣列。"},
                ]
            )
            app.db.chat_history.insert_many([
                {"role": "user", "content": "請根據以上故事發展及所選的選項，生成關於戰鬥的故事。請用繁體中文，並用「story」和「options」當作JSON的鍵值，並且將options設成空的陣列。"},
                {"role": "assistant", "content": response.choices[0].message.content},
            ])
            
            # generate monsters
            app.db.monsters.drop()
            app.db.status.drop()
            chat_history = app.db.chat_history.find({}, {"_id": 0})
            monster_response = app.client.chat.completions.create(
                model=app.model,
                response_format={ "type": "json_object" },
                messages=[
                    *chat_history,
                    {"role": "user", "content": "請根據以上故事發展及所選的選項，生成適當數量的小怪以及零或一隻BOSS。請生成各個小怪以及BOSS的名字(name)、\
血量(HP)、攻擊力(ATK)、移動速度(MVSPD)、攻擊速度(ATKSPD)、以及型態(TYPE；0代表小怪，1代表BOSS)。請用繁體中文，並且每隻怪物用以上英文當作JSON的鍵值，\
回傳一個list。如果有請把BOSS的MVSPD設定成0"},
                ]
            )
            print(monster_response.choices[0].message.content)
            app.db.monsters.insert_many([*json.loads(monster_response.choices[0].message.content).values()])
            
        else:
            response = app.client.chat.completions.create(
                model=app.model,
                response_format={ "type": "json_object" },
                messages=[
                    *chat_history,
                    {"role": "user", "content": "請根據以上故事發展及所選的選項，生成後續的故事(200字內)以及4種可能的未來發展的選項。選項字數請少於10個字。\
請用繁體中文，並用「story」和「options」當作JSON的鍵值"},
                ]
            )
            app.db.chat_history.insert_many([
                {"role": "user", "content": "請根據以上故事發展及所選的選項，生成後續的故事(200字內)以及4種可能的未來發展的選項。選項字數請少於10個字。\
請用繁體中文，並用「story」和「options」當作JSON的鍵值"},
                {"role": "assistant", "content": response.choices[0].message.content},
            ])
        
        for x in app.db.chat_history.find({}, {"_id": 0}):
            print(x)
        return Response(response.choices[0].message.content, headers={"Content-Type": "text/json;charset=UTF-8"})

@app.get('/get_db')
async def get_db_data(db_name: str = 'chat_history'):
    data = app.db[db_name].find({}, {'_id': 0})
    return Response(json.dumps([*data], ensure_ascii=False), headers={"Content-Type": "text/json;charset=UTF-8"})

# @app.get('/get_db_one')
# async def get_db_data(db_name: str = 'chat_history'):
#     app.db[db_name].insert_one({
#         'status': 'win'
#     })
#     data = app.db[db_name].find_one({}, {'_id': 0})
    
#     print(data is not None)
#     return Response(json.dumps(data, ensure_ascii=False), headers={"Content-Type": "text/json;charset=UTF-8"})

@app.get('/clear_db')
async def clear_db_data(db_name: str = 'chat_history'):
    app.db[db_name].drop()
    return Response(f"Deleted {db_name} successfully")

@app.get('/get_user_info')
async def get_user_info():
    user = app.db.user.find({}, {"_id": 0})
    return Response(json.dumps([*user]), headers={"Content-Type": "text/json;charset=UTF-8"})

@app.get('/get_monsters_info')
async def insert_monster():
    monsters = app.db.monsters.find({}, {"_id": 0})
    return Response(json.dumps([*monsters]), headers={"Content-Type": "text/json;charset=UTF-8"})
    
# implement functions for user props update according to the choice of the user

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
        return Response("Status updated successfully", 200)
    else:
        return HTTPException(403, "Status is invalid")

# return a prompt for generating a picture based on the stories

if __name__ == "__main__":
    import uvicorn
    import argparse
    
    parser = argparse.ArgumentParser(description='Server settings')
    parser.add_argument("-H", "--host", help="host", type=str, default="localhost")
    parser.add_argument("-p", "--port", help="port", type=int, default="8000")
    args = parser.parse_args()
    # print(f"🚀🚀 Listening on http://{args.host}:{args.port}!!")
    
    uvicorn.run("server:app", host=args.host, port=args.port, reload=True)
    
