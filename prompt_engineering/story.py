from openai import OpenAI
import json

api_key = "sk-proj-Wu6mv1CN39drNi7oYda0T3BlbkFJVFjXe0IwdPmSAVl7USCt"
assistant_id = "asst_Vt6SNqYzUPfIm9SDHnr4EfgZ"
client = OpenAI(api_key=api_key)

thread = client.beta.threads.create()

finish = False

while not finish:
    user_input = input("user > ")
    message = client.beta.threads.messages.create(
        thread_id=thread.id,
        role="user",
        content=user_input,
    )
    run = client.beta.threads.runs.create_and_poll(
        thread_id=thread.id,
        assistant_id=assistant_id,
    )
    if run.status == 'completed': 
        messages = client.beta.threads.messages.list(
            thread_id=thread.id
        )
        response = messages.data[0].content[0].text.value
        print(response)
        response = json.loads(response)
        if response['Status'] == 'End':
            finish = True
    else:
        print(run.status)
