#!/bin/bash

# Ativa e atualiza o venv
poetry install
source $(poetry env info --path)/bin/activate

# Executa o script principal
python ./app/main.py
