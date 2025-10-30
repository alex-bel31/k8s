variable "folder_id" {
  type        = string
  description = "Folder ID"
  sensitive = true
}

variable "env_name" {
  description = "Network name"
  type        = string
}


variable "subnets" {
  description = "Location area and CIDR block for subnetwork"
  type = map(object({
    zone      = string
    cidr      = string
    is_public = bool
    role      = string  # "bastion", "master", "worker"
  }))
}