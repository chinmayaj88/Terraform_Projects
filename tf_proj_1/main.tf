# Configure the OCI Provider
provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}

# Get the latest Ubuntu 22.04 image if not specified
data "oci_core_images" "ubuntu_images" {
  compartment_id           = var.compartment_ocid
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "22.04"
  shape                    = var.instance_shape
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

locals {
  # Use provided image OCID or get the latest Ubuntu 22.04
  instance_image_ocid = var.instance_image_ocid != "" ? var.instance_image_ocid : data.oci_core_images.ubuntu_images.images[0].id
  
  # Common tags
  common_tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}"
    }
  )
}

# ============================================================================
# VCN (Virtual Cloud Network)
# ============================================================================

resource "oci_core_vcn" "main" {
  compartment_id = var.compartment_ocid
  cidr_blocks    = [var.vcn_cidr]
  display_name   = "${var.project_name}-vcn"
  dns_label      = "apacheservervcn"
  
  freeform_tags = local.common_tags
}

# ============================================================================
# Internet Gateway
# ============================================================================

resource "oci_core_internet_gateway" "main" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.main.id
  display_name   = "${var.project_name}-igw"
  enabled        = true
  
  freeform_tags = local.common_tags
}

# ============================================================================
# Route Table
# ============================================================================

resource "oci_core_route_table" "public" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.main.id
  display_name   = "${var.project_name}-public-rt"
  
  route_rules {
    network_entity_id = oci_core_internet_gateway.main.id
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }
  
  freeform_tags = local.common_tags
}

# ============================================================================
# Security List
# ============================================================================

resource "oci_core_security_list" "public" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.main.id
  display_name   = "${var.project_name}-public-sl"
  
  # Ingress Rules
  
  # SSH Access
  ingress_security_rules {
    protocol    = "6" # TCP
    source      = var.allowed_ssh_cidr
    source_type = "CIDR_BLOCK"
    description = "Allow SSH access"
    stateless   = false
    
    tcp_options {
      min = 22
      max = 22
    }
  }
  
  # HTTP Access
  ingress_security_rules {
    protocol    = "6" # TCP
    source      = var.allowed_http_cidr
    source_type = "CIDR_BLOCK"
    description = "Allow HTTP access"
    stateless   = false
    
    tcp_options {
      min = 80
      max = 80
    }
  }
  
  # HTTPS Access
  ingress_security_rules {
    protocol    = "6" # TCP
    source      = var.allowed_http_cidr
    source_type = "CIDR_BLOCK"
    description = "Allow HTTPS access"
    stateless   = false
    
    tcp_options {
      min = 443
      max = 443
    }
  }
  
  # Egress Rules - Allow all outbound traffic
  egress_security_rules {
    protocol         = "all"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    description      = "Allow all outbound traffic"
  }
  
  freeform_tags = local.common_tags
}

# ============================================================================
# Public Subnet
# ============================================================================

resource "oci_core_subnet" "public" {
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_vcn.main.id
  cidr_block        = var.public_subnet_cidr
  display_name      = "${var.project_name}-public-subnet"
  dns_label         = "apacheserverpub"
  security_list_ids = [oci_core_security_list.public.id]
  route_table_id    = oci_core_route_table.public.id
  
  # Make it a public subnet
  prohibit_public_ip_on_vnic = false
  
  freeform_tags = local.common_tags
}

# ============================================================================
# Cloud-Init Script for VM Setup
# ============================================================================

locals {
  cloud_init_script = <<-EOF
    #!/bin/bash
    set -e
    
    # Update system
    apt-get update -y
    apt-get upgrade -y
    
    # Install Apache
    apt-get install -y apache2
    
    # Configure firewall
    ufw --force enable
    ufw allow 22/tcp
    ufw allow 80/tcp
    ufw allow 443/tcp
    
    # Enable and start Apache
    systemctl enable apache2
    systemctl start apache2
    
    echo "Apache installation completed successfully!"
    echo "Default Apache page will be available at http://$(curl -s ifconfig.me)"
  EOF
}

# ============================================================================
# Compute Instance
# ============================================================================

resource "oci_core_instance" "app" {
  compartment_id      = var.compartment_ocid
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  display_name        = "${var.project_name}-${var.environment}"
  shape               = var.instance_shape
  
  create_vnic_details {
    subnet_id        = oci_core_subnet.public.id
    assign_public_ip = var.assign_public_ip
    display_name     = "${var.project_name}-vnic"
  }
  
  source_details {
    source_type = "image"
    source_id   = local.instance_image_ocid
  }
  
  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data           = base64encode(local.cloud_init_script)
  }
  
  freeform_tags = local.common_tags
  
  # Wait for cloud-init to complete
  timeouts {
    create = "20m"
  }
}

# ============================================================================
# Data Sources
# ============================================================================

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

