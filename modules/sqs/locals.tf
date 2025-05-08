locals {
    queues = ["dlq", "user-interaction", "long-running"]
    
    sqs_urls = {
        dlq = "https://${var.vpce_ids["sqs"]}-sqs.${var.region}.vpce.amazonaws.com/${data.aws_caller_identity.current.account_id}/${var.environment}-dlq" // aws_sqs_queue.dlq.url,
        user-interaction = "https://${var.vpce_ids["sqs"]}-sqs.${var.region}.vpce.amazonaws.com/${data.aws_caller_identity.current.account_id}/${var.environment}-user-interaction",
        long-running = "https://${var.vpce_ids["sqs"]}-sqs.${var.region}.vpce.amazonaws.com/${data.aws_caller_identity.current.account_id}/${var.environment}-long-running"
    }
}