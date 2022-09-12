This repo is to build WAN federated Consul clusters across 2 AWS regions.

## Deployment Architecture
![Consul Deployment architecture](https://github.com/panchal-ravi/terraform-consul-multi-cluster-vms/blob/main/files/Consul-Multi-Region-Cluster-VM.png?raw=true)

## <TODO>
Steps to generate Consul CA key and certificate

## 1. Create folder for private SSH key

Create foler "private-key" in the cloned folder and copy AWS private key file.

```
<git-cloned-folder>
    private-key
        <private-key.pem>
```

## 2. Copy Consul enterprise license

Create a file `consul-license` with Consul enterprise license and move it to `<git-clone-folder>/files/common/` folder. 

## 3. Create terraform.tfvars file

Create "terraform.tfvars" file in the cloned folder with below content:

```sh
owner                    = "<replace-with-ownername>" # for e.g. rp
aws_key_pair_key_name    = "<replace-with-aws-keypair-name>" # for e.g. consul-key
deployment_name          = "<replace-with-deployment-name>" # for e.g. rp-consul, use as prefix for aws resources
aws_instance_type        = "t3.small" # instance type to provision consul clusters
consul_cluster_instances = 3 # number of consul instances (should be a odd number for e.g. 1, 3, 5)
consul_version           = "1.12.4-ent"
region1                  = "ap-southeast-1" # AWS region to spin up primary consul datacenter
region2                  = "ap-south-1" # AWS region to spin up secondary consul datacenter
private_key_filename     = "rp-key.pem" # Name of the private key file copied to above folder 
```

## 4. Build Consul AMI image

Build Consul AMI image and push it to region1 and region2 as configured above in terraform.tfvars file

### Build AMI and push to region-1
```sh
cd <git-cloned-folder>/amis/consul

# Configure variables.pkrvars.hcl
# For e.g. change aws_region value to "ap-southeast-1" (whatever value you configured for region1 variable above)
packer build -var-file="variables.pkrvars.hcl" .
```


### Build AMI and push to region-2
```sh
cd <git-cloned-folder>/amis/consul

# Configure variables.pkrvars.hcl
# For e.g. change aws_region value to "ap-south-1" (whatever value you configured for region2 variable above)
packer build -var-file="variables.pkrvars.hcl" .
```

## 5 Build and apply Terraform

```sh
cd <git-cloned-folder>
terraform init
terraform validate
terraform apply -auto-approve
```