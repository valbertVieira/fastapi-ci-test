pipeline {
    agent any
    
    stages {        
        stage('Deploy to Server') {
            steps {
                sh """
                    ssh root@${REMOTE_CONTAINER_IP} '
                    # Cria diretório da aplicação se não existir
                    mkdir -p ${JOB_BASE_NAME}
                    '
                    
                    # Copia os arquivos da aplicação
                    scp -r ./* root@${REMOTE_CONTAINER_IP}:${JOB_BASE_NAME}/
                    
                    ssh root@${REMOTE_CONTAINER_IP} '
                    # Cria e ativa o ambiente virtual
                    python3 -m venv venv
                    source venv/bin/activate
                    
                    # Instala as dependências
                    pip install -r ${JOB_BASE_NAME}/requirements.txt
                    
                    # Desativa o ambiente virtual
                    deactivate
                    '
                """
            }
        }
        
        stage('Create Service') {
            steps {
                sh """
                    ssh root@${REMOTE_CONTAINER_IP}'
                    tee /etc/systemd/system/${JOB_BASE_NAME}.service << EOF
[Unit]
Description=FastAPI application
After=network.target

[Service]
User=ubuntu
Group=ubuntu
WorkingDirectory="/${JOB_BASE_NAME}"
Environment="PATH=/venv/bin"
ExecStart=/venv/bin/uvicorn main:app --host 0.0.0.0 --port 8000
Restart=always

[Install]
WantedBy=multi-user.target
EOF

                    sudo systemctl daemon-reload
                    sudo systemctl enable ${JOB_BASE_NAME}.service
                    sudo systemctl restart ${JOB_BASE_NAME}.service
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
