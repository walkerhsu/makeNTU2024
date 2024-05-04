FROM python:3.9

WORKDIR /app
COPY . /app/

RUN pip install -r requirements.txt
ENV OPENAI_API_KEY=sk-proj-Od5ATYnuHVQwc9rOYr1sT3BlbkFJbgocHeoWtMLTX4YF29NC

CMD [ "python", "server.py", "--host", "0.0.0.0" ]