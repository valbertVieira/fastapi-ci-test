pipeline {
    agent any
    
    stages {        
        stage('Deploy to Server') {
            steps {
                sh '''
                    ssh root@${REMOTE_CONTAINER_IP} '
                    # Cria diretório da aplicação se não existir
                    mkdir -p ${JOB_BASE_NAME}
                    '
                    
                    # Copia os arquivos da aplicação
                    scp -r ./* root@${REMOTE_CONTAINER_IP}:${JOB_BASE_NAME}/
                    
                    ssh root@${REMOTE_CONTAINER_IP} '
                    # Cria e ativa o ambiente virtual
                    cd ${JOB_BASE_NAME}
                    #install deps
                    poetry install        
                    # Instala as dependências
                    source $(poetry env info --path)/bin/activate
                    
                    # Desativa o ambiente virtual
                    deactivate
                    '
                '''
            }
        }
        
        stage('Create Service') {
            steps {
                 sh """
                    ssh root@${REMOTE_CONTAINER_IP} '
                    echo "Criando serviço no container"
                    cat > /etc/systemd/system/${JOB_BASE_NAME}.service <<EOF
[Unit]
Description=${JOB_BASE_NAME}
StartLimitIntervalSec=0

[Service]
Type=simple
Environment="PATH=/root/.local/bin:/root/.pyenv/shims:/root/.pyenv/bin:/root/.pyenv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
Restart=always
RestartSec=1
User=root
WorkingDirectory=/root/${JOB_BASE_NAME}
ExecStart=gunicorn main:app --host 0.0.0.0 --port 8000

[Install]
WantedBy=multi-user.target
EOF

                    systemctl daemon-reload
                    systemctl enable ${JOB_BASE_NAME}.service
                    systemctl restart ${JOB_BASE_NAME}.service
                    '
                """
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
    }
}
