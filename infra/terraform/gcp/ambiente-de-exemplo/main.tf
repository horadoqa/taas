module "provider" {
  source = "../../../"
}
resource "google_compute_instance" "gce_k6" {
  count        = var.number_instances
  project      = var.project_id
  name         = "gce-${var.name_prefix}-${count.index}-${var.environment}"
  tags         = [var.environment]
  machine_type = var.machine_type
  zone         = var.zone

  labels = {
    "system" = var.system_label
    "env"    = var.environment
  }

  scheduling {
    provisioning_model = var.provisioning_model
    preemptible        = var.preemptible
    automatic_restart  = var.automatic_restart
  }

  metadata_startup_script = "echo \"sshd:   10.86.7.        #Redes Gitlab runners GCP\" >> /etc/hosts.allow"
  boot_disk {
    initialize_params {
      image = var.source_image
      size  = var.disk_size
    }
  }

  network_interface {
    subnetwork = var.subnetwork
    ###access_config {
    ###network_tier = "PREMIUM"
    ###}
  }

  service_account {
    email  = var.service_account
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_instance" "gce_prometheus" {
  project      = var.project_id
  name         = "gce-prometheus-${var.environment}"
  tags         = [var.environment, "prometheus"]
  machine_type = var.machine_type
  zone         = var.zone

  labels = {
    "system" = "prometheus"
    "env"    = var.environment
  }

  scheduling {
    provisioning_model = var.provisioning_model
    preemptible        = var.preemptible
    automatic_restart  = var.automatic_restart
  }

  metadata_startup_script = "echo \"sshd:   10.86.7.        #Redes Gitlab runners GCP\" >> /etc/hosts.allow"
  boot_disk {
    initialize_params {
      image = var.source_image
      size  = var.disk_size
    }
  }

  network_interface {
    subnetwork = var.subnetwork
  }

  service_account {
    email  = var.service_account
    scopes = ["cloud-platform"]
  }
}