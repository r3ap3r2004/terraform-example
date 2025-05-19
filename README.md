# Terraform Multi-Region Infra

See environments/us-east-1 for fully working example.

To deploy the example:
```bash
./scripts/deploy.sh
```

To remove the generated infrastructure:
```bash
./scripts/destroy.sh
```

This example will build a web server and a mysql server.  NOTE: These won't be fully working, it's just an example, and would need more configuration for any real use.  See the scripts in `./user_data` for example configuration.

The `IAM` roles that are created are also not fully fleshed out, and are only put in place for a general example.

Be sure to add your public ssh keys to `./user_data/authorized_keys.yml` or you may not be able to ssh to the server.
By default an AWS Key Pair will be created based on your own `.ssh/id_rsa.pub` key.
You can use an existing AWS Key Pair by modifying the `ssh_key_name` default value to be the name of an existing AWS Key Pair.

To deploy to a region other than `us-east-1` you should copy the files from `environments/us-east-1` to `environments/<YOUR REGION>` and adjust them as needed.

Security Group rules can be modified in the `./sg_rules/` files.  There are separate files for ingress and egress.

The code defaults to using OpenTofu, with a fallback to Terraform.

OpenTofu: https://opentofu.org/
Terraform: https://developer.hashicorp.com/terraform


### OpenTofu Install

You can install OpenTofu on an Ubuntu machine by doing:
```bash
# Download the installer script:
curl --proto '=https' --tlsv1.2 -fsSL https://get.opentofu.org/install-opentofu.sh -o install-opentofu.sh
# Alternatively: wget --secure-protocol=TLSv1_2 --https-only https://get.opentofu.org/install-opentofu.sh -O install-opentofu.sh

# Give it execution permissions:
chmod +x install-opentofu.sh

# Please inspect the downloaded script

# Run the installer:
./install-opentofu.sh --install-method deb

# Remove the installer:
rm -f install-opentofu.sh
```

The latest instructions can be found here: https://opentofu.org/docs/intro/install/deb/


### Terraform Install

You can install terraform on an Ubuntu machine by doing:
```bash
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
```

For the latest instructions go to: https://developer.hashicorp.com/terraform/install


