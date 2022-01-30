
// The bucket to hold the Cloud Function zip
resource "google_storage_bucket" "bucket" {
  name = var.cloud_func_bucket
  uniform_bucket_level_access = true
  versioning {
    enabled = true
  }
}

data "archive_file" "src" {
  type        = "zip"
  source_dir  = "${path.root}/../src" 
  output_path = "${path.root}/../generated/src.zip"
}

resource "google_storage_bucket_object" "archive" {
  name   = "${data.archive_file.src.output_md5}.zip"
  bucket = google_storage_bucket.bucket.name
  source = "${path.root}/../generated/src.zip"
}

resource "google_service_account" "service_account" {
  account_id   = var.cloud_func_service_account
  display_name = "Cloud Function Service Account"
}



# Allow SA service account use the default GCE account
# data "google_compute_default_service_account" "default" {}

# resource "google_service_account_iam_member" "gce-default-account-iam" {
#   service_account_id = data.google_compute_default_service_account.default.name
#   role               = "roles/iam.serviceAccountUser"
#   member             = "serviceAccount:${google_service_account.sa.email}"
# }

resource "google_project_iam_member" "service-account-roles" {
  for_each    = toset(var.cloud_func_service_account_roles)
  project     = var.project
  role        = each.value
  member      = "serviceAccount:${google_service_account.service_account.email}"
}

# resource "google_cloudfunctions_function_iam_member" "member" {
#   for_each    = { 
#       for i, v in flatten([
#         for k, func in var.functions: [
#             for role in var.cloud_func_service_account_roles: {
#                 key = k, role = role
#             }
#         ]
#       ]): (sha256(jsonencode(v))) => v
#   }
  
#   project  = google_cloudfunctions_function.function[each.value.key].project
#   region   = google_cloudfunctions_function.function[each.value.key].region
#   cloud_function = google_cloudfunctions_function.function[each.value.key].name
#   role   = each.value.role
#   member = "serviceAccount:${google_service_account.service_account.email}"
# }

resource "google_cloudfunctions_function" "function" {
  for_each    = var.functions
  name        = each.value.name
  region      = var.region
  description = each.value.description
  runtime     = each.value.runtime

  environment_variables = each.value.environment_variables

  available_memory_mb   = each.value.available_memory_mb
  source_archive_bucket = google_storage_bucket.bucket.name
  source_archive_object = google_storage_bucket_object.archive.name
  // trigger_http          = true

  entry_point           = each.value.entry_point
  service_account_email = google_service_account.service_account.email

  event_trigger {
    event_type = "google.pubsub.topic.publish"
    resource   = each.value.pubsub_topic
  }

  depends_on = [
    google_project_service.pubsub,
    google_project_service.cloudfunctions,
  ]
}

// Pubsub Topic

resource "google_project_service" "pubsub" {
  project = var.project
  service = "pubsub.googleapis.com"
}

resource "google_project_service" "cloudfunctions" {
  project = var.project
  service = "cloudfunctions.googleapis.com"
}

resource "google_project_service" "cloudscheduler" {
  project = var.project
  service = "cloudscheduler.googleapis.com"
}

resource "google_pubsub_topic" "topic" {
  for_each = var.cloud_schedulers
  project = var.project
  name    = each.value.pubsub_topic

  depends_on = [
    google_project_service.pubsub,
  ]
}

// Cloud Scheduler
resource "google_cloud_scheduler_job" "pubsub_jobs" {
  for_each = var.cloud_schedulers
  project  = var.project
  region   = var.region
  name     = each.key
  schedule = each.value.schedule
  time_zone = each.value.time_zone

  pubsub_target {
    topic_name = google_pubsub_topic.topic[each.key].id
    data       = base64encode(jsonencode(each.value.data))
  }

  depends_on = [
    google_project_service.cloudscheduler,
  ]
}

