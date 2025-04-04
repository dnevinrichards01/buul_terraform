locals {
    queues = ["dlq", "user-interaction", "long-running"]
    sqs_urls = {
        dlq = aws_sqs_queue.dlq.url,
        user-interaction = aws_sqs_queue.user_interaction.url,
        long-running = aws_sqs_queue.long_running.url
    }
}