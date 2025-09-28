pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = 'ashishnegi77' // The ID you will create in Jenkins
        DOCKER_IMAGE_NAME   = "your-dockerhub-username/my-python-app"
        EC2_SSH_KEY         = 'staging-server-ssh-key' // The ID you will create in Jenkins
        // ** Use the PRIVATE IP of your staging server for better security and reliability **
        STAGING_SERVER_IP   = '172.31.3.137'
        STAGING_SERVER_USER = 'ec2-user'
    }

    stages {
        stage('1. Checkout Code') {
            steps {
                checkout scm
            }
        }
        stage('2. Build Docker Image') {
            steps {
                script {
                    // The '.' means build from the current directory
                    docker.build(DOCKER_IMAGE_NAME, '.')
                }
            }
        }
        stage('3. Push to Docker Hub') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', DOCKERHUB_CREDENTIALS) {
                        // Tag the image with the build number and 'latest'
                        sh "docker tag ${DOCKER_IMAGE_NAME} ${DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER}"
                        sh "docker push ${DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER}"
                        sh "docker tag ${DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER} ${DOCKER_IMAGE_NAME}:latest"
                        sh "docker push ${DOCKER_IMAGE_NAME}:latest"
                    }
                }
            }
        }
        stage('4. Deploy to Staging') {
            steps {
                script {
                    // Use the SSH Agent plugin to securely connect to the staging server
                    sshagent(credentials: [EC2_SSH_KEY]) {
                        sh """
                            ssh -o StrictHostKeyChecking=no ${STAGING_SERVER_USER}@${STAGING_SERVER_IP} '
                                docker pull ${DOCKER_IMAGE_NAME}:latest
                                docker stop my-python-app || true
                                docker rm my-python-app || true
                                docker run -d -p 5000:5000 --name my-python-app ${DOCKER_IMAGE_NAME}:latest
                            '
                        """
                    }
                }
            }
        }
    }
}