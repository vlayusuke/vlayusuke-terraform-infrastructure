resource "aws_guardduty_detector" "guardduty" {
  enable = true

  datasources {
    s3_logs {
      enable = true
    }
  }
}
