pipeline{
    agent any

    options { preserveStashes() }

    environment {
        TF_IN_AUTOMATION = 1
        CLOUDFLARE_EMAIL = 'cloudsupport@redapt.com'
        ARM_USE_MSI=true
    }
    parameters {
        string(name: 'cidr_blocks', description: 'The CIDR block for the VPC/vNtfvarset', defaultValue: '10.12.0.0/16')
        string(name: 'public_key_path', description: 'The path to the public ketfvarsy to upload to KMS', defaultValue: './meetup_sshkey.pub')
        string(name: 'userdata_path', description: 'Path to the script housing tfvarsyour userdata setup.', defaultValue: './scripts/setup_vm.sh')
        string(name: 'domain_name', description: 'The domain name being administfvarstered by CloudFlare.', defaultValue: 'redaptdemo.com')
        choice(name: 'record_type', description: 'The type of DNS record to cretfvarsate.', choices: ['A','SRV','TXT'])
        string(name: 'record_names', description: 'The names of the records thatfvarst you want to apply', defaultValue: '"redaptu","redaptdb"')
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

        stage("Copy Artifacts"){
            steps {
                copyArtifacts filter: '**/*.tfvars', projectName: 'HashicorpMeetupPlatform', selector: lastSuccessful(), target: '.'
            }
        }

        stage('Destroy base platform'){
            steps {
                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding', accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: '4ac9ab41-5279-443b-a9d8-1d56b6bace81', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'], 
                        string(credentialsId: 'cloudflare_api_key', variable: 'CLOUDFLARE_TOKEN'), 
                        string(credentialsId: 'cloudflare_api_key', variable: 'CLOUDFLARE_API_KEY'), 
                        azureServicePrincipal(clientIdVariable: 'ARM_CLIENT_ID', clientSecretVariable: 'ARM_CLIENT_SECRET', credentialsId: 'azure_demo_creds', subscriptionIdVariable: 'ARM_SUBSCRIPTION_ID', tenantIdVariable: 'ARM_TENANT_ID')]) {            
                    
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
                                -destroy \
                                -out platform.plan
                        '''

                        echo "Apply Platform Destroy Plan"
                        sh'''
                            terraform apply platform.plan
                        '''
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