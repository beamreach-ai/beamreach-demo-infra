resource "aws_sqs_queue" "demo" {
  name = "public-demo-map-queue"

  # drift: declared=30 actual="30"
  visibility_timeout_seconds = 30
}