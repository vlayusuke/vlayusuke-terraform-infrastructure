# ===============================================================================
# Inspector v2
# ===============================================================================
resource "aws_inspector2_enabler" "audit_tokyo_region" {
  account_ids = [
    data.aws_caller_identity.current.account_id,
  ]
  resource_types = [
    "EC2",
    "ECR",
    "LAMBDA",
    "LAMBDA_CODE"
  ]
}
