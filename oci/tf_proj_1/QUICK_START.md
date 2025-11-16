# 🚀 Quick Start - Terraform Deployment

## Prerequisites
- [ ] OCI Account
- [ ] Terraform installed (`terraform version`)
- [ ] OCI API Key configured
- [ ] SSH key pair generated

## 5-Minute Setup

### 1. Configure Variables
```powershell
cd terraform
Copy-Item terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
```

### 2. Deploy
```powershell
terraform init
terraform plan
terraform apply
```

### 3. Get Public IP
```powershell
terraform output instance_public_ip
```

### 4. SSH and Deploy App
```powershell
ssh -i ~/.ssh/oci_terraform_key ubuntu@<public-ip>
# Wait for cloud-init: sudo cloud-init status --wait
# Deploy your app (see full guide)
```

### 5. Access
```
http://<public-ip>
```

## Common Commands

```powershell
# Show outputs
terraform output

# Destroy everything
terraform destroy

# Show state
terraform show
```

## Need Help?
See [DEPLOYMENT_TERRAFORM.md](../DEPLOYMENT_TERRAFORM.md) for detailed instructions.

