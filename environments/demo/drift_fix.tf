resource "aws_lb" "idle" {
  # drift: declared=true actual=internal
  name               = "public-demo-finops-idle-alb"
  internal           = true
  load_balancer_type = "application"
}