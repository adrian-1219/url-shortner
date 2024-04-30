# https://docs.docker.com/engine/reference/builder/

# Use an official Python runtime as a parent image
# See https://hub.docker.com/ and search for python:2.7-slim
FROM python:3.7

# Set the working directory to /app
# The WORKDIR instruction sets the working directory (inside the container) 
# for any RUN, CMD, ENTRYPOINT, COPY and ADD instructions that 
# follow it in the Dockerfile. 
WORKDIR /app

# Copy the application directory (app) contents into the container at /app
ADD app /app

RUN pip install --trusted-host pypi.python.org -r requirements.txt
RUN apt-get update
RUN apt-get -y install vim

EXPOSE 5000
HEALTHCHECK CMD curl --fail http://localhost:5000 || exit 1

CMD ["python", "app.py"]
