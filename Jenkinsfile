pipeline {
    agent any

        
    
    stages {
        stage('Preparing environment') {
            steps {
                script {
                    // Limpa o workspace antes de começar
                    // cleanWs()
                    sh 'ls'
                }
            } 
        }

        stage('Generate Environment File') {
            steps {
                // Adicione permissões ao script se necessário
                sh 'chmod +x ./scripts/build_env.bash'
                // Executa o script que gera o .env com as variáveis de ambiente
                sh 'bash ./scripts/build_env.bash'
                // Opcional: Verifica o conteúdo do .env para garantir que foi gerado corretamente
                sh 'printenv'
            }
        }
        
        stage('Deploy to Remote Container') {
            steps {
                // Adicione permissões ao script de deploy se necessário
                sh 'chmod +x ./scripts/deploy.bash'
                // Executa o script de deploy que copia os arquivos para o container remoto e inicia o serviço
                sh 'bash ./scripts/deploy.bash ${REMOTE_CONTAINER_IP}'
            }
        }
        stage('Check Health') {
            steps {
                // Aguarda alguns segundos para o serviço iniciar
                // sh 'sleep 10'
        
                // Adicione uma checagem na URL da API para garantir que está online
                script {
                    echo "Verificando a disponibilidade da API..."
                    def apiStatus = sh(script: "curl -s -o /dev/null -w '%{http_code}' http://${REMOTE_CONTAINER_IP}:5050", returnStdout: true).trim()
                    if (apiStatus >= '200' && apiStatus <= '204') {
                        echo "Servico atualizado e funcionando. STATUS: ${apiStatus}"
                    } else {
                        error "Api sem resposta. STATUS: ${apiStatus}"
                    }
                }
        }
}


        
    }
    
    post {

        success {
            echo "Pipeline executado com sucesso!"
        }
        failure {
            script {
                echo "Pipeline falhou. Iniciando rollback..."
                def previousSuccessfulBuild = currentBuild.previousSuccessfulBuild
                if (previousSuccessfulBuild) {
                    echo "Revertendo para a build ${previousSuccessfulBuild.number}"
                    build job: currentBuild.projectName, parameters: [
                        string(name: 'REMOTE_CONTAINER_IP', value: REMOTE_CONTAINER_IP),
                        string(name: 'ROLLBACK_TO', value: previousSuccessfulBuild.number.toString())
                    ]
                } else {
                    echo "Não foi possível encontrar uma build anterior bem-sucedida para rollback."
                }
            }
        }
        
        always {
            // Limpeza ou ações pós-build, se necessário
            echo "Pipeline concluido, executando acoes pos-build."
            cleanWs()
        }
    }
}
