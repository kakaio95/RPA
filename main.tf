provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_storage_bucket" "static_bucket" {
  name          = var.bucket_name
  location      = var.region
  force_destroy = true
  website {
    main_page_suffix = "index.html"
  }
}

resource "google_storage_bucket_object" "index" {
  name   = "index.html"
  bucket = google_storage_bucket.static_bucket.name
  source = file("${path.module}/static-website/index.html")
  content_type = "text/html"
}

resource "google_compute_global_address" "lb_ip" {
  name = "static-website-lb-ip"
}

resource "google_compute_backend_bucket" "backend" {
  name        = var.bucket_name
  bucket_name = google_storage_bucket.static_bucket.name
}

resource "google_compute_url_map" "url_map" {
  name            = "static-website-map"
  default_service = google_compute_backend_bucket.backend.self_link
}

resource "google_compute_target_http_proxy" "proxy" {
  name   = "http-proxy"
  url_map = google_compute_url_map.url_map.self_link
}

resource "google_compute_global_forwarding_rule" "http_rule" {
  name        = "http-forwarding-rule"
  ip_address  = google_compute_global_address.lb_ip.address
  target      = google_compute_target_http_proxy.proxy.self_link
  port_range  = "80"
}
