variable "cidr_block" { type = string }
variable "name_prefix" { type = string }
variable "region" { type = string }
variable "create_internet_gateway" {
  type        = bool
  description = "Whether to create and attach an IGW (true for public workloads)"
  default     = true
}

