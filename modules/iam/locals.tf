locals {
    queues = ["dlq", "user-interaction", "long-running"]
    queue_policy_jsons = {
        for queue in local.queues :
        queue => data.aws_iam_policy_document.sqs_access[queue].json
    }
    containers = ["app", "celery", "beat"]
    container_region_pairs_list = flatten([
        for region in var.regions : [
            for container in local.containers : {
                region = region
                container = container
            }
        ]
    ])
    container_region_pairs_map = {
      for pair in local.container_region_pairs_list :
      "${pair.container}-${pair.region}" => pair
    }
    ecs_task_role_arns = {
        for container, role in aws_iam_role.ecs_task_execution : 
        container => role.arn
    }
    ssm_read_policy_doc_jsons = {
        for env_var, doc in data.aws_iam_policy_document.ssm_read_policy_doc :
        env_var => doc.json
    }
}
    