static_worker_node_group = {
    monitoring = {
      type       = "sys"
      image      = "Ubuntu 22.04 LTS 64-bit"
      datacenter = "ru-2c"
      count      = 1
      public_ip4 = false
      labels     = [ "worker-group=monitoring",
                     "worker-group-type=system"
      ]
      taints     = [
        {
          key    = "worker-group",
          value  = "monitoring",
          effect = "NoSchedule"
        }]
    }
    logging = {
      type       = "sys"
      image      = "Ubuntu 22.04 LTS 64-bit"
      datacenter = "ru-2c"
      count      = 1
      public_ip4 = false
      labels     = [ "worker-group=logging",
                     "worker-group-type=system"
      ]
      taints     = [
        {
          key    = "worker-group",
          value  = "logging",
          effect = "NoSchedule"
        }]
    }
    worker = {
      type       = "worker"
      image      = "Ubuntu 22.04 LTS 64-bit"
      datacenter = "ru-2c"
      count      = 1
      public_ip4 = false
      labels     = [ "worker-group=worker",
                     "worker-group-type=payload"
      ]
      taints     = []
    }
  }