# Dockerfile for Paperspace

[Japanese](readme_ja.md)

## What is this?
This is a Dockerfile for Paperspace, based on `cuda:12.4.1-cudnn-devel-ubuntu22.04`.  
Since the official Paperspace image updates are slow, I decided to create this one.  
It includes a `docker-compose.yaml` file used for building in WSL, so feel free to customize it to fit your needs.

### Git Pull & Build
```bash
git clone https://github.com/dreamflange/paperspace_dockerfile  
cd paperspace_dockerfile  
docker compose build  


### Start the Container and Access the Shell
```bash
docker compose up -d
docker compose exec paperspace bash  
```

### Upload to DockerHub
```bash
docker login -u myDockerHubAccount  
docker tag paperspace_dockerfile-paperspace myDockerHubAccount/repositoryName:latest  
docker push myDockerHubAccount/repositoryName:latest  
```

### Create a Project on Paperspace
Go to Notebooks → Start from Scratch → View advanced options → Advanced options and specify the DockerHub repository and image you uploaded under Container to launch it.


## Additional Info
Large images containing all applications might time out before the download from DockerHub completes when starting a VM. Therefore, a smaller image is used here.
Although applications and PyTorch need to be downloaded and installed each time, using a cache can make it easier to standardize the PyTorch version across sd-scripts and ComfyUI.

```bash
./venv/bin/pip install torch==2.4.1 torchvision==0.19.1 torchaudio==2.4.1 --index-url https://download.pytorch.org/whl/cu124  
./venv/bin/pip install xformers==0.0.28  
```
  
You can place custom shell scripts in /notebooks/share as it has a path set up.

To automatically log in with your Hugging Face token on startup, place a file in /notebooks/share/.env with your Hugging Face token in the following format:


```
HF_TOKEN=hf_MyHuggingFaceTokenEbiDance
```
I tried using multi-stage builds in the build section, but it only reduced the image size by about 300 MB from a total of 9 GB, so I didn’t keep it.

### Want to Download a Model from Hugging Face?
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

### Want to Upload a Model to Hugging Face?
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