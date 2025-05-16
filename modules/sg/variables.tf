variable "name_prefix" { type = string }
variable "role"        { type = string }
variable "vpc_id"      { type = string }

variable "ingress" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = []
}

variable "sg_ingress" {
  type = list(object({
    from_port = number
    to_port   = number
    protocol  = string
    source_sg = string
  }))
  default = []
}

variable "egress" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = []
}

variable "sg_egress" {
  type = list(object({
    from_port = number
    to_port   = number
    protocol  = string
    source_sg = string
  }))
  default = []
}