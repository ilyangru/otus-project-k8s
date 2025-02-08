resource "openstack_lb_loadbalancer_v2" "kube_apiserver" {
  name               = "${local.project}-kube-apiserver"
  admin_state_up     = true
  #security_group_ids = [openstack_networking_secgroup_v2.securitygroup.id]
  vip_network_id     = openstack_networking_network_v2.project_private_net.id
  vip_subnet_id      = openstack_networking_subnet_v2.project_private_subnet.id
}

resource "openstack_lb_pool_v2" "kube_apiservers" {
  name            = "${local.project}-kube-apiservers"
  protocol        = "TCP"
  lb_method       = "ROUND_ROBIN"
  loadbalancer_id = openstack_lb_loadbalancer_v2.kube_apiserver.id
}

resource "openstack_lb_listener_v2" "kube_apiserver" {
  name            = "${local.project}-kube-apiserver"
  protocol        = "TCP"
  protocol_port   = 6443
  admin_state_up  = true
  default_pool_id = openstack_lb_pool_v2.kube_apiservers.id
  loadbalancer_id = openstack_lb_loadbalancer_v2.kube_apiserver.id
}

resource "openstack_lb_monitor_v2" "lb_monitor_tcp" {
  name        = "${local.project}-kube-apiserver"
  pool_id     = openstack_lb_pool_v2.kube_apiservers.id
  type        = "TCP"
  delay       = 30
  timeout     = 10
  max_retries = 5
}

resource "openstack_lb_member_v2" "kube_apiserver" {
  for_each = { for node in local.system_node_list : node.name => node.group if node.group == "control-plane"}
  # count         = length(openstack_compute_instance_v2.control_plane)
  name          = "${local.project}-kube_apiserver-${each.key}"
  pool_id       = openstack_lb_pool_v2.kube_apiservers.id
  address       = openstack_compute_instance_v2.node[each.key].access_ip_v4
  protocol_port = 6443
}

resource "openstack_networking_floatingip_v2" "kube_apiserver" {
  pool = "external-network"
}

resource "openstack_networking_floatingip_associate_v2" "kube_apiserver" {
  floating_ip = openstack_networking_floatingip_v2.kube_apiserver.address
  port_id     = openstack_lb_loadbalancer_v2.kube_apiserver.vip_port_id
}
