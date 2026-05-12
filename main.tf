# /aws/lambda/public-demo-map-publisher
resource "aws_cloudwatch_log_group" "aws_lambda_public_demo_map_publisher" {
  name              = "/aws/lambda/public-demo-map-publisher"
  retention_in_days = 7
}