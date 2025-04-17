pipeline {
    agent any

    environment {
        TERRAFORM_VERSION = '1.3.6'
        TF_VAR_AWS_REGION = 'us-east-1'  // Set your AWS region here
    }

    stages {
        stage('Clone Repository') {
            steps {
                script {
                    git 'https://github.com/Charanraj2498/k8.git'
                }
            }
        }

        stage('Install Terraform') {
            steps {
                script {
                    // Install Terraform (if necessary)
                    sh 'curl -LO https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip'
                    sh 'unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip'
                    sh 'mv terraform /usr/local/bin/'
                    sh 'terraform --version'
                }
            }
        }

        stage('Terraform Init') {
            steps {
                script {
                    // Initialize Terraform
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                script {
                    // Run Terraform Plan
                    sh 'terraform plan -out=tfplan'
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                script {
                    // Use AWS credentials stored in Jenkins
                    withCredentials([aws(credentialsId: 'aws-jenkins-creds', region: 'us-east-1')]) {
                        // Apply Terraform configuration
                        sh 'terraform apply -auto-approve tfplan'
                    }
                }
            }
        }
    }

    post {
        success {
            echo 'Terraform apply was successful!'
        }
        failure {
            echo 'There was a failure in the Terraform pipeline.'
        }
    }
}

