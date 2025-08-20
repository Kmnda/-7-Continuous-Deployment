pipeline {
  agent any

  environment {
    AWS_DEFAULT_REGION = credentials('aws-region-text') // e.g., ap-south-1
    AWS_ACCESS_KEY_ID = credentials('aws-access-key-id')
    AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
    ECR_ACCOUNT_ID = credentials('aws-account-id-text') // 12-digit account id (string credential)
    ECR_REPO = "flask-staging" // name of your ECR repository
    IMAGE = "${ECR_REPO}"
    GIT_SHA = "${env.GIT_COMMIT}"
    EC2_HOST = credentials('staging-ec2-host') // e.g., ec2-user@34.201.103.122
    SSH_KEY = 'staging-ec2-ssh-key' // Jenkins SSH credentials id for .pem key
  }

  options {
    skipDefaultCheckout(false)
    timestamps()
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
        sh 'git rev-parse --short HEAD > .jenkins/gitsha && cat .jenkins/gitsha'
      }
    }

    stage('Unit tests') {
      steps {
        sh 'docker build -t ${IMAGE}:${GIT_SHA} .'
        sh 'docker run --rm ${IMAGE}:${GIT_SHA} pytest -q'
      }
      post {
        always {
          sh 'docker image ls | head -n 20 || true'
        }
      }
    }

    stage('Login to ECR') {
      steps {
        sh '''
          aws ecr get-login-password --region ${AWS_DEFAULT_REGION}               | docker login --username AWS --password-stdin ${ECR_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com
        '''
      }
    }

    stage('Push image to ECR') {
      steps {
        sh '''
          docker tag ${IMAGE}:${GIT_SHA} ${ECR_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${ECR_REPO}:${GIT_SHA}
          docker tag ${IMAGE}:${GIT_SHA} ${ECR_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${ECR_REPO}:latest
          docker push ${ECR_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${ECR_REPO}:${GIT_SHA}
          docker push ${ECR_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${ECR_REPO}:latest
        '''
      }
    }

    stage('Deploy to EC2 (staging)') {
      steps {
        sshagent (credentials: [SSH_KEY]) {
          sh '''
            set -eux
            SHA=$(cat .jenkins/gitsha)
            ECR_URI="${ECR_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${ECR_REPO}"

            ssh -o StrictHostKeyChecking=no ${EC2_HOST} bash -s <<EOF
            set -eux
            # Login to ECR
            aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${ECR_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com
            # Pull and run
            docker pull "$ECR_URI:$SHA"
            docker rm -f web || true
            docker run -d --name web -p 80:8000 -e GIT_SHA="$SHA" "$ECR_URI:$SHA"
            docker ps
            EOF
          '''
        }
      }
    }

    stage('Post-deploy check') {
      steps {
        script {
          // Optional: simple HTTP check from Jenkins (replace with your public IP / DNS)
          sh 'echo "Hit your EC2 public DNS or Elastic IP here to verify deployment"'
        }
      }
    }
  }

  post {
    always {
      archiveArtifacts artifacts: '.jenkins/gitsha', onlyIfSuccessful: false
    }
  }
}
