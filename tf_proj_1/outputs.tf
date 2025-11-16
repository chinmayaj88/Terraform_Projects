output "vcn_id" {
  description = "OCID of the VCN"
  value       = oci_core_vcn.main.id
}

output "vcn_cidr" {
  description = "CIDR block of the VCN"
  value       = oci_core_vcn.main.cidr_blocks[0]
}

output "public_subnet_id" {
  description = "OCID of the public subnet"
  value       = oci_core_subnet.public.id
}

output "instance_id" {
  description = "OCID of the compute instance"
  value       = oci_core_instance.app.id
}

output "instance_public_ip" {
  description = "Public IP address of the compute instance"
  value       = oci_core_instance.app.public_ip
}

output "instance_private_ip" {
  description = "Private IP address of the compute instance"
  value       = oci_core_instance.app.private_ip
}

output "ssh_connection_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i <your-private-key> ubuntu@${oci_core_instance.app.public_ip}"
}

output "apache_url" {
  description = "URL to access Apache default page"
  value       = "http://${oci_core_instance.app.public_ip}"
}

output "deployment_instructions" {
  description = "Instructions for accessing Apache"
  value = <<-EOT
    ============================================
    Apache Server Deployment
    ============================================
    
    1. Wait for cloud-init to complete (about 2-3 minutes)
       SSH into the instance and check:
       ssh -i <your-private-key> ubuntu@${oci_core_instance.app.public_ip}
       sudo cloud-init status --wait
    
    2. Verify Apache is installed and running:
       sudo systemctl status apache2
       apache2 -v
    
    3. Access Apache default page in your browser:
       http://${oci_core_instance.app.public_ip}
    
    4. You should see the default Apache2 Ubuntu page!
    
    ============================================
  EOT
}

