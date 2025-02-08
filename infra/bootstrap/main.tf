# Настройки приватной сети проекта для нод control plane
resource "openstack_networking_network_v2" "project_private_net" {
  name           = local.project
  admin_state_up = "true"
  depends_on = [
    selectel_vpc_project_v2.project_otus,
    selectel_iam_serviceuser_v1.project_otus
  ]
}
resource "openstack_networking_subnet_v2" "project_private_subnet" {
  name       = local.project
  network_id = openstack_networking_network_v2.project_private_net.id
  cidr       = "192.168.192.0/20"
  ip_version = 4
  depends_on = [
    selectel_vpc_project_v2.project_otus,
    selectel_iam_serviceuser_v1.project_otus
  ]
}

# настройка облачного роутера с подключением к публичной сети
data "openstack_networking_network_v2" "project_public_net" {
  external = true
  depends_on = [
    selectel_vpc_project_v2.project_otus,
    selectel_iam_serviceuser_v1.project_otus
  ]
}
resource "openstack_networking_router_v2" "project_router" {
  name                = "${local.project}-router"
  external_network_id = data.openstack_networking_network_v2.project_public_net.id
  depends_on = [
    selectel_vpc_project_v2.project_otus,
    selectel_iam_serviceuser_v1.project_otus
  ]
}
resource "openstack_networking_router_interface_v2" "project_router_interface" {
  router_id = openstack_networking_router_v2.project_router.id
  subnet_id = openstack_networking_subnet_v2.project_private_subnet.id
  depends_on = [
    selectel_vpc_project_v2.project_otus,
    selectel_iam_serviceuser_v1.project_otus
  ]
}
resource "openstack_networking_port_v2" "node_port" {
  for_each = { for node in local.system_node_list : node.name => node.group }
  name       = each.key
  network_id = openstack_networking_network_v2.project_private_net.id

  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.project_private_subnet.id
  }
  depends_on = [
    selectel_vpc_project_v2.project_otus,
    selectel_iam_serviceuser_v1.project_otus
  ]
}
# настройки безопасности: конфигурация для предварительной настройки
# resource "openstack_networking_secgroup_v2" "configure" {
#   name        = "configure"
#   description = "To configure virtual servers"
# }
# resource "openstack_networking_secgroup_rule_v2" "allow_ssh"  {
#   direction         = "ingress"
#   ethertype         = "IPv4"
#   protocol          = "tcp"
#   port_range_min    = 22
#   port_range_max    = 22
#   remote_ip_prefix  = "0.0.0.0/0"
#   security_group_id = openstack_networking_secgroup_v2.configure.id
# }

# Настройки виртуального сервера
resource "openstack_compute_flavor_v2" "project_flavors" {
  for_each = var.flavor
  name      = format("%s-%s-flavor-%s",local.project,each.key,random_string.flavor_suffix.result)
  vcpus     = each.value.vcpus
  ram       = each.value.ram
  disk      = each.value.disk
  swap      = each.value.swap
  is_public = false
  # lifecycle {
  #   create_before_destroy = true
  # }
  depends_on = [
    selectel_vpc_project_v2.project_otus,
    selectel_iam_serviceuser_v1.project_otus
  ]
}
data "openstack_images_image_v2" "system_images" {
  for_each = var.system_node_group
  name        = each.value.image
  most_recent = true
  visibility  = "public"
  depends_on = [
    selectel_vpc_project_v2.project_otus,
    selectel_iam_serviceuser_v1.project_otus
  ]
}
data "openstack_images_image_v2" "worker_images" {
  for_each = var.worker_node_group
  name        = each.value.image
  most_recent = true
  visibility  = "public"
  depends_on = [
    selectel_vpc_project_v2.project_otus,
    selectel_iam_serviceuser_v1.project_otus
  ]
}
# resource "openstack_blockstorage_volume_v3" "boot" {
#   for_each = { for node in local.node_list : node.name => node.group if var.flavor[var.system_node_group[node.group].type].is_ephemeral != true }
#   name                 = format("%s-boot",each.key)
#   size                 = tostring(var.flavor[var.system_node_group[each.value].type].disk)
#   image_id             = data.openstack_images_image_v2.project_images[each.value].id
#   volume_type          = format("universal.%s",var.system_node_group[each.value].datacenter)
#   availability_zone    = var.system_node_group[each.value].datacenter
#   enable_online_resize = true
#
#   lifecycle {
#     ignore_changes = [image_id]
#   }
#   depends_on = [
#     selectel_vpc_project_v2.project_otus,
#     selectel_iam_serviceuser_v1.project_otus
#   ]
# }
resource "openstack_compute_instance_v2" "node" {
  for_each = { for node in local.system_node_list : node.name => node.group }
  depends_on = [
    #openstack_blockstorage_volume_v3.boot,
    openstack_networking_port_v2.node_port
  ]
  name              = each.key
  flavor_id         = openstack_compute_flavor_v2.project_flavors[var.system_node_group[each.value].type].id
  image_id          = data.openstack_images_image_v2.system_images[each.value].id
  key_pair          = selectel_vpc_keypair_v2.otus_project_sshkey.name
  availability_zone = var.system_node_group[each.value].datacenter

  network {
    port = openstack_networking_port_v2.node_port[each.key].id
  }

  lifecycle {
    ignore_changes = [image_id]
  }

  # block_device {
  #   uuid             = openstack_blockstorage_volume_v3.boot[each.key].id
  #   source_type      = "volume"
  #   destination_type = "volume"
  #   boot_index       = 0
  # }

  vendor_options {
    ignore_resize_confirmation = true
  }
}

# подключение сервера к публичной сети
resource "openstack_networking_floatingip_v2" "node_ext_ip" {
  for_each = { for node in local.system_node_list : node.name => node.group if var.system_node_group[node.group].public_ip4 }
  pool = "external-network"
  description = each.key
  region = var.sel_project_region
}
resource "openstack_networking_floatingip_associate_v2" "node" {
  for_each = { for node in local.system_node_list : node.name => node.group  if var.system_node_group[node.group].public_ip4 }
  port_id     = openstack_networking_port_v2.node_port[each.key].id
  floating_ip = openstack_networking_floatingip_v2.node_ext_ip[each.key].address
}
# output "public_ip_address" {
#   value = openstack_networking_floatingip_v2.node_ext_ip[*] #.address
# }
