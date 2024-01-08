# ===============================================================================
# Config
# ===============================================================================
resource "aws_config_configuration_recorder" "default" {
  name     = "${local.project}-${local-env}-aws-config-default-recorder"
  role_arn = aws_iam_role.config_recorder.arn

  recording_group {
    all_supported                 = false
    include_global_resource_types = false
    resource_types = [
      "AWS::EC2::CustomerGateway",
      "AWS::EC2::EIP",
      "AWS::EC2::Host",
      "AWS::EC2::Instance",
      "AWS::EC2::InternetGateway",
      "AWS::EC2::NetworkAcl",
      "AWS::EC2::RouteTable",
      "AWS::CloudTrail::Trail",
      "AWS::EC2::Volume",
      "AWS::EC2::VPNConnection",
      "AWS::EC2::VPNGateway",
      "AWS::EC2::RegisteredHAInstance",
      "AWS::EC2::NatGateway",
      "AWS::EC2::EgressOnlyInternetGateway",
      "AWS::EC2::VPCEndpoint",
      "AWS::EC2::VPCEndpointService",
      "AWS::EC2::FlowLog",
      "AWS::EC2::VPCPeeringConnection",
      "AWS::Elasticsearch::Domain",
      "AWS::IAM::Group",
      "AWS::IAM::Policy",
      "AWS::IAM::Role",
      "AWS::IAM::User",
      "AWS::ElasticLoadBalancingV2::LoadBalancer",
      "AWS::ACM::Certificate",
      "AWS::RDS::DBInstance",
      "AWS::RDS::DBSubnetGroup",
      "AWS::RDS::DBSecurityGroup",
      "AWS::RDS::DBSnapshot",
      "AWS::RDS::DBCluster",
      "AWS::RDS::DBClusterSnapshot",
      "AWS::RDS::EventSubscription",
      "AWS::S3::Bucket",
      "AWS::S3::AccountPublicAccessBlock",
      "AWS::Redshift::Cluster",
      "AWS::Redshift::ClusterSnapshot",
      "AWS::Redshift::ClusterParameterGroup",
      "AWS::Redshift::ClusterSecurityGroup",
      "AWS::Redshift::ClusterSubnetGroup",
      "AWS::Redshift::EventSubscription",
      "AWS::SSM::ManagedInstanceInventory",
      "AWS::CloudWatch::Alarm",
      "AWS::CloudFormation::Stack",
      "AWS::ElasticLoadBalancing::LoadBalancer",
      "AWS::AutoScaling::AutoScalingGroup",
      "AWS::AutoScaling::LaunchConfiguration",
      "AWS::AutoScaling::ScalingPolicy",
      "AWS::AutoScaling::ScheduledAction",
      "AWS::DynamoDB::Table",
      "AWS::CodeBuild::Project",
      "AWS::WAF::RateBasedRule",
      "AWS::WAF::Rule",
      "AWS::WAF::RuleGroup",
      "AWS::WAF::WebACL",
      "AWS::WAFRegional::RateBasedRule",
      "AWS::WAFRegional::Rule",
      "AWS::WAFRegional::RuleGroup",
      "AWS::WAFRegional::WebACL",
      "AWS::CloudFront::Distribution",
      "AWS::CloudFront::StreamingDistribution",
      "AWS::Lambda::Function",
      "AWS::NetworkFirewall::Firewall",
      "AWS::NetworkFirewall::FirewallPolicy",
      "AWS::NetworkFirewall::RuleGroup",
      "AWS::ElasticBeanstalk::Application",
      "AWS::ElasticBeanstalk::ApplicationVersion",
      "AWS::ElasticBeanstalk::Environment",
      "AWS::WAFv2::WebACL",
      "AWS::WAFv2::RuleGroup",
      "AWS::WAFv2::IPSet",
      "AWS::WAFv2::RegexPatternSet",
      "AWS::WAFv2::ManagedRuleSet",
      "AWS::XRay::EncryptionConfig",
      "AWS::SSM::AssociationCompliance",
      "AWS::SSM::PatchCompliance",
      "AWS::Shield::Protection",
      "AWS::ShieldRegional::Protection",
      "AWS::Config::ConformancePackCompliance",
      "AWS::Config::ResourceCompliance",
      "AWS::ApiGateway::Stage",
      "AWS::ApiGateway::RestApi",
      "AWS::ApiGatewayV2::Stage",
      "AWS::ApiGatewayV2::Api",
      "AWS::CodePipeline::Pipeline",
      "AWS::ServiceCatalog::CloudFormationProvisionedProduct",
      "AWS::ServiceCatalog::CloudFormationProduct",
      "AWS::ServiceCatalog::Portfolio",
      "AWS::SQS::Queue",
      "AWS::KMS::Key",
      "AWS::QLDB::Ledger",
      "AWS::SecretsManager::Secret",
      "AWS::SNS::Topic",
      "AWS::SSM::FileData",
      "AWS::Backup::BackupPlan",
      "AWS::Backup::BackupSelection",
      "AWS::Backup::BackupVault",
      "AWS::Backup::RecoveryPoint",
      "AWS::ECR::Repository",
      "AWS::ECS::Cluster",
      "AWS::ECS::Service",
      "AWS::ECS::TaskDefinition",
      "AWS::EFS::AccessPoint",
      "AWS::EFS::FileSystem",
      "AWS::EKS::Cluster",
      "AWS::OpenSearch::Domain",
      "AWS::EC2::TransitGateway",
      "AWS::Kinesis::Stream",
      "AWS::Kinesis::StreamConsumer",
      "AWS::CodeDeploy::Application",
      "AWS::CodeDeploy::DeploymentConfig",
      "AWS::CodeDeploy::DeploymentGroup",
      "AWS::EC2::LaunchTemplate",
      "AWS::ECR::PublicRepository",
      "AWS::GuardDuty::Detector",
      "AWS::EMR::SecurityConfiguration",
      "AWS::SageMaker::CodeRepository",
      "AWS::Route53Resolver::ResolverEndpoint",
      "AWS::Route53Resolver::ResolverRule",
      "AWS::Route53Resolver::ResolverRuleAssociation",
      "AWS::DMS::ReplicationSubnetGroup",
      "AWS::DMS::EventSubscription",
      "AWS::MSK::Cluster",
      "AWS::StepFunctions::Activity",
      "AWS::WorkSpaces::Workspace",
      "AWS::WorkSpaces::ConnectionAlias",
      "AWS::SageMaker::Model",
      "AWS::ElasticLoadBalancingV2::Listener",
      "AWS::StepFunctions::StateMachine",
      "AWS::Batch::JobQueue",
      "AWS::Batch::ComputeEnvironment",
      "AWS::AccessAnalyzer::Analyzer",
      "AWS::Athena::WorkGroup",
      "AWS::Athena::DataCatalog",
      "AWS::Detective::Graph",
      "AWS::GlobalAccelerator::Accelerator",
      "AWS::GlobalAccelerator::EndpointGroup",
      "AWS::GlobalAccelerator::Listener",
      "AWS::EC2::TransitGatewayAttachment",
      "AWS::EC2::TransitGatewayRouteTable",
      "AWS::DMS::Certificate",
    ]
  }
}

