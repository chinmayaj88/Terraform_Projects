# Terraform Projects

Collection of Terraform configurations for spinning up infrastructure on different cloud providers. I use these for deploying workloads, testing setups, and learning how different cloud platforms work.

## What's Here

### OCI Project

Currently have one working project for Oracle Cloud Infrastructure. It sets up:
- VCN (Virtual Cloud Network) 
- Internet Gateway
- Public subnet with routing
- Security lists (SSH, HTTP, HTTPS ports open)
- Ubuntu 22.04 compute instance
- Apache pre-installed via cloud-init

Basically gives you a ready-to-use web server in a few minutes. The instance automatically installs Apache when it boots, so you can SSH in and start deploying your app right away.

There's a detailed README in `oci/tf_proj_1/` that walks through everything step by step.

### AWS

Planning to add AWS projects here soon. The `aws/` folder is currently empty but that's where they'll go when I get around to it.

## Getting Started

Make sure you have Terraform installed first (1.5.0+ should work fine). You can grab it from [terraform.io](https://www.terraform.io/downloads) or use your package manager.

Then:
1. Pick a project folder
2. Read the README in that folder (each one has its own setup instructions)
3. Copy the `.example` files and fill in your actual values
4. Run `terraform init` and `terraform apply`

That's pretty much it. Each project has its own README with more details.

## Before You Start

Quick checklist:
- [ ] Terraform installed (`terraform version` should work)
- [ ] Cloud account set up (OCI, AWS, whatever you're using)
- [ ] API keys configured for your provider
- [ ] SSH key pair generated (you'll need this to access instances)

## Security Stuff

**Don't commit sensitive files!**

The `.gitignore` should catch these, but just in case - never commit:
- `*.tfvars` files (these have your real credentials)
- `*.tfstate` files (contains state info)
- `*.pem` or `*.key` files (private keys)
- Any backup files

Always use the `.example` files as templates. Copy them, rename (remove `.example`), fill in your values, and you're good to go. The actual files with your secrets should never make it into git.

## When to Use This

I mostly use these for:
- Quick dev/test environments
- Learning how different cloud services work
- Setting up reproducible infrastructure
- When I need something up fast without clicking through a bunch of UI forms

You can probably find better production-ready examples elsewhere, but these work well for getting started and personal projects.

## Helpful Links

- [Terraform docs](https://developer.hashicorp.com/terraform/docs) - official docs are pretty good
- [OCI provider docs](https://registry.terraform.io/providers/oracle/oci/latest/docs) - if you're working with OCI
- [AWS provider docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs) - for AWS stuff

## A Few Things I've Learned

1. **Always run `terraform plan` first** - saves you from accidentally destroying things
2. **State files can contain sensitive data** - be careful with them, consider remote state backends for team use
3. **Test in dev before prod** - obvious but easy to forget
4. **Watch your costs** - remember to destroy resources when you're done, cloud bills add up fast
5. **Use `terraform fmt`** - keeps your code readable
6. **`terraform validate`** catches a lot of errors before you apply

## Contributing

If you find bugs or want to add something, feel free to open an issue or PR. These are just my personal projects but I'm happy to improve them if others find them useful.

---

That's about it. Check out the individual project folders for more specific instructions. Good luck!

