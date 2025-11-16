terraform {
  required_version = ">= 1.5.0"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 5.0"
    }
  }

  # Optional: Configure remote state backend
  # Uncomment and configure if you want to use OCI Object Storage for state
  # backend "s3" {
  #   bucket   = "terraform-state-bucket"
  #   key      = "oci-express-deployment/terraform.tfstate"
  #   region   = "us-east-1"
  #   endpoint = "https://namespace.compat.objectstorage.region.oraclecloud.com"
  # }
}

