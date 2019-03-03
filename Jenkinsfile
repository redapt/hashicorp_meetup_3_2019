pipeline{
    agent any
    
    environment {
        TF_IN_AUTOMATION = 1
        CLOUDFLARE_EMAIL = 'cloudsupport@redapt.com'
        ARM_USE_MSI=true
    }
    parameters {
        string(name: 'cidr_blocks', description: 'The CIDR block for the VPC/vNet', defaultValue: '10.12.0.0/16')
        string(name: 'public_key_path', description: 'The path to the public key to upload to KMS', defaultValue: './meetup_sshkey.pub')
        string(name: 'userdata_path', description: 'Path to the script housing your userdata setup.', defaultValue: './scripts/setup_vm.sh')
        string(name: 'domain_name', description: 'The domain name being administered by CloudFlare.', defaultValue: 'redaptdemo.com')
        choice(name: 'record_type', description: 'The type of DNS record to create.', choices: ['A','SRV','TXT'])
        string(name: 'record_names', description: 'The names of the records that you want to apply', defaultValue: '"redaptu","redaptdb"')
        booleanParam(name: 'proxied', description: 'Whether the record gets Cloudflare\'s origin protection; defaults to false.', defaultValue: false)
        string(name: 'email_address', description: 'The contact email address for this account', defaultValue: 'cloudsupport@redapt.com')
        string(name: 'subject_alternative_names', description: 'The certificate\'s subject alternative names, domains that this certificate will also be recognized for.')
    }
    stages{
        stage("Fetch sources"){
            steps 
            {   
                deleteDir()         
                git branch: 'jenkins', credentialsId: 'gh_creds', url: 'https://github.com/redapt/hashicorp_meetup_3_2019.git'
            }
        }
        stage("Setup Terraform Backend"){
            steps {
                withCredentials([
                    azureServicePrincipal(
                        clientIdVariable: 'ARM_CLIENT_ID',
                        clientSecretVariable: 'ARM_CLIENT_SECRET', 
                        credentialsId: 'azure_demo_creds', 
                        subscriptionIdVariable: 'ARM_SUBSCRIPTION_ID', 
                        tenantIdVariable: 'ARM_TENANT_ID')])
                {

                    dir('scripts'){
                        sh '''
                            powershell Setup-TerraformBackend.ps1
                        '''
                    }

                }
                sleep 5
            }
        }
        stage('Build Terraform Base'){
            agent any
            steps {
                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding', accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'aws_creds', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'], 
                    string(credentialsId: 'cloudflare_api_key', variable: 'CLOUDFLARE_TOKEN'),
                    string(credentialsId: 'cloudflare_api_key', variable: 'CLOUDFLARE_API_KEY'),
                    azureServicePrincipal(clientIdVariable: 'ARM_CLIENT_ID', clientSecretVariable: 'ARM_CLIENT_SECRET', credentialsId: 'azure_demo_creds', subscriptionIdVariable: 'ARM_SUBSCRIPTION_ID', tenantIdVariable: 'ARM_TENANT_ID')
                    ]) 
                {                
                    sh'''
                        export CLOUDFLARE_API_KEY=${CLOUDFLARE_TOKEN}
                    '''

                    echo "Initialize Terraform"
                    retry(3) {
                        sh'''
                            yes | terraform init
                        '''
                    }
                    
                retry(3){
                    echo "Terraform Plan - Platform"
                    sh'''
                        export USE_ARM_MSI=true

                        terraform plan -var cidr_blocks="${cidr_blocks}" \
                            -var public_key_path="${public_key_path}" \
                            -var userdata_path="${userdata_path}" \
                            -var domain_name="${domain_name}" \
                            -var record_names=[${record_names}] \
                            -var proxied=${proxied} \
                            -var email_address="${email_address}" \
                            -var subject_alternative_name=[${subject_alternative_names}] \
                            -out platform.plan
                    '''
                    sshagent(['meetup_ssh']) {
                        echo "Apply Platform Plan"
                        sh'''
                            terraform apply platform.plan
                        '''
                    }
                }
                    sh '''
                        export TF_VAR_frontend_ip=$(terraform output aws_public_ip)
                        export TF_VAR_backend_ip=$(terraform output azure_public_ip)
                        terraform output issuer_pem | tee app/ca.pem
                        terraform output certificate_pem | tee app/cert.pem
                        terraform output private_key_pem | tee app/key.pem
                    '''
                }
            }
        }
        stage('Build PFX Certificate') {
            agent any
            steps {
                sh'''
                    openssl pkcs12 -export -out app/certificate.pfx -inkey app/key.pem -in app/cert.pem -certfile app/ca.pem -nodes
                '''
            }
        }
        stage('Build Website Container') {
            agent any
            steps {
                dir('app') {
                    sh'''
                        docker build --compress . -t iancornett/redaptuniversity:latest -t iancornett/redaptuniversity
                    '''

                    withCredentials([usernamePassword(credentialsId: 'dockerhub', passwordVariable: 'DOCKERHUB_SECRET', usernameVariable: 'DOCKERHUB_USER')]) {
                        sh'''
                            echo ${DOCKERHUB_SECRET} | docker login -u ${DOCKERHUB_USER} --password-stdin
                            docker push iancornett/redaptuniversity
                        '''
                    }
                }
            }
        }
        stage('Setup Docker'){
            steps {
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
                        sh '''
                            yes | terraform init
                        '''

                        sh'''
                            echo "domain_name=${domain_name}" | tee -a terraform.tfvars
                            echo "docker_username=${DOCKERHUB_USER}" | tee -a terraform.tfvars
                            echo "docker_password=${DOCKERHUB_SECRET}" | tee -a terraform.tfvars
                        '''

                        sh'''
                            terraform plan -out docker.plan
                        '''

                        sshagent(['meetup_ssh']) {
                            sh'''
                                terraform apply docker.plan
                            '''
                        }
                    }
                }
            }
        }
    }
    post{
        success{
            echo "========pipeline executed successfully ========"
        }
        failure{
            echo "========pipeline execution failed========"
        }
    }
}