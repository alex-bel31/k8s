variable "env_name" {
  description = "Network name"
  type        = string
}

variable "cloud_id" {
  type        = string
  description = "Cloud ID"
  sensitive   = true
}

variable "folder_id" {
  type        = string
  description = "Folder ID"
  sensitive   = true
}

variable "default_zone" {
  type        = string
  description = "Default zone"
  sensitive   = true
}

variable "ssh_username" {
  description = "SSH username"
  type        = string
  sensitive   = true
}

variable "ssh_private_key" {
  type = string
}

variable "subnets" {
  type = map(object({
    zone      = string
    cidr      = string
    is_public = bool
    role      = string
  }))
}

variable "security_group_ingress_bastion" {
  description = "secrules ingress"
  type = list(object(
    {
      protocol          = string
      description       = string
      v4_cidr_blocks    = optional(list(string))
      port              = optional(number)
      from_port         = optional(number)
      to_port           = optional(number)
      security_group_id = optional(string)
  }))
  default = [
    {
      protocol       = "TCP"
      description    = "SSH доступ с рабочего IP"
      v4_cidr_blocks = ["0.0.0.0/0"]
      port           = 22
    }
  ]
}

variable "security_group_egress_bastion" {
  description = "secrules egress"
  type = list(object(
    {
      protocol          = string
      description       = string
      v4_cidr_blocks    = optional(list(string))
      port              = optional(number)
      from_port         = optional(number)
      to_port           = optional(number)
      security_group_id = optional(string)
  }))
  default = [
    {
      protocol       = "TCP"
      description    = "разрешить весь исходящий трафик"
      v4_cidr_blocks = ["0.0.0.0/0"]
      from_port      = 0
      to_port        = 65365
    }
  ]
}

variable "security_group_ingress_nodes" {
  description = "secrules ingress"
  type = list(object(
    {
      protocol          = string
      description       = string
      v4_cidr_blocks    = optional(list(string))
      port              = optional(number)
      from_port         = optional(number)
      to_port           = optional(number)
      security_group_id = optional(string)
  }))
  default = [
    {
      protocol       = "TCP"
      description    = "Kubernetes API и node communication"
      v4_cidr_blocks = ["10.0.0.0/8"]
      from_port      = 10250
      to_port        = 65535
    }
  ]
}


variable "security_group_egress_nodes" {
  description = "secrules egress"
  type = list(object(
    {
      protocol          = string
      description       = string
      v4_cidr_blocks    = optional(list(string))
      port              = optional(number)
      from_port         = optional(number)
      to_port           = optional(number)
      security_group_id = optional(string)
  }))
  default = [
    {
      protocol       = "TCP"
      description    = "Разрешить исходящий трафик"
      v4_cidr_blocks = ["0.0.0.0/0"]
      from_port      = 0
      to_port        = 65535
    }
  ]
}

