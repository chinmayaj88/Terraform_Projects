variable "tenancy_ocid" {
  description = "OCID of your tenancy"
  type        = string
  sensitive   = true
}

variable "user_ocid" {
  description = "OCID of the user calling the API"
  type        = string
  sensitive   = true
}

variable "fingerprint" {
  description = "Fingerprint of the API private key"
  type        = string
  sensitive   = true
}

variable "private_key_path" {
  description = "Path to the private key file"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "OCI region (e.g., ap-mumbai-1, us-ashburn-1)"
  type        = string
  default     = "ap-mumbai-1"
}

variable "compartment_ocid" {
  description = "OCID of the compartment where resources will be created"
  type        = string
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "express-app"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "prod"
}

# VCN Configuration
variable "vcn_cidr" {
  description = "CIDR block for the VCN"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

# Compute Instance Configuration
variable "instance_shape" {
  description = "Shape of the compute instance"
  type        = string
  default     = "VM.Standard.E2.1.Micro" # Free tier eligible
}

variable "instance_image_ocid" {
  description = "OCID of the image to use. Leave empty to use latest Ubuntu 22.04"
  type        = string
  default     = ""
}

variable "ssh_public_key" {
  description = "SSH public key for instance access"
  type        = string
}

variable "assign_public_ip" {
  description = "Whether to assign a public IP address"
  type        = bool
  default     = true
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed for SSH access (0.0.0.0/0 for anywhere)"
  type        = string
  default     = "0.0.0.0/0"
}

variable "allowed_http_cidr" {
  description = "CIDR block allowed for HTTP access"
  type        = string
  default     = "0.0.0.0/0"
}

# Tags
variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Project     = "ExpressApp"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

