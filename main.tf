resource "google_compute_instance" "web" {
  name         = "webserver"
  machine_type = "e2-standard-4"
  zone         = "us-central1-a"
  tags         = ["http-server"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  metadata_startup_script = templatefile("./script.sh", { google_creds = file(var.serviceaccount) })

  scheduling {
    preemptible       = true
    automatic_restart = false
  }

  network_interface {
    network = "default"
    access_config {

    }

  }
}
