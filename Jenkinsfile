node() {
    properties([
        parameters([
            string(name: 'cidr_block', description: 'The CIDR block for the VPC', defaultValue: '10.12.0.0/16'),
            string(name: 'public_key_path', description: 'The path to the public key to upload to KMS', default: './meetup_sshkey.pub'),
            string(name: 'userdata_path', description: 'Path to the script housing your userdata setup.', defaultValue: './scripts/setup_vm.sh'),
            string(name: 'tags', description: 'A mapping of tags to assign to the resource (k="v",k="v" format)', defaultValue: ''),
            string(name: 'public_key_path', description: 'The path to the public key to upload to KMS', defaultValue: './meetup_sshkey.pub'),
            string(name: 'userdata_path', description: 'Path to the script housing your userdata setup.', defaultValue: './scripts/setup_vm.sh'),
            string(name: 'num_records', description: 'The number of records to create.', defaultValue: '2'),
            string(name: 'record_type', description: 'The type of DNS record to create', defaultValue: 'A'),
            string(name: 'record_names', description: 'The names of the records to create.', defaultValue: '"redaptu","redaptdb"'),
            booleanParam(name: 'cloudflare_proxied', description: 'Whether the record gets Cloudflare\'s origin protection; defaults to false.', defaultValue: false),
            string(name: 'email_address', description: 'The contact email address for the account', defaultValue: 'cloudsupport@redapt.com'),
            string(name: 'subject_alternative_names', description: 'The certificate\'s subject alternative names, domains that this certificate will also be recognized for.', defaultValue: '"redaptu.redaptdemo.com","redaptdb.redaptdemo.com"')
        ])
    ])

    stage('terraform init - VMs') {
        sh '''
            terraform init -input=false
        '''
    }

    stage('terraform plan - VMs') {
        sh '''
            terraform plan -input=false \
                -out vmplan \
                -var cidr_block=${cidr_block} \
                -var public_key_path=${public_key_path} \
                -var userdata_path=${userdata_path} \
                -var num_records=${num_records} \
                -var record_type=${record_type} \
                -var record_names=[${record_names}] \
                -var proxied=${cloudflare_proxied} \
                -var email_address=${email_address} \
                -var subject_alternative_names=[${subject_alternative_names}]
        '''
    }

    stage('terraform apply - VMs') {
        sh '''
            terraform apply vmplan
        '''
    }
}