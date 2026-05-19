pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "poojanerkar/jenkins-trivy-k8s-pipeline"
        DOCKER_TAG = "latest"
        K8S_MASTER = "ubuntu@65.2.183.239"
    }

    stages {

        stage('Clone Repository') {
            steps {
                echo 'Cloning repository...'
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image...'
                sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
            }
        }

        stage('Trivy Security Scan') {
            steps {
                echo 'Scanning image for vulnerabilities...'
                sh """
                    trivy image --exit-code 1 \
                    --severity CRITICAL \
                    --no-progress \
                    ${DOCKER_IMAGE}:${DOCKER_TAG}
                """
            }
        }

        stage('Push to DockerHub') {
            steps {
                echo 'Pushing image to DockerHub...'
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-credentials',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh "echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin"
                    sh "docker push ${DOCKER_IMAGE}:${DOCKER_TAG}"
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                echo 'Deploying to Kubernetes...'
                sh """
                    ssh -o StrictHostKeyChecking=no ${K8S_MASTER} \
                    'kubectl apply -f /home/ubuntu/k8s/'
                """
            }
        }

    }

    post {
        success {
            echo 'Pipeline completed! App deployed to Kubernetes.'
        }
        failure {
            echo 'Pipeline failed! Check Trivy scan results.'
        }
    }
}