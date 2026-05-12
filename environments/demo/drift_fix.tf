resource "aws_lb" "demo" {
  name               = "demo-map-alb"
  load_balancer_type = "application"
  # drift: declared=false actual=internet-facing
  internal           = false
}