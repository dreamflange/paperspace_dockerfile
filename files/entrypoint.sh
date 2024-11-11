#!/bin/bash

export CUDA_VISIBLE_DEVICES=0

#hf token
export $(cat /notebooks/share/.env | grep -v '^#' | xargs)
huggingface-cli login --token $HF_TOKEN

jupyter lab --allow-root --ip=0.0.0.0 --no-browser --ServerApp.trust_xheaders=True --ServerApp.disable_check_xsrf=False --ServerApp.allow_remote_access=True --ServerApp.allow_origin='*' --ServerApp.allow_credentials=True
