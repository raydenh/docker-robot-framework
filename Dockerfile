FROM python:3.11

# Install system dependencies
RUN apt-get update && apt-get install -y \
    unzip \
    wget \
    chromium \
    xvfb \
    bash

# Install ChromeDriver
RUN wget -O /tmp/chromedriver.zip https://chromedriver.storage.googleapis.com/108.0.5359.71/chromedriver_linux64.zip \
    && unzip /tmp/chromedriver.zip -d /usr/local/bin \
    && rm /tmp/chromedriver.zip
# Copy the test files and resources to the working directory
COPY . .
#Workaround to chrome work
RUN mv /usr/lib/chromium/chromium /usr/lib/chromium/chromium-original \
  && ln -sfv /bin/chromium /usr/lib/chromium/chromium
# Install Robot Framework and additional libraries
RUN pip install -r requirements.txt
# Set the working directory
WORKDIR /app