variable "audit_hook_url" {
  type      = string
  sensitive = true
}

variable "audit_slack_workspace_id" {
  sensitive = true
}

variable "audit_slack_channel_id" {
  sensitive = true
}
