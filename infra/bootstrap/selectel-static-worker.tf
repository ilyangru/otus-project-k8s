# подготовка портов для подключения Static Workers
resource "openstack_networking_port_v2" "static_node_port" {
  for_each = { for node in local.static_worker_node_list : node.name => node.group }
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
# Образы для Static Workers
data "openstack_images_image_v2" "static_workers_images" {
  for_each = var.static_worker_node_group
  name        = each.value.image
  most_recent = true
  visibility  = "public"
  depends_on = [
    selectel_vpc_project_v2.project_otus,
    selectel_iam_serviceuser_v1.project_otus
  ]
}
# Создание нод Static Workers
resource "openstack_compute_instance_v2" "static_worker" {
  for_each = { for node in local.static_worker_node_list : node.name => node.group }
  depends_on = [
    openstack_networking_port_v2.static_node_port
  ]
  name              = each.key
  flavor_id         = openstack_compute_flavor_v2.project_flavors[var.static_worker_node_group[each.value].type].id
  image_id          = data.openstack_images_image_v2.static_workers_images[each.value].id
  key_pair          = selectel_vpc_keypair_v2.otus_project_sshkey.name
  availability_zone = var.static_worker_node_group[each.value].datacenter
  network {
    port = openstack_networking_port_v2.static_node_port[each.key].id
  }
  tags = var.static_worker_node_group[each.value].labels
  lifecycle {
    ignore_changes = [image_id]
  }
  vendor_options {
    ignore_resize_confirmation = true
  }
}
