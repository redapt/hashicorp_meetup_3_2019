node(){
    properties([
        parameters([
            string(name: 'domain_name', description: 'The domain name you\'re deploying to.', defaultValue: 'redaptdemo.com')
        ])
    ])

    stage('Fetch Sources'){
        deleteDir()         
        git branch: 'jenkins', credentialsId: 'gh_creds', url: 'https://github.com/redapt/hashicorp_meetup_3_2019.git'
    }
    stage('Configure tfvars'){
        copyArtifacts filter: '**/*.tfvars', projectName: 'HashicorpMeetupPlatform', selector: lastSuccessful(), target: '.'

        sh'''
            echo "domain_name=${domain_name}" | tee -a terraform.tfvars > /dev/null
            echo "docker_username=${DOCKERHUB_USER}" | tee -a terraform.tfvars > /dev/null
            echo "docker_password=${DOCKERHUB_SECRET}" | tee -a terraform.tfvars > /dev/null
        '''
    }
    withCredentials([
        azureServicePrincipal(
            clientIdVariable: 'ARM_CLIENT_ID',
            clientSecretVariable: 'ARM_CLIENT_SECRET', 
            credentialsId: 'azure_demo_creds', 
            subscriptionIdVariable: 'ARM_SUBSCRIPTION_ID', 
            tenantIdVariable: 'ARM_TENANT_ID'),
        usernamePassword(
            credentialsId: 'dockerhub', 
            passwordVariable: 'DOCKERHUB_SECRET', 
            usernameVariable: 'DOCKERHUB_USER')
            ])
    {
        dir('app_config') {
            stage('Initialize Terraform') {
                sh '''
                    yes | terraform init
                '''
            }
            stage('Generate Plan'){
                sh"""
                    terraform plan -input=false \
                        -var domain_name=${domain_name}
                        -var docker_username=${DOCKERHUB_USER} \
                        -var docker_password=${DOCKERHUB_SECRET}
                        -out docker.plan
                """

                stash name: 'plan', includes: 'docker.plan'

            }
            stage('Apply Plan'){
                sshagent(['meetup_ssh']) {
                    unstash name: 'plan'
                    sh'''
                        terraform apply docker.plan
                    '''
                }
            }                           
        }
    }
}