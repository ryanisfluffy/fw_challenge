variable "ami_id" {
    description = "the AMI ID of the Amazon Machine Image you wish to base your EC2 instance on. Defaults to an Amazon Linux amd64 ami"
    type        = string
    default     = "ami-0f5094faf16f004eb"
}

variable "instance_type" {
    description = "The size of the EC2 you wish to run your app on"
    type        = string
    default     = "t2.micro"
}

variable "app_name" {
    description = "Name of the Application as represented in AWS"
    type        = string
    default     = "rustpad"
}

variable "region" {
    description = "Which AWS Region to run against"
    type        = string
    default     = "eu-west-3"
}