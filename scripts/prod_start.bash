#!/bin/bash

# Ativa e atualiza o venv
poetry install
source $(poetry env info --path)/bin/activate

gunicorn main:app  --bind 0.0.0.0:8000
