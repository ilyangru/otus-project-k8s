/*
Copyright 2019 The KubeOne Authors.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

output "kubeone_api" {
  description = "kube-apiserver LB endpoint"

  value = {
    endpoint                    = openstack_networking_floatingip_v2.kube_apiserver.address
    apiserver_alternative_names = []
  }
}

output "ssh_commands" {
  value = formatlist(
    "ssh -J ${local.bastion_user}@${openstack_networking_floatingip_v2.node_ext_ip["k8s-project-bastion-1"].address} ${local.ssh_username}@%s",
    [ for name,node in openstack_compute_instance_v2.node : node.access_ip_v4 if strcontains(name,"control-plane") ]
  )
}

output "kubeone_hosts" {
  description = "Control plane endpoints to SSH to"

  value = {
    control_plane = {
      cluster_name         = local.project
      cloud_provider       = "openstack"
      #untaint              = true
      private_address      = [ for name,node in openstack_compute_instance_v2.node : node.access_ip_v4 if strcontains(name,"control-plane") ]
      hostnames            = [ for name,node in openstack_compute_instance_v2.node : node.name if strcontains(name,"control-plane") ]
      ssh_agent_socket     = "" #"env:SSH_AUTH_SOCK"
      ssh_port             = 22
      ssh_private_key_file = "${path.cwd}/${local_sensitive_file.sshkey.filename}"
      ssh_user             = local.ssh_username
      bastion              = openstack_networking_floatingip_v2.node_ext_ip["k8s-project-bastion-1"].address
      bastion_port         = 22
      bastion_user         = local.bastion_user
      ssh_hosts_keys       = null
      bastion_host_key     = null
    }
  }
}
output "kubeone_static_workers" {
  description = "Static workers config"
  # value = {
  #   workers = {
  #     private_address      = [ for cur_worker in openstack_compute_instance_v2.static_worker: cur_worker.access_ip_v4 ] #flatten([ for cur_port in openstack_networking_port_v2.static_node_port: [for cur_ipset in cur_port: cur_ipset] ])
  #     hostnames            = [ for cur_worker in openstack_compute_instance_v2.static_worker: cur_worker.name ]
  #     ssh_agent_socket     = ""
  #     ssh_port             = 22
  #     ssh_private_key_file = "${path.cwd}/${local_sensitive_file.sshkey.filename}"
  #     ssh_user             = local.ssh_username
  #     bastion              = openstack_networking_floatingip_v2.node_ext_ip["k8s-project-bastion-1"].address
  #     bastion_port         = 22
  #     bastion_user         = local.bastion_user
  #     bastion_host_key     = null
  #     labels               = {}
  #   }
  # }
  value = {
    for group_name, group_val in var.static_worker_node_group:
      group_name => {
      private_address      = [ for cur_worker in openstack_compute_instance_v2.static_worker: cur_worker.access_ip_v4 if strcontains(cur_worker.name,group_name) ]
      hostnames            = [ for cur_worker in openstack_compute_instance_v2.static_worker: cur_worker.name if strcontains(cur_worker.name,group_name) ]
      ssh_agent_socket     = ""
      ssh_port             = 22
      ssh_private_key_file = "${path.cwd}/${local_sensitive_file.sshkey.filename}"
      ssh_user             = local.ssh_username
      bastion              = openstack_networking_floatingip_v2.node_ext_ip["k8s-project-bastion-1"].address
      bastion_port         = 22
      bastion_user         = local.bastion_user
      bastion_host_key     = null
      labels               = { for cur_label in group_val.labels: split("=",cur_label)[0] => split("=",cur_label)[1] if length(split("=",cur_label))==2 }
      }
  }
}

# output "kubeone_workers" {
#   description = "Workers definitions, that will be transformed into MachineDeployment object"
#
#   value = {
#     # following outputs will be parsed by kubeone and automatically merged into
#     # corresponding (by name) worker definition
#     "${local.project}-monitoring" = {
#       replicas = var.worker_node_group["monitoring"].count
#       providerSpec = {
#         sshPublicKeys   = [tls_private_key.project_ssh_key.public_key_openssh]
#         operatingSystem = "ubuntu"
#         operatingSystemSpec = {
#           distUpgradeOnBoot = true
#           disableAutoUpdate = false
#           disableLocksmithD = false
#         }
#         cloudProviderSpec = {
#           #region = var.sel_project_region
#           image = "${var.worker_node_group["monitoring"].image}"
#           flavor = openstack_compute_flavor_v2.project_flavors[var.worker_node_group["monitoring"].type].name
#           #securityGroups = []
#           #network        = openstack_networking_network_v2.project_private_net.name
#           #subnet         = openstack_networking_subnet_v2.project_private_subnet.name
#           availabilityZone = var.worker_node_group["monitoring"].datacenter
#         }
#       }
#     }
#   }
# }

# DEFAULT DEMO CONFIG FOR DYNAMIC WORKERS
# output "kubeone_workers" {
#   description = "Workers definitions, that will be transformed into MachineDeployment object"
#
#   value = {
#     # following outputs will be parsed by kubeone and automatically merged into
#     # corresponding (by name) worker definition
#     "${var.cluster_name}-pool1" = {
#       replicas = var.initial_machinedeployment_replicas
#       providerSpec = {
#         annotations = {
#           "k8c.io/operating-system-profile"                           = var.initial_machinedeployment_operating_system_profile
#           "cluster.k8s.io/cluster-api-autoscaler-node-group-min-size" = tostring(local.cluster_autoscaler_min_replicas)
#           "cluster.k8s.io/cluster-api-autoscaler-node-group-max-size" = tostring(local.cluster_autoscaler_max_replicas)
#         }
#         sshPublicKeys   = [file(var.ssh_public_key_file)]
#         operatingSystem = var.worker_os
#         operatingSystemSpec = {
#           distUpgradeOnBoot = false
#           disableAutoUpdate = var.disable_auto_update
#           disableLocksmithD = var.disable_auto_update
#         }
#         # nodeAnnotations are applied on resulting Node objects
#         # nodeAnnotations = {
#         #   "key" = "value"
#         # }
#         # machineObjectAnnotations are applied on resulting Machine objects
#         # uncomment to following to set those kubelet parameters. More into at:
#         # https://kubernetes.io/docs/tasks/administer-cluster/reserve-compute-resources/
#         # machineObjectAnnotations = {
#         #   "v1.kubelet-config.machine-controller.kubermatic.io/SystemReserved" = "cpu=200m,memory=200Mi"
#         #   "v1.kubelet-config.machine-controller.kubermatic.io/KubeReserved"   = "cpu=200m,memory=300Mi"
#         #   "v1.kubelet-config.machine-controller.kubermatic.io/EvictionHard"   = ""
#         #   "v1.kubelet-config.machine-controller.kubermatic.io/MaxPods"        = "110"
#         # }
#         cloudProviderSpec = {
#           # provider specific fields:
#           # see example under `cloudProviderSpec` section at:
#           # https://github.com/kubermatic/machine-controller/blob/main/examples/openstack-machinedeployment.yaml
#           image          = data.openstack_images_image_v2.image.name
#           flavor         = var.worker_flavor
#           securityGroups = [openstack_networking_secgroup_v2.securitygroup.name]
#           network        = openstack_networking_network_v2.network.name
#           subnet         = openstack_networking_subnet_v2.subnet.name
#           configDrive    = var.config_drive
#           # floatingIpPool = var.external_network_name
#           # Optional: If set, the rootDisk will be a volume.
#           # Otherwise, the rootDisk will be on ephemeral storage and its size will
#           # be derived from the flavor
#           # rootDiskSizeGB = 50
#           # Optional: limit how many volumes can be attached to a node
#           # nodeVolumeAttachLimit = 25
#           tags = {
#             "${var.cluster_name}-workers" = "pool1"
#           }
#         }
#       }
#     }
#   }
# }
