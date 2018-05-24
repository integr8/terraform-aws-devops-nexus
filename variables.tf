variable "availability-zones" {
  type = "list"
}

variable "vpc-id" {}

variable "subnets" {
  type = "list"
}

variable "cluster-name" {
  default = "nexus-cluster"
}

variable "bucket-name-prefix" {
  default = "nexus-config-"
}

variable "ami" {
  default = "ami-aff65ad2"
}

variable "instance-type" {
  default = "t2.medium"
}
