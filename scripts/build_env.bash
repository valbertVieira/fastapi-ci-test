#!/bin/bash

# Caminho para o arquivo config.ini
CONFIG_FILE="config.ini"

# Verifica se o arquivo config.ini existe
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Erro: Arquivo $CONFIG_FILE não encontrado."
    exit 1
fi

# Lê o arquivo config.ini e atualiza com variáveis de ambiente
while IFS='=' read -r key value || [ -n "$key" ]; do
    # Ignora linhas em branco e comentários
    if [[ -z "$key" || "$key" == \;* || "$key" == \[* ]]; then
        continue
    fi
    
    # Remove espaços em branco do início e fim da chave
    key=$(echo "$key" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    
    # Obtém o valor da variável de ambiente correspondente
    env_value="${!key}"
    
    # Se a variável de ambiente existe, atualiza o valor no config.ini
    if [ -n "$env_value" ]; then
        sed -i "s|^$key=.*|$key=$env_value|" "$CONFIG_FILE"
        echo "Atualizado: $key=$env_value"
    fi
done < "$CONFIG_FILE"

echo "Arquivo $CONFIG_FILE atualizado com sucesso."
