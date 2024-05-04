from openai import OpenAI

api_key = "sk-proj-Wu6mv1CN39drNi7oYda0T3BlbkFJVFjXe0IwdPmSAVl7USCt"
assistant_id = "asst_J7Fonqn39ucfZ3iDBPMBkgCb"
client = OpenAI(api_key=api_key)

thread = client.beta.threads.create()

message = client.beta.threads.messages.create(
  thread_id=thread.id,
  role="user",
  content='{"type":"勇者救公主", "starting point":"松山文創園區", "ending point":"國立台灣大學"}',
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
else:
  print(run.status)