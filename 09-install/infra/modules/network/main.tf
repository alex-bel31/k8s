resource "yandex_vpc_network" "network" {
  name = "${var.env_name}-vpc"
}

resource "yandex_vpc_gateway" "nat" {
  name      = "${var.env_name}-nat-gateway"
  folder_id = var.folder_id
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "private" {
  name       = "${var.env_name}-private-rt"
  folder_id  = var.folder_id
  network_id = yandex_vpc_network.network.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat.id
  }
}

resource "yandex_vpc_subnet" "subnet" {
  for_each = { for idx, s in var.subnets : idx => s }
  name           = "${var.env_name}-${each.key}"
  zone           = each.value.zone
  v4_cidr_blocks = [each.value.cidr]
  network_id     = yandex_vpc_network.network.id

  route_table_id = each.value.is_public ? null : yandex_vpc_route_table.private.id
}