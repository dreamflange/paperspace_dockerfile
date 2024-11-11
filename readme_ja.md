# paperspace用Dockerfile

 [日本語](README_ja.md)

## 何これ？
cuda:12.4.1-cudnn-devel-ubuntu22.04をベースにしたpaperspace用のDockerfile  
paperspaceの公式はイメージの更新が遅いので作ってみた  
WSLでビルドに使ってるdocker-compose.yamlが付いてるので各自カスタマイズしてね  

### gitpull & build
```bash
git clone https://github.com/dreamflange/paperspace_dockerfile  
cd paperspace_dockerfile  
docker compose build  
```

### コンテナを起動して中に入ってみる
```bash
docker compose up -d
docker compose exec paperspace bash  
```

### dockerHubにアップする
```bash
docker login -u myDockerHubAccount  
docker tag paperspace_dockerfile-paperspace myDockerHubAccount/repositoryName:latest  
docker push myDockerHubAccount/repositoryName:latest  
```

### paperspaceでprojectを作る
Notebooks → Start from Scratch → View advanced options → Advanced options → ContainerにDocherHubにupったリポジトリとイメージを入れて起動（雑）  

## 色々
全てのアプリを入れた大型イメージはVM起動時にdockerHubからのダウンロードが終わる前にタイムアウトに 
なる場合があるので小型のイメージ
毎回アプリとpytorchをダウンロード&インストールする事になるが、キャッシュが効くのでpytorchのバージョンをsd-scriptやcomfyuiなどで共通化させた方がいい  
```bash
./venv/bin/pip install torch==2.4.1 torchvision==0.19.1 torchaudio==2.4.1 --index-url https://download.pytorch.org/whl/cu124  
./venv/bin/pip install xformers==0.0.28  
```
  
/notebooks/shareにパスを通してあるので自分用のシェルスクリプトを置くといいよ  

/notebooks/share/.envに以下の形式で自分のhuggingfaceTokenを入れたファイルを置くと起動時に自動でログインするよ  
```
HF_TOKEN=hf_MyHuggingFaceTokenEbiDance
```

マルチステージビルドはちょっと試したけどイメージ9Gのうち300Mぐらいしか減らなかったのでいいかな  

### huggingfaceからモデルをダウンロードしたいんですけど！？  
```python
from huggingface_hub import hf_hub_download
from dotenv import load_dotenv
import os

def download(repo, filename):
    load_dotenv( dotenv_path="/notebooks/share/.env")
    hf_token = os.getenv("HF_TOKEN")
    hf_hub_download(
        filename=filename,
        local_dir="/notebooks/models/checkpoints",
        local_dir_use_symlinks=False,
        repo_id=repo,
        token=hf_token,
    )

repo="cagliostrolab/animagine-xl-3.1"
filename = "animagine-xl-3.1.safetensors"
download(repo, filename)
```

### huggingfaceにモデルをアップロードしたいんですけど！？  
```
from huggingface_hub import HfApi
from dotenv import load_dotenv
import os

def upload(localpath, repo):
    load_dotenv( dotenv_path="/notebooks/share/.env")
    hf_token = os.getenv("HF_TOKEN")
    path_in_repo = "/" + os.path.basename(localpath)

    api = HfApi()
    api.upload_file(
        path_or_fileobj = localpath,
        path_in_repo = path_in_repo,
        repo_id=repo,
        token=hf_token,    
    )
    
localpath = "/notebooks/_models/animagine-xl-3.1.safetensors"
repo = "my_account/my_repo"
upload(localpath, repo)
```