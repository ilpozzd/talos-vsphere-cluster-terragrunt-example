include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "github.com/ilpozzd/terraform-talos-vsphere-cluster?version=1.0.0"
}

dependency "kubernetes-cluster-secrets" {
  config_path = "${get_parent_terragrunt_dir()}/infrastructure/_global_data/kubernetes-cluster-secrets/"
}

inputs = {
  datacenter = "Office_Datacenter"

  datastores = [
    "Office_Datastore-1",
    "Office_Datastore-2",
    "Office_Datastore-3"
  ]

  hosts = [
    "office-host-1.company.local",
    "office-host-2.company.local",
    "office-host-3.company.local",
    "office-host-4.company.local"
  ]

  resource_pool  = "Kubernetes_Cluster"
  folder         = "Office/Kubernetes_Cluster"
  remote_ovf_url = "https://github.com/siderolabs/talos/releases/download/v1.0.4/vmware-amd64.ova"

  control_plane_count    = 1
  control_plane_num_cpus = 2
  control_plane_memory   = 2048
  
  control_plane_disks = [
    {
      label = "sda"
      size  = 20
    }
  ]

  control_plane_network_interfaces = [
    {
      name = "192_168_10_0"
    }
  ]


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

  control_plane_machine_network_interfaces = [
    [
      {
        interface = "eth0"
        addresses = [
          "192.168.10.10/24"
        ]
        routes = [
          {
            network = "0.0.0.0/0"
            gateway = "192.168.10.1"
          }
        ]
      }
    ]
  ]

  machine_secrets               = dependency.kubernetes-cluster-secrets.outputs.machine_secrets
  talos_admin_pki               = dependency.kubernetes-cluster-secrets.outputs.talos_admin_pki
  cluster_secrets               = dependency.kubernetes-cluster-secrets.outputs.cluster_secrets
  kubernetes_admin_pki          = dependency.kubernetes-cluster-secrets.outputs.kubernetes_admin_pki
  control_plane_cluster_secrets = dependency.kubernetes-cluster-secrets.outputs.control_plane_cluster_secrets

  cluster_name      = "kubernetes-cluster"
  kubeconfig_path   = "./configs/kubeconfig"
  talosconfig_path  = "./configs/talosconfig"
}