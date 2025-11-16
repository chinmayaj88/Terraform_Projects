# Terraform OCI Deployment

This directory contains Terraform configuration files for deploying the Express.js application to Oracle Cloud Infrastructure (OCI).

## 🎯 Overview

This Terraform configuration creates a production-grade infrastructure on OCI:

- **VCN (Virtual Cloud Network)** with proper CIDR blocks
- **Internet Gateway** for public internet access
- **Public Subnet** with proper routing
- **Security List** with correct ingress/egress rules (fixes browser access issues)
- **Compute Instance** with Ubuntu 22.04
- **Automated VM Setup** via cloud-init (Docker, Nginx, firewall)

## 📋 Prerequisites

1. **OCI Account** with appropriate permissions
2. **OCI API Key** configured
3. **Terraform** installed (>= 1.5.0)
4. **SSH Key Pair** generated

### Install Terraform

**Windows (PowerShell):**
```powershell
# Using Chocolatey
choco install terraform

# Or download from https://www.terraform.io/downloads
```

**Linux/Mac:**
```bash
# Using Homebrew (Mac)
brew install terraform

# Or download from https://www.terraform.io/downloads
```

### Generate SSH Key Pair

```powershell
# Windows PowerShell
ssh-keygen -t rsa -b 4096 -f $env:USERPROFILE\.ssh\oci_terraform_key
```

```bash
# Linux/Mac
ssh-keygen -t rsa -b 4096 -f ~/.ssh/oci_terraform_key
```

## 🔑 OCI API Key Setup

1. **Create API Key:**
   - Log in to OCI Console
   - Go to **Identity** → **Users** → Select your user
   - Click **API Keys** → **Add API Key**
   - Choose **Paste Public Key** and paste your public key
   - Click **Add**

2. **Get Required Values:**
   - **Tenancy OCID**: Found in **Administration** → **Tenancy Details**
   - **User OCID**: Found in your **User Details**
   - **Fingerprint**: Shown after creating API key
   - **Private Key**: The private key file you generated

3. **Get Compartment OCID:**
   - Go to **Identity** → **Compartments**
   - Select your compartment
   - Copy the OCID

## 🚀 Quick Start

### Step 1: Configure Variables

1. Copy the example variables file:
   ```powershell
   cd terraform
   Copy-Item terraform.tfvars.example terraform.tfvars
   ```

2. Edit `terraform.tfvars` with your values:
   ```hcl
   tenancy_ocid     = "ocid1.tenancy.oc1..xxxxx"
   user_ocid        = "ocid1.user.oc1..xxxxx"
   fingerprint      = "xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx"
   private_key_path = "~/.oci/oci_api_key.pem"
   region           = "ap-mumbai-1"
   compartment_ocid = "ocid1.compartment.oc1..xxxxx"
   ssh_public_key   = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC... your-key-here"
   ```

   **To get your SSH public key:**
   ```powershell
   Get-Content $env:USERPROFILE\.ssh\oci_terraform_key.pub
   ```

### Step 2: Initialize Terraform

```powershell
cd terraform
terraform init
```

This downloads the OCI provider and initializes the backend.

### Step 3: Review the Plan

```powershell
terraform plan
```

This shows what resources will be created without actually creating them.

### Step 4: Apply the Configuration

```powershell
terraform apply
```

Type `yes` when prompted. This will:
- Create the VCN and networking components
- Create the compute instance
- Configure the VM with Docker and Nginx
- Set up security lists correctly

**This takes about 5-10 minutes.**

### Step 5: Get Outputs

After deployment, Terraform will show outputs including:
- Public IP address
- SSH connection command
- Application URL

You can also get outputs later:
```powershell
terraform output
terraform output instance_public_ip
terraform output application_url
```

## 📦 Deploying Your Application

After Terraform creates the infrastructure:

### Option 1: Manual Deployment

1. **SSH into the instance:**
   ```powershell
   ssh -i $env:USERPROFILE\.ssh\oci_terraform_key ubuntu@<public-ip>
   ```

2. **Wait for cloud-init to complete:**
   ```bash
   sudo cloud-init status --wait
   ```

