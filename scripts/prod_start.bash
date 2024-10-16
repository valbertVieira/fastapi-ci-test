#!/bin/bash

# Ativa e atualiza o venv
poetry install
source $(poetry env info --path)/bin/activate

gunicorn main:app --host 0.0.0.0 --port 8000
