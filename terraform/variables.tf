variable "project" {
  type    = string
}

variable "region" {
  type    = string
}

variable "cloud_func_bucket" {
  type    = string
}

variable "cloud_func_service_account" {
  type    = string
  default = "cloud-func-sa"
}

variable "cloud_func_service_account_roles" {
  type    = list(string)
  default = []
}

variable "functions" {
  type    = map(object({
      name = string
      description = string
      runtime = string
      environment_variables = map(string)
      available_memory_mb = number
      entry_point  = string
      pubsub_topic = string
  }))
}

variable "cloud_schedulers" {
  type    = map(object({
      pubsub_topic = string
      schedule = string
      time_zone = string
      data = map(string)
  }))
}