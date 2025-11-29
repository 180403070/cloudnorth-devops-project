#!/bin/bash
# Jenkins Agent Setup Script

echo "Setting up Jenkins agent for CloudNorth project..."

# Install Docker
sudo apt-get update
sudo apt-get install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker

# Add jenkins user to docker group
sudo usermod -aG docker jenkins

# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install Terraform
wget https://releases.hashicorp.com/terraform/1.5.0/terraform_1.5.0_linux_amd64.zip
sudo unzip terraform_1.5.0_linux_amd64.zip -d /usr/local/bin/
rm terraform_1.5.0_linux_amd64.zip

# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm -rf awscliv2.zip aws/

# Verify installations
echo "=== Installation Verification ==="
docker --version
node --version
npm --version
terraform --version
aws --version

echo "Jenkins agent setup complete!"