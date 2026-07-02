resource "aws_appautoscaling_target" "members" {
  max_capacity       = var.members_max_count
  min_capacity       = var.members_min_count
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.members.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "members_cpu" {
  name               = "${var.project_name}-members-cpu-autoscale"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.members.resource_id
  scalable_dimension = aws_appautoscaling_target.members.scalable_dimension
  service_namespace  = aws_appautoscaling_target.members.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = var.members_cpu_target
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}