3. **Verify installations:**
   ```bash
   docker --version
   nginx -v
   ```

4. **Deploy your app:**
   ```bash
   # Pull from OCI Container Registry
   docker login <region>.ocir.io
   docker pull <region>.ocir.io/<namespace>/express-app:latest
   
   # Run the container
   docker run -d \
     --name express-app \
     --restart unless-stopped \
     -p 3000:3000 \
     <region>.ocir.io/<namespace>/express-app:latest
   ```

5. **Verify it's working:**
   ```bash
   curl http://localhost:3000
   curl http://localhost
   ```

6. **Access from browser:**
   ```
   http://<public-ip>
   ```

### Option 2: Use GitHub Actions CI/CD

If you have GitHub Actions set up, it will automatically deploy when you push to the repository.

## 🔍 Verification

### Check Security List

The Terraform configuration automatically creates security list rules for:
- **Port 22** (SSH)
- **Port 80** (HTTP)
- **Port 443** (HTTPS)

These are properly attached to the subnet, which fixes the browser access issue.

### Test Connectivity

```powershell
# Test HTTP
Test-NetConnection -ComputerName <public-ip> -Port 80

# Test from browser
# http://<public-ip>
```

### Check Logs

```bash
# Application logs
docker logs express-app

# Nginx access logs
sudo tail -f /var/log/nginx/express-app-access.log

# Nginx error logs
sudo tail -f /var/log/nginx/express-app-error.log
```

## 🛠️ Common Commands

```powershell
# Initialize
terraform init

# Plan changes
terraform plan

# Apply changes
terraform apply

# Destroy infrastructure
terraform destroy

# Show outputs
terraform output

# Show state
terraform show

# Format code
terraform fmt

# Validate configuration
terraform validate
```

## 🔒 Security Best Practices

1. **Restrict SSH Access:**
   ```hcl
   allowed_ssh_cidr = "YOUR_IP/32"  # Only your IP
   ```

2. **Use Reserved Public IP:**
   - Create a reserved public IP in OCI Console
   - Update the instance to use it

3. **Enable HTTPS:**
   - Set up Let's Encrypt certificate
   - Configure Nginx for HTTPS

4. **Use Network Security Groups:**
   - Create NSGs for additional security layers

5. **Rotate Keys Regularly:**
   - Update SSH keys periodically
   - Rotate OCI API keys

## 🗑️ Cleanup

To destroy all resources:

```powershell
terraform destroy
```

**Warning:** This will delete all resources created by Terraform!

## 📝 Troubleshooting

### Issue: "Authentication failed"

- Verify your API key is correct
- Check the fingerprint matches
- Ensure private key path is correct
- Verify user has necessary permissions

### Issue: "Insufficient permissions"

- Ensure user has `manage` permissions for:
  - VCN, Subnet, Security List
  - Compute Instance
  - Internet Gateway

### Issue: "Instance creation failed"

- Check shape availability in your region
- Verify image OCID is correct
- Check quota limits

### Issue: "Can't access from browser"

The Terraform configuration fixes this by:
- ✅ Properly configuring security lists
- ✅ Attaching security list to subnet
- ✅ Configuring route tables correctly
- ✅ Setting up firewall rules

If still having issues:
1. Verify security list rules in OCI Console
2. Check instance firewall: `sudo ufw status`
3. Test from VM: `curl http://localhost`

## 📚 Additional Resources

- [Terraform OCI Provider Documentation](https://registry.terraform.io/providers/oracle/oci/latest/docs)
- [OCI Networking Documentation](https://docs.oracle.com/en-us/iaas/Content/Network/Concepts/overview.htm)
- [OCI Compute Documentation](https://docs.oracle.com/en-us/iaas/Content/Compute/Concepts/computeoverview.htm)

## 🎉 Success!

Once deployed, you should be able to:
- ✅ Access your app at `http://<public-ip>`
- ✅ SSH into the instance
- ✅ Deploy updates via CI/CD
- ✅ Scale as needed

---

**Last Updated:** 2025-01-XX

