pipeline {
    agent any

    environment {
        // This MUST be the ID of the credential you created in Jenkins.
        DOCKERHUB_CREDENTIALS = 'dockerhub-creds'
        // This is the corrected variable name.
        DOCKER_IMAGE_NAME   = "ashishnegi77/my-python-app"
        EC2_SSH_KEY         = 'staging-server-ssh-key'
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
                    docker.build(DOCKER_IMAGE_NAME, '.')
                }
            }
        }

        stage('A. Run Tests') {
            steps {
                echo 'Running unit tests inside the container...'
                // Run tests within a temporary container from the image we just built
                sh "docker run --rm ${DOCKER_IMAGE_NAME} pytest"
            }
        }
        
        stage('3. Push to Docker Hub') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', DOCKERHUB_CREDENTIALS) {
                        def customTag = "build-${env.BUILD_NUMBER}"
                        sh "docker tag ${DOCKER_IMAGE_NAME} ${DOCKER_IMAGE_NAME}:${customTag}"
                        sh "docker push ${DOCKER_IMAGE_NAME}:${customTag}"
                        sh "docker tag ${DOCKER_IMAGE_NAME}:${customTag} ${DOCKER_IMAGE_NAME}:latest"
                        sh "docker push ${DOCKER_IMAGE_NAME}:latest"
                    }
                }
            }
        }
        
        stage('4. Deploy to Staging') {
            steps {
                script {
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
