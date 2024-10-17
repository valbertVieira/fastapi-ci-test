pipeline {
    agent any
    parameters {
        string(name: 'COMMIT_HASH', defaultValue: '', description: 'Tag da build para reconstruir (ex: jenkins-ci-tesste-11)')
    }

    stages {
        stage('Checkout') {
            steps {
                script {
                    sh 'printenv'
                    
                    if (params.COMMIT_HASH) {
                        checkout([$class: 'GitSCM', 
                                  branches: [[name: "${params.COMMIT_HASH}"]],
                                  userRemoteConfigs: [[url: '${GIT_URL}']]])
                    } else {
                        // Checkout padrão da branch principal se nenhuma tag for especificada
                        checkout scm
                    }
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
                sh 'sleep 10'
        
                // Adicione uma checagem na URL da API para garantir que está online
                script {
                    echo "Verificando a disponibilidade da API..."
                    def apiStatus = sh(script: "curl -s -o /dev/null -w '%{http_code}' http://${REMOTE_CONTAINER_IP}:${API_PORT}", returnStdout: true).trim()
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
                def lastSuccessfulCommit = env.GIT_PREVIOUS_SUCCESSFUL_COMMIT
                echo "${lastSuccessfulCommit}"
                if (lastSuccessfulCommit) {
                    echo "Fazendo rollback para o commit da última build bem-sucedida: ${lastSuccessfulCommit}"
                    
                   build job: env.JOB_NAME, parameters: [
                        string(name: 'COMMIT_HASH', value: lastSuccessfulCommit)
                    ], wait: false
                    
                    echo "Rollback concluído. O código agora está no estado da última build bem-sucedida."
                    
                } else {
                    echo "Não foi encontrada nenhuma build bem-sucedida anterior. Não é possível realizar o rollback."
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
