locals {
    queues = ["dlq", "user-interaction", "long-running"]
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
}
    