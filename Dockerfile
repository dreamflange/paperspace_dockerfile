FROM nvidia/cuda:12.4.1-cudnn-devel-ubuntu22.04 as builder

ENV TZ=Asia/Tokyo
ENV LANG C.UTF-8
ENV SHELL=/bin/bash
ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /tmp

# 必要なパッケージのみをインストール
WORKDIR /tmp
RUN apt update && \
    apt install -y --no-install-recommends git git-lfs zip unzip libgl1-mesa-dev libglib2.0-0 google-perftools

# Python 3.10.15 のソースをダウンロードしてビルド＆インストール
RUN apt install -y --no-install-recommends \
    wget \
    build-essential \
    zlib1g-dev \
    libssl-dev \
    libffi-dev \
    libbz2-dev \
    liblzma-dev \
    libreadline-dev \
    libsqlite3-dev && \
    wget https://www.python.org/ftp/python/3.10.15/Python-3.10.15.tgz && \
    tar -xzf Python-3.10.15.tgz && \
    cd Python-3.10.15 && \
    ./configure --enable-optimizations --with-ensurepip=install && \
    make -j$(nproc) && \
    make altinstall && \
    cd .. && \
    rm -rf Python-3.10.15 Python-3.10.15.tgz && \
    apt-get remove -y build-essential && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# python3.10をpythonで使えるようにシンボリックリンクを作成
RUN ln -s /usr/local/bin/python3.10 /usr/local/bin/python

# 必要なpipパッケージのインストール
RUN python -m pip install --upgrade pip && \
        python -m pip install jupyterlab huggingface_hub pillow opencv-python python-dotenv --no-cache-dir && \
        rm -rf ~/.cache/pip

# accelerate configの内容はコピーで済ます
COPY files/default_config.yaml  /root/.cache/huggingface/accelerate/default_config.yaml 

# 起動時に読み込むentrypoint.shと実行権限の付与
COPY files/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# /notebooks/shareにパスを通すのでシェルスプリスクリプトとかはそこに入れるといいよ
WORKDIR /notebooks
ENV PATH="/notebooks/share:${PATH}"

EXPOSE 8888 6006
ENTRYPOINT ["/entrypoint.sh"]
