#!/bin/bash
set -e

# Verifica se o IP do container foi fornecido como argumento
if [ $# -eq 0 ]; then
    echo "Erro: Por favor, forneça o IP do container como argumento."
    echo "Uso: $0 <IP_DO_CONTAINER>"
    exit 1
fi

CONTAINER_IP="$1"
WORKSPACE=$(basename "$WORKSPACE")
REMOTE_PATH="/home/$WORKSPACE"
SERVICE_NAME="$WORKSPACE"
SERVICE_PATH="/etc/systemd/system/$SERVICE_NAME.service"

# Função para logging
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Função para executar comandos SSH
run_ssh_command() {
    ssh -o StrictHostKeyChecking=no root@$CONTAINER_IP "$1"
}

# Função para copiar arquivos via SCP
run_scp_command() {
    scp -o StrictHostKeyChecking=no -r "$1" root@$CONTAINER_IP:"$2"
}

# Limpeza e preparação
log "Iniciando processo de deployment"
rm -rf .git

# Enviando arquivos
log "Enviando arquivos para container..."
if ! run_scp_command "$(pwd)" "/home"; then
    log "Erro: Falha ao enviar arquivos para container."
    exit 1
fi
log "Arquivos copiados com sucesso."

# Criando o serviço diretamente no container
log "Criando servico no container"
run_ssh_command "bash -s" <<EOF
#!/bin/bash
# Criação do serviço diretamente no container

# Configuração do servico
cat > "${SERVICE_NAME}.service" <<SERVICE_EOF
[Unit]
Description=$SERVICE_NAME
StartLimitIntervalSec=0

[Service]
Type=simple
Environment="PATH=/root/.local/bin:/root/.pyenv/shims:/root/.pyenv/bin:/root/.pyenv/bin:/root/.pyenv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/root/.local/bin/poetry"
Restart=always
RestartSec=1
User=root
WorkingDirectory=$REMOTE_PATH
ExecStartPre=/root/.local/bin/poetry install
ExecStart=/root/.local/bin/poetry run uvicorn main:app --host 0.0.0.0 --port ${API_PORT}  --workers ${API_WORKERS}
[Install]
WantedBy=multi-user.target
SERVICE_EOF

# Recarregar o daemon do systemd
systemctl daemon-reload

# Verificar se o serviço já existe
if systemctl list-unit-files | grep -Fq "$SERVICE_NAME.service"; then
    echo "Serviço $SERVICE_NAME encontrado."
    if systemctl is-active --quiet "$SERVICE_NAME.service"; then
        echo "Parando o serviço $SERVICE_NAME..."
        systemctl stop "$SERVICE_NAME.service"
    fi
else
    echo "Servico $SERVICE_NAME nao existe. Sera criado."
fi

cp "${SERVICE_NAME}.service" /etc/systemd/system/
# Habilitar e iniciar o serviço
systemctl enable $SERVICE_NAME.service
systemctl restart $SERVICE_NAME.service

echo "[Service] Servico '$SERVICE_NAME' foi ativado e reiniciado com sucesso."
EOF

log "Servico criado e iniciado com sucesso no container."

log "Processo de deployment concluido"
