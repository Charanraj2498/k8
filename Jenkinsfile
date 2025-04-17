pipeline {
    agent any

    environment {
        WORKSPACE = '/mnt/jenkins_home/workspace'
        TERRAFORM_VERSION = '1.3.6'
        TF_VAR_AWS_REGION = 'us-east-1'
    }

    stages {
        stage('Clone Repository') {
            steps {
                git 'https://github.com/Charanraj2498/k8.git'
            }
        }

        stage('Install Terraform') {
            steps {
                sh '''
                curl -LO https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
                unzip -o terraform_${TERRAFORM_VERSION}_linux_amd64.zip
                sudo mv terraform /usr/local/bin/
                terraform --version
                '''
            }
        }

        stage('Terraform Init') {
            steps {
                sh 'terraform init'
            }
        }

        stage('Terraform Plan') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-jenkins-creds']]) {
                    sh 'terraform plan -out=tfplan'
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-jenkins-creds']]) {
                    sh 'terraform apply -auto-approve tfplan'
                }
            }
        }
    }

    post {
        success {
            echo '✅ Terraform apply was successful!'
        }
        failure {
            echo '❌ Terraform pipeline failed.'
        }
    }
}
