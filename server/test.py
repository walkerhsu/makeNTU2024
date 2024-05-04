from openai import OpenAI
from dotenv import load_dotenv

# load_dotenv()
# client = OpenAI()
# response = client.chat.completions.create(
#     model="gpt-3.5-turbo-0125",
#     response_format={ "type": "json_object" },
#     messages=[
#         {"role": "system", "content": "You are a helpful assistant designed to output JSON."},
#         {"role": "user", "content": "Who won the world series in 2020?"}
#     ]
# )
# print(response.choices[0].message.content)

dictionary = {
    "小怪1": {
        "name": "暗影魃妖",
        "HP": 50,
        "ATK": 10,
        "MVSPD": 2,
        "ATKSPD": 1,
        "TYPE": 0
    },
    "小怪2": {
        "name": "炎焰獸",
        "HP": 40,
        "ATK": 8,
        "MVSPD": 3,
        "ATKSPD": 2,
        "TYPE": 0
    },
    "BOSS": {
        "name": "邪惡亡靈王",
        "HP": 200,
        "ATK": 20,
        "MVSPD": 0,
        "ATKSPD": 2,
        "TYPE": 1
    }
}
print([*dictionary.values()])
