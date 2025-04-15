# Base CUDA image
FROM registry.cn-shanghai.aliyuncs.com/wanxp-mirror/pytorch:2.0.1-py3.9.17-cuda11.8.0-ubuntu20.04

LABEL maintainer="breakstring@hotmail.com"
LABEL version="dev-20240209"
LABEL description="Docker image for GPT-SoVITS"


# Install 3rd party apps
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
RUN sed -i "s@http://.*archive.ubuntu.com@https://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list
RUN sed -i "s@http://.*security.ubuntu.com@https://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list
RUN apt-get update && \
    apt-get install -y --no-install-recommends tzdata ffmpeg libsox-dev parallel aria2 git git-lfs && \
    git lfs install && \
    rm -rf /var/lib/apt/lists/*

# Copy only requirements.txt initially to leverage Docker cache
WORKDIR /workspace
COPY requirements.txt /workspace/
RUN pip config set global.index-url https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple
RUN pip install --no-cache-dir -r requirements.txt

# Define a build-time argument for image type
ARG IMAGE_TYPE=full

# Conditional logic based on the IMAGE_TYPE argument
# Always copy the Docker directory, but only use it if IMAGE_TYPE is not "elite"
COPY ./Docker /workspace/Docker
#COPY ./download/workspace/GPT_SoVITS  /workspace/
#COPY ./download/workspace/tools  /workspace/
# elite 类型的镜像里面不包含额外的模型
RUN python /workspace/Docker/download.py

#RUN     python -m nltk.downloader averaged_perceptron_tagger cmudict;


# Copy the rest of the application
COPY . /workspace

EXPOSE 9871 9872 9873 9874 9880

CMD ["python", "webui.py"]
