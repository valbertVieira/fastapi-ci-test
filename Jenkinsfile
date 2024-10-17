pipeline {
    agent any
    parameters {
        string(name: 'COMMIT', defaultValue: '', description: 'Construir a partir de um commit especifico')
    }

    stages {
        stage('Checkout') {
            steps {
                script {
                    sh 'printenv'
                    
                    if (params.COMMIT) {
                        checkout([$class: 'GitSCM', 
                                  branches: [[name: "${params.COMMIT}"]],
                                  userRemoteConfigs: [[url: "${GIT_URL}"]]])
                    } else {
                        // Checkout padrão da branch principal se nenhuma tag for especificada
                        checkout scm
                    }
                }
            }
        }

        
        stage('Generate env file') {
            steps {
                // Adicione permissões ao script se necessário
                sh 'chmod +x ./scripts/build_env.bash'
                // Executa o script que gera o .env com as variáveis de ambiente
                sh 'bash ./scripts/build_env.bash'
                // Opcional: Verifica o conteúdo do .env para garantir que foi gerado corretamente
                sh 'printenv'
            }
        }
        
        stage('Deploy') {
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
                        echo "AVISO: API sem resposta. STATUS: ${apiStatus}"

                        def lastSuccessfulCommit = env.GIT_PREVIOUS_SUCCESSFUL_COMMIT
                        if (lastSuccessfulCommit) {
                            echo "Check Health falhou. Iniciando rollback para commit: ${lastSuccessfulCommit}"
                            build job: env.JOB_NAME, parameters: [
                                string(name: 'COMMIT_HASH', value: lastSuccessfulCommit)
                            ], wait: false
                        } else {
                            echo "Commit bem sucedido nao encontrado, faca rollback manualmente passando o commit estavel na proxima build"
                        }
                        
                        error "Falha no Check Health. Pipeline interrompido."


                        
                    }
                }
        }
}


        
    }
    
    post {
        success {
            echo "Pipeline executado com sucesso!"
        }
       
        always {
            // Limpeza ou ações pós-build, se necessário
            echo "Pipeline concluido, executando acoes pos-build."
            cleanWs()
        }
    }
}
