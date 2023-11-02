resource "aws_sns_topic" "window_task_notification" {
  count = var.notification_arn == "" && length(var.notification_events) > 0 ? 1 : 0
  name  = "${var.name}-patch-manager-alerts"
}