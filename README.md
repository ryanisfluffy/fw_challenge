# Technical Challenge

This technical challenge consist of Terraform scripts to provision an EC2 instance running the [RustPad](https://github.com/ekzhang/rustpad) application in a docker container with a single command from the user.

## Approach

I decided to use Terraform to complete this challenge for a few reasons:
  - I've had prior experience using Terraform (v0.9)
  - It is well supported/documented
  - It's fairly easy to develop/debug quickly
  - Fairly low bar to entry vs other methods/frameworks

## Assumptions

The assumptions I made include: 
  - The EC2 instance only runs the docker app
  - SSH access is desired
  - Minimal prerequisites desired

## Prerequisites

[Terraform](https://terraform.io) must be installed, as well as having [AWS Credentials configured for Terraform](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#environment-variables) before running this script.

## Components


### VPC, Public Subnet, Route Table, Internet Gateway
These resources create the backbone for the app to allow communication outside of the AWS network

### EC2 Instance

The application runs on a `t2-micro` instance by default, within the default vpc.

### Security Group/Rules

A Security group is created and associated with the EC2 instance to limit ingress traffic to ports 22 (ssh) and 3030 (RustPad), and allows Egress traffic anywhere from the application

### TLS Private Key (pem), Key Pair, local-exec
A private key is generated, and then used to initalize an AWS Key pair which is then associated with the EC2 instance to allow ssh access into the EC2 instance. A local copy of the pem is also generated, which the convenience `./setup.sh` script applies the correct permissions to (400).

## Running the Application

A convenience script for running the application has been provided at `./setup.sh`. Running this script will initialize Terraform, apply the infrastructure required for the application, and then will print out the URL for the RustPad application after waiting for it to initialize. A keypair and pem file are also generated for convenience in connecting to the EC2 instance via ssh. The output from running `./setup.sh` will look something like:
```bash
Waiting for the RustPad Service to come online...
Waiting for the RustPad Service to come online...
Resources successfully provisioned. You can connect to the RustPad service by visiting
http://ec2-18-212-73-10.compute-1.amazonaws.com:3030 in your browser
You can also connect to your instance via ssh by running ssh -i generated-key-pair.pem ec2-user@ec2-18-212-73-10.compute-1.amazonaws.com
```

## Cleaning up

To clean up the application, you can run `./cleanup.sh` to delete the infrastructure provisioned by Terraform, as well as deleting the `generated-key-pair.pem` file.