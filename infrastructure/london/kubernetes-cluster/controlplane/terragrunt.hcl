include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "github.com/ilpozzd/terraform-talos-vsphere-vm?version=1.0.0"
}

dependency "kubernetes-cluster-secrets" {
  config_path = "${get_parent_terragrunt_dir()}/infrastructure/_global_data/kubernetes-cluster-secrets/"
}

dependency "kubernetes-cluster" {
  config_path = "${get_parent_terragrunt_dir()}/infrastructure/local/kubernetes-cluster/"
}

inputs = {
  datacenter = "London_Datacenter"

  datastores = [
    "London_Datastore-1"
  ]

  hosts = [
    "london-host-1.company.local"
  ]

  resource_pool  = "Kubernetes_Cluster"
  folder         = "London/Kubernetes_Cluster"
  remote_ovf_url = "https://github.com/siderolabs/talos/releases/download/v1.0.4/vmware-amd64.ova"

  vm_count = 1
  num_cpus = 2
  memory   = 2048
  
  disks = [
    {
      label = "sda"
      size  = 20
    }
  ]

  network_interfaces = [
    {
      name = "172_16_10_0"
    }
  ]

  machine_type = "controlplane"

  machine_base_configuration = {
    install = {
      disk       = "/dev/sda"
      image      = "ghcr.io/siderolabs/installer:latest"
      bootloader = true
      wipe       = false
    }
    time = {
      disabled = false
      servers = [
        "ntp.company.local"
      ]
      bootTimeout = "2m0s"
    }
    features = {
      rbac = true
    }
  }

  machine_network = {
    nameservers = [
      "192.168.1.10",
      "192.168.1.11"
    ]
  }

  machine_network_interfaces = [
    [
      {
        interface = "eth0"
        addresses = [
          "172.16.10.10/24"
        ]
        routes = [
          {
            network = "0.0.0.0/0"
            gateway = "172.16.10.1"
          }
        ]
      }
    ]
  ]

  machine_secrets               = dependency.kubernetes-cluster-secrets.outputs.machine_secrets
  cluster_secrets               = dependency.kubernetes-cluster-secrets.outputs.cluster_secrets
  control_plane_cluster_secrets = dependency.kubernetes-cluster-secrets.outputs.control_plane_cluster_secrets

  cluster_name          = "kubernetes-cluster"
  cluster_control_plane = {
    endpoint = dependency.kubernetes-cluster.outputs.cluster_endpoint
  }
}