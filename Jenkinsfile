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
                echo "[web_servers]" > ansible/inventory.ini
                echo "${env.WEB_SERVER_IP}" >> ansible/inventory.ini
                
                cd ansible && ansible-playbook -i inventory.ini playbook.yml
                """
            }
        }
    }

    post {
        always {
            // Re-enable this to destroy resources after the project is complete
            // sh "cd terraform && terraform destroy -auto-approve -var='jenkins_server_ip=${env.JENKINS_SERVER_IP}'"
        }
    }
}
