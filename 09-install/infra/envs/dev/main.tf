module "network" {
  source    = "../../modules/network"
  folder_id = var.folder_id
  env_name  = "dev"
  subnets   = var.subnets
}

module "sg_bastion" {
  source     = "../../modules/sg"
  name       = "bastion-sg"
  folder_id  = var.folder_id
  network_id = module.network.network_id

  security_group_ingress = var.security_group_ingress_bastion
  security_group_egress  = var.security_group_egress_bastion
}

module "sg_nodes" {
  source     = "../../modules/sg"
  name       = "nodes-sg"
  folder_id  = var.folder_id
  network_id = module.network.network_id

  security_group_ingress = [
    {
      protocol          = "TCP"
      description       = "SSH только с бастиона"
      security_group_id = module.sg_bastion.security_group_id
      port              = 22
    },
    {
      protocol       = "TCP"
      description    = "Kubernetes API и node communication"
      v4_cidr_blocks = ["10.0.0.0/8"]
      from_port      = 10250
      to_port        = 65535
    },
      {
    protocol       = "TCP"
    description    = "etcd client communication"
    v4_cidr_blocks = ["10.0.0.0/8"]
    from_port      = 2379
    to_port        = 2379
  },
  {
    protocol       = "TCP"
    description    = "etcd peer communication"
    v4_cidr_blocks = ["10.0.0.0/8"]
    from_port      = 2380
    to_port        = 2380
  },
  {
    protocol       = "TCP"
    description    = "Kubernetes API server"
    v4_cidr_blocks = ["10.0.0.0/8"]
    from_port      = 6443
    to_port        = 6443
  }
  ]
  security_group_egress = var.security_group_egress_nodes
}

module "k8s_master" {
  source                 = "../../modules/vms"
  env_name               = "dev"
  network_id             = module.network.network_id
  subnet_ids             = [for s in module.network.subnet_info : s.id if s.role == "master"]
  subnet_zones           = [for s in module.network.subnet_info : s.zone if s.role == "master"]
  instance_name          = "master"
  instance_count         = 3
  image_family           = "ubuntu-2204-lts"
  public_ip              = false
  platform               = "standard-v3"
  instance_core_fraction = 20
  security_group_ids     = [module.sg_nodes.security_group_id]
  instance_memory        = 4
  instance_cores = 2

  metadata = {
    user-data = templatefile("${path.root}/../../templates/cloud-init.tpl", {
      ssh_public_key = file("~/.ssh/yavm.pub")
      user           = var.ssh_username
    })
  }
}

module "k8s_worker" {
  source                 = "../../modules/vms"
  env_name               = "dev"
  network_id             = module.network.network_id
  subnet_ids             = [for s in module.network.subnet_info : s.id if s.role == "worker"]
  subnet_zones           = [for s in module.network.subnet_info : s.zone if s.role == "worker"]
  instance_name          = "worker"
  instance_count         = 1
  image_family           = "ubuntu-2204-lts"
  public_ip              = false
  platform               = "standard-v3"
  instance_core_fraction = 20
  security_group_ids     = [module.sg_nodes.security_group_id]
  instance_memory        = 2
  instance_cores = 2

  metadata = {
    user-data = templatefile("${path.root}/../../templates/cloud-init.tpl", {
      ssh_public_key = file("~/.ssh/yavm.pub")
      user           = var.ssh_username
    })
  }
}
module "bastion" {
  source                 = "../../modules/vms"
  env_name               = "dev"
  network_id             = module.network.network_id
  subnet_ids             = [for s in module.network.subnet_info : s.id if s.role == "bastion"]
  subnet_zones           = [for s in module.network.subnet_info : s.zone if s.role == "bastion"]
  instance_name          = "bastion"
  instance_count         = 1
  image_family           = "ubuntu-2204-lts"
  public_ip              = true
  platform               = "standard-v3"
  instance_core_fraction = 20
  security_group_ids     = [module.sg_bastion.security_group_id]

  metadata = {
    user-data = templatefile("${path.root}/../../templates/cloud-init.tpl", {
      ssh_public_key = file("~/.ssh/yavm.pub")
      user           = var.ssh_username
    })
  }
}

resource "local_file" "ansible_inventory" {
  filename = "${path.root}/inventory.ini"
  content = templatefile("${path.root}/../../templates/inventory-kubespray.tftpl", {
    bastion_ip = module.bastion.external_ip_address[0]
    masters    = module.k8s_master.internal_ip_address
    workers    = module.k8s_worker.internal_ip_address
    ssh_user   = var.ssh_username
    ssh_key    = var.ssh_private_key
  })
}