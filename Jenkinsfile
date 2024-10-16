pipeline {
    agent any
    
    stages {        
        stage('Deploy to Server') {
            steps {
               script {
                    // Função para executar comandos SSH
                    def sshCommand = { cmd ->
                        sh "ssh ${REMOTE_USER}@${REMOTE_HOST} '${cmd}'"
                    }
                    
                    // Função para copiar arquivos via SCP
                    def scpFiles = { from, to ->
                        sh "scp -r ${from} ${REMOTE_USER}@${REMOTE_HOST}:${to}"
                    }
                    
                    // Cria diretório da aplicação
                    sshCommand "mkdir -p ${JOB_BASE_NAME}"
                    
                    // Copia os arquivos da aplicação
                    scpFiles "./*", "${JOB_BASE_NAME}/"
                    
                    // Instala e configura a aplicação
                    sshCommand """
                        cd ${JOB_BASE_NAME}
                        poetry install
                        source \$(poetry env info --path)/bin/activate
                    """
                }
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
