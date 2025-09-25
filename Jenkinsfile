pipeline {
    agent any

    stages {
        stage('Provision Infrastructure') {
            steps {
                script {
                    // Get the public IP of the Jenkins server
                    def jenkinsIp = sh(
                        script: 'curl ifconfig.me',
                        returnStdout: true
                    ).trim()
                    echo "Jenkins IP is: ${jenkinsIp}"

                    // Initialize Terraform
                    sh 'cd terraform && terraform init'

                    // Plan and apply the infrastructure, passing the Jenkins IP
                    sh "cd terraform && terraform apply -auto-approve -var='jenkins_server_ip=${jenkinsIp}'"

                    // Get the web server IP from Terraform output
                    def webServerIp = sh(
                        script: 'cd terraform && terraform output -raw web_server_ip',
                        returnStdout: true
                    ).trim()

                    // Store the IP for the next stage
                    env.WEB_SERVER_IP = webServerIp
                    echo "Web Server IP is: ${env.WEB_SERVER_IP}"
                }
            }
        }
        
        stage('Deploy Application') {
            steps {
                sh """
                # Generate a temporary Ansible inventory file
                echo "[web_servers]" > ansible/inventory.ini
                echo "${env.WEB_SERVER_IP}" >> ansible/inventory.ini
                
                # Run the Ansible playbook
                cd ansible && ansible-playbook -i inventory.ini playbook.yml
                """
            }
        }
    }

    // This section runs after all stages are complete
    post {
        always {
            // This command is currently commented out for debugging.
            // When your pipeline is working, uncomment this to automatically destroy resources.
            // sh "cd terraform && terraform destroy -auto-approve"
        }
    }
}
