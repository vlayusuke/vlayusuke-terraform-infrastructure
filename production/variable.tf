variable "hook_url_app" {
  type      = string
  sensitive = true
}

variable "slack_workspace_id" {
  sensitive = true
}

variable "slack_channel_id" {
  sensitive = true
}
