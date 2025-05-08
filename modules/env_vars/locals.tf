locals {
  django_env_vars = {
    LOAD_BALANCER_ENDPOINT   = "${var.environment}.${var.domain}"
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
    REDIS_CAFILE_PATH        = "/code/conf_files/redis-bundle.pem",
  }
  env_vars = merge(local.django_env_vars, var.kms_aliases)
  db_username_final = "${var.environment}${var.db_username}"
  db_password_final = var.db_password
  secrets = {
    DB_CREDENTIALS     = {
      username = local.db_username_final,
      password = local.db_password_final
    }
    EMAIL_CREDENTIALS  = { 
      EMAIL_HOST_PASSWORD = var.email_host_password,
      EMAIL_HOST_USER = var.email_host_user,
      NOTIFICATIONS_EMAIL = var.notifications_email,
      SENDGRID_API_KEY = var.sendgrid_api_key
    }
    PLAID_CREDENTIALS  = {
      PLAID_CLIENT_ID = var.plaid_client_id,
      PLAID_SECRET = var.plaid_secret,
      PLAID_HOST = var.plaid_host
    }
    ANONYMIZE_USER_HMAC_KEY = { 
      ANONYMIZE_USER_HMAC_KEY = var.anonymize_user_hmac_key
    }
    FMP_CREDENTIALS = { FMP_KEY = var.fmp_key }
  }
  secret_jsons = {
    for key, secret in local.secrets :
    key => jsonencode(secret)
  }

//  analytics_ec2_env_vars = {
//    DB_PORT                  = var.analytics_db_name_port_host["port"]
//    DB_NAME                  = var.analytics_db_name_port_host["name"]
//    DB_HOST                  = var.analytics_db_name_port_host["host"]
//    DB_CAFILE_PATH           = "/code/conf_files/rds-us-west-1-bundle.pem"
//  }
//  analytics_ec2_secrets = {
//    DB_CREDENTIALS     = {
//        username = var.analytics_db_user_username,
//        password = var.analytics_db_user_password
//    }
//  }
//  analytics_ec2_secret_jsons = {
//    for key, secret in local.analytics_ec2_secrets :
//    key => jsonencode(secret)
//  }
  
  
}