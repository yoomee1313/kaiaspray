# Deploy Private Layer1 Network on Azure

### 1. Deploy Azure resources
> :warning: Before running the following commands, please get Azure credentials using command below.
```bash
az login
```

> :warning: If you don't have a resource group named 'Kaiaspray', create it using the command below.
```bash
az group create --name Kaiaspray --location koreacentral
```

> :warning: Azure Limitations
> - Plan information is required when using Marketplace images. Check the image information and add plan information if necessary.
> - The default core quota in Korea Central region is limited to 4 cores. Request a quota increase if you need more cores.
> - The number of Public IP addresses per region per subscription is limited to 3. Request a quota increase if you need more Public IPs.
> - If you encounter "resource already exists" errors, you need to either clean up existing resources or import them into Terraform state.
> - Before deploying, you must accept the legal terms for the Marketplace image. Run the following command:
```bash
az vm image terms accept --publisher resf --offer rockylinux-x86_64 --plan 9-base
```

Execute command belows to deploy resources via Terraform.
```bash
$ git clone https://github.com/kaiachain/kaiaspray.git
$ cd kaiaspray
$ export TF_OPTIONS="-chdir=terraform/azure/private-layer1"
$ terraform $TF_OPTIONS init
$ terraform $TF_OPTIONS apply -auto-approve
```

terraform output will be shown like the below.
```hcl
layer1 = {
  cn = [
    {
      "instance_id" = "<instance-id>"
      "private_ip" = "<private-ip>"
      "public_ip" = "<public-ip>"
    },
    ...
  ]
  en = [
    {
      "instance_id" = "<instance-id>"
      "private_ip" = "<private-ip>"
      "public_ip" = "<public-ip>"
    },
  ]
  pn = [
    {
      "instance_id" = "<instance-id>"
      "private_ip" = "<private-ip>"
      "public_ip" = "<public-ip>"
    },
    ...
  ]
  monitor = {
    "instance_id" = "<instance-id>"
    "private_ip" = "<private-ip>"
    "public_ip" = "<public-ip>"
  }
  layer1_sg_id  = "<security-group-id>"
  monitor_sg_id = "<security-group-id>"
}
```

### 2. Check the generated files
You can check two files in the root path of kaiaspray.
1. azure-private-ssh-key.pem: a file to use via SSH
2. inventory/private-layer1/inventory.ini: a file storing Kaia node connection information


### 3. Execute Ansible playbook
```bash
$ ansible-playbook -i inventory/private-layer1/inventory.ini private-layer1.yaml
```
### 4. Check working using Grafana
Open http://<monitor-public-ip>:3000 in the webbrowser. The default credential is admin:admin.

![Image](docs/img/grafana.png?raw=true)

### 5. Destroy the deployed instances
```bash
$ terraform $TF_OPTIONS destroy -auto-approve
```

### Additional Configuration Options

You can modify various configuration options in the terraform.tfvars file. See the example below for available settings:

#### Option1. deploy_options

The `deploy_options` block configures deployment settings for your Kaia nodes:

1. **Installation Mode**:
   - Set `kaia_install_mode` to specify how nodes are installed
   - Available options are "package" or "build"

2. **Version Control**:
   - Set `kaia_version` to specify which version to deploy
   - Example: "v1.0.3"

3. **Docker Build Settings**:
   - Use `kaia_build_docker_base_image` to set the base image for builds
   - Only needed when installation mode is "build"

4. **Network Configuration**:
   - `kaia_network_id`: Unique identifier for your network
   - `kaia_chain_id`: Chain identifier for your network

### Example terraform.tfvars
```
deploy_options = {
  kaia_install_mode = "package"
  kaia_version = "v1.0.3"
  kaia_build_docker_base_image = "kaiachain/build_base:latest"
  kaia_network_id = 9999
  kaia_chain_id   = 9999
}
```