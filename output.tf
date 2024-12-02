output "bucket_url" {
  value = google_storage_bucket.static_bucket.website_endpoint
}
