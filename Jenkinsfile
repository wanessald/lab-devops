pipeline {
    agent any

    environment {
        REGISTRY  = "192.168.56.10:5000"
        IMAGE     = "lab-devops-api"
        TAG       = "${env.GIT_COMMIT?.take(7) ?: 'latest'}"
        STACK_YML = "infrastructure-lab/swarm/stack.yml"
    }

    stages {
        stage('Test') {
            steps {
                dir('app') {
                    sh 'pip3 install -r requirements.txt --break-system-packages'
                    sh 'python3 -m pytest test_main.py -v'
                }
            }
        }

        stage('Build') {
            steps {
                dir('app') {
                    sh "docker build -t ${REGISTRY}/${IMAGE}:${TAG} ."
                    sh "docker tag ${REGISTRY}/${IMAGE}:${TAG} ${REGISTRY}/${IMAGE}:latest"
                }
            }
        }

        stage('Push') {
            steps {
                sh "docker push ${REGISTRY}/${IMAGE}:${TAG}"
                sh "docker push ${REGISTRY}/${IMAGE}:latest"
            }
        }

        stage('Deploy') {
            steps {
                sh """
                    docker stack deploy \
                      --compose-file ${STACK_YML} \
                      --with-registry-auth \
                      lab
                """
            }
        }
    }

    post {
        success {
            echo "Deploy concluído: ${REGISTRY}/${IMAGE}:${TAG}"
        }
        failure {
            echo "Pipeline falhou. Verifique os logs acima."
        }
    }
}
