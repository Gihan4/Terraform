provider "google" {
  credentials = file("/var/lib/jenkins/.kube/credentials")
  project     = "formidable-hold-392607"
  region      = "us-central1" 
}

resource "google_container_cluster" "the_cluster" {
  name               = "autopilot-cluster"
  location           = "us-central1" 
  enable_autopilot   = true

  # Specify the default release channel for Autopilot mode
  release_channel {
    channel = "REGULAR"
  }
}


