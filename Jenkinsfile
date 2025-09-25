pipeline {
    agent any

    stages {
        stage('Provision Infrastructure') {
            steps {
                script {
                    // Initialize Terraform
                    sh 'cd terraform && terraform init'

                    // Plan and apply the infrastructure
                    sh 'cd terraform && terraform apply -auto-approve'

                    // Get the server IP from Terraform output
                    def serverIp = sh(
                        script: 'cd terraform && terraform output -raw server_ip',
                        returnStdout: true
                    ).trim()

                    // Store the IP for the next stage
                    env.SERVER_IP = serverIp
                    echo "Server IP is: ${env.SERVER_IP}"
                }
            }
        }
        
        stage('Deploy Application') {
            steps {
                sh """
                # Generate a temporary Ansible inventory file
                echo "[web_servers]" > ansible/inventory.ini
                echo "${env.SERVER_IP}" >> ansible/inventory.ini
                
                # Run the Ansible playbook
                cd ansible && ansible-playbook -i inventory.ini playbook.yml
                """
            }
        }
    }

    // Always clean up resources
    post {
        always {
            sh 'cd terraform && terraform destroy -auto-approve'
        }
    }
}
