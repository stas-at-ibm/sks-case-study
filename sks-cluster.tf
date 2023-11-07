locals {
  zone   = "de-fra-1"
  labels = { "project" : "exoscale_sks_case_study_1" }
}

# This resource will create the control plane
# Since we're going for the fully managed option, we will ask sks to preinstall
# the calico network plugin and the exoscale-cloud-controller
resource "exoscale_sks_cluster" "sj_sks_cluster" {
  zone           = local.zone
  name           = "sj_sks_cluster"
  version        = "1.22.3"
  description    = "Case Study 1"
  service_level  = "pro"
  cni            = "calico"
  exoscale_ccm   = true
  metrics_server = true
  auto_upgrade   = true
  labels         = local.labels
}

resource "exoscale_sks_nodepool" "sj_workers" {
  zone               = local.zone
  cluster_id         = exoscale_sks_cluster.sj_sks_cluster.id
  name               = "sj_workers"
  instance_type      = "standard.medium"
  size               = 1
  security_group_ids = [exoscale_security_group.sj_sks_nodes.id]
  labels             = local.labels
}

resource "exoscale_security_group" "sj_sks_nodes" {
  name        = "sks_nodes"
  description = "Allows traffic between sks nodes and public pulling of logs"
}

resource "exoscale_security_group_rule" "sks_nodes_logs_rule" {
  security_group_id = exoscale_security_group.sj_sks_nodes.id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0"
  start_port        = 10250
  end_port          = 10250
}

resource "exoscale_security_group_rule" "sj_sks_nodes_calico" {
  security_group_id      = exoscale_security_group.sj_sks_nodes.id
  type                   = "INGRESS"
  protocol               = "UDP"
  start_port             = 4789
  end_port               = 4789
  user_security_group_id = exoscale_security_group.sj_sks_nodes.id
}

resource "exoscale_security_group_rule" "sj_sks_nodes_ccm" {
  security_group_id = exoscale_security_group.sj_sks_nodes.id
  type              = "INGRESS"
  protocol          = "TCP"
  start_port        = 30000
  end_port          = 32767
  cidr              = "0.0.0.0/0"
}

output "kubectl_command" {
  value = "exo compute sks kubeconfig ${exoscale_sks_cluster.sj_sks_cluster.id} user -z ${local.zone} --group system:masters"
}
