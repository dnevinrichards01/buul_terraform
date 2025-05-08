locals {
  kms = {
    RH_ACCESS_KMS_ALIAS = "rh-access", 
    RH_REFRESH_KMS_ALIAS = "rh-refresh", // refresh and device_id
    PLAID_ITEM_KMS_ALIAS = "plaid-item-access", 
    PLAID_USER_KMS_ALIAS = "plaid-user-access", //userToken
    USER_PII_KMS_ALIAS = "user-pii", // email, number, waitlist email, name, username
  } // sort on the encrypted version of email and number...
  
  // 
    
  services = ["app", "celery", "beat"]
  tasks = ["app", "celery", "beat", "debug-current", "debug-latest"]
  ecr_repo_names = {
    app = var.ecr_repo_names["app"],
    celery = var.ecr_repo_names["celery"],
    beat = var.ecr_repo_names["beat"],
    debug-current = var.ecr_repo_names["app"]
    debug-latest = var.ecr_repo_names["app"]
  }
  image_versions = {
    app = "current",
    celery = "current",
    beat = "current",
    debug-current = "current",
    debug-latest = "latest"
  }


  task_definitions = {
    for task in local.tasks :
    task => [
      {
        name  = "${var.environment}-${task}"
        image = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com/${local.ecr_repo_names[task]}:${local.image_versions[task]}"
        cpu   = 0 // just gives it the tasks's total cpu
        essential = true

        command = task == "debug" ? ["tail", "-f", "/dev/null"] : null

        portMappings = [
          {
            name          = "${var.environment}-${task}-443-tcp"
            containerPort = 443
            hostPort      = 443
            protocol      = "tcp"
            appProtocol   = "http"
          }
        ]

        secrets = flatten([
          [
            for name, arn in var.ssm_env_arns : {
              name = name, 
              valueFrom = arn
            }
          ], 
          [
            for name, arn in var.secrets_arns : {
              name = name, 
              valueFrom = arn
            }
          ] 
        ])

        logConfiguration = {
          logDriver = "awslogs"
          options = {
            awslogs-group         = "/ecs/${var.environment}/${task}"
            awslogs-region        = var.region
            awslogs-stream-prefix = "ecs"
            mode                  = "non-blocking"
            awslogs-create-group  = "true"
            max-buffer-size       = "25m"
          }
        }
      }
    ]
  }
}