pipeline {
    agent any

    environment {
        REGISTRY = "192.168.56.10:5000"
        IMAGE    = "lab-devops-api"
        TAG      = "${env.GIT_COMMIT?.take(7) ?: 'latest'}"
    }

    stages {
        stage('Test') {
            steps {
                dir('app') {
                    sh 'pip install -r requirements.txt --break-system-packages'
                    sh 'pytest test_main.py -v'
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
                    docker service update \
                      --image ${REGISTRY}/${IMAGE}:${TAG} \
                      --update-parallelism 1 \
                      --update-delay 5s \
                      lab-api || \
                    docker service create \
                      --name lab-api \
                      --replicas 3 \
                      --publish published=80,target=8000 \
                      ${REGISTRY}/${IMAGE}:${TAG}
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