resource "aws_config_delivery_channel" "default" {
  name           = "${local.project}-${local-env}-aws-config-default-channel"
  s3_bucket_name = aws_s3_bucket.config_logs.bucket

  depends_on = [
    aws_config_configuration_recorder.default,
  ]

  snapshot_delivery_properties {
    delivery_frequency = "TwentyFour_Hours"
  }
}

resource "aws_config_configuration_recorder_status" "default" {
  name       = aws_config_configuration_recorder.default.name
  is_enabled = true

  depends_on = [
    aws_config_delivery_channel.default,
  ]
}

resource "aws_cloudformation_stack" "operational_best_practices_for_cis" {
  name = "${local.project}-${local.env}-operational-best-practices-for-cis"
  # commit: 9018e3a3003bde8d8898a2912de64cce39a20b80
  # https://github.com/awslabs/aws-config-rules/blob/master/aws-config-conformance-packs/Operational-Best-Practices-for-CIS.yaml
  template_body = file("./files/cloudformation/Operational-Best-Practices-for-CIS.yaml")

  depends_on = [
    aws_config_configuration_recorder.default,
  ]
}

resource "aws_config_config_rule" "s3_bucket_server_side_encryption_enabled" {
  name = "s3_bucket_server_side_encryption_enabled"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_SERVER_SIDE_ENCRYPTION_ENABLED"
  }

  depends_on = [
    aws_config_configuration_recorder.default,
  ]
}

resource "aws_config_config_rule" "s3_bucket_versioning_enabled" {
  name = "s3_bucket_versioning_enabled"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_VERSIONING_ENABLED"
  }

  depends_on = [
    aws_config_configuration_recorder.default,
  ]
}

resource "aws_config_config_rule" "rds_instance_public_access_check" {
  name = "rds_instance_public_access_check"

  source {
    owner             = "AWS"
    source_identifier = "RDS_INSTANCE_PUBLIC_ACCESS_CHECK"
  }

  depends_on = [
    aws_config_configuration_recorder.default,
  ]
}
