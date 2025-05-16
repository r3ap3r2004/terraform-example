variable "ami_id" { type = string }
variable "instance_type" { type = string }
variable "subnet_id" { type = string }
variable "sg_ids" { type = list(string) }
variable "name_prefix" { type = string }
variable "role" { type = string }
variable "user_data" { type = string }
variable "key_name" {
  description = "Name of the AWS key pair to attach to the instance"
  type        = string
  default     = null    # keep optional for AMIs that forbid SSH
}
