locals {
  env_vars = {
    DB_PORT                  = var.db_name_port_host["port"]
    DB_NAME                  = var.db_name_port_host["name"]
    DB_HOST                  = var.db_name_port_host["host"]
    DB_CAFILE_PATH           = "/code/conf_files/rds-us-west-1-bundle.pem"
    EMAIL_HOST               = "smtp.gmail.com"
    EMAIL_HOST_USER          = "accumate-verify@accumatewealth.com"
    DEBUG                    = "False"
    SQS_USER_INTERACTION_URL = var.sqs_urls["user-interaction"]
    SQS_LONG_RUNNING_URL     = var.sqs_urls["long-running"]
    SQS_DLQ_URL              = var.sqs_urls["dlq"]
    REDIS_HOST               = var.redis_no_cluster_host_port_url["host"]
    REDIS_URL                = var.redis_no_cluster_host_port_url["url"]
    REDIS_PORT               = var.redis_no_cluster_host_port_url["port"]
    REDIS_CAFILE_PATH        = "/code/conf_files/redis-bundle.pem"
  }

  db_username_final = "${var.environment}${var.db_username}"
  db_password_final = var.db_password

  secrets = {
    DB_CREDENTIALS     = {
        username = local.db_username_final,
        password = local.db_password_final
    }
    EMAIL_CREDENTIALS  = { 
      EMAIL_HOST_PASSWORD = var.email_host_password,
      EMAIL_HOST_USER = var.email_host_user
    }
    PLAID_CREDENTIALS  = {
        PLAID_CLIENT_ID = "var.plaid_client_id",
        PLAID_SECRET = "var.plaid_secret",
        PLAID_HOST = "var.plaid_host"
    }

    FMP_CREDENTIALS = { FMP_KEY = var.fmp_key }
  }
  
  secret_jsons = {
    for key, secret in local.secrets :
    key => jsonencode(secret)
  }
}