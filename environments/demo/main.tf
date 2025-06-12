```diff
diff --git a/environments/demo/main.tf b/environments/demo/main.tf
index 1234567..abcdefg 100644
--- a/environments/demo/main.tf
+++ b/environments/demo/main.tf
@@ -58,7 +58,7 @@ module "iam" {
 }
 
 resource "aws_iam_role_policy_attachment" "demo_123_s3_readonly" {
-  role       = "demo-123"
+  role       = module.iam.demo123_role_name
   policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
 }
 
diff --git a/modules/iam/main.tf b/modules/iam/main.tf
index 1234567..abcdefg 100644
--- a/modules/iam/main.tf
+++ b/modules/iam/main.tf
@@ -11,7 +11,7 @@ resource "aws_iam_role" "demo123" {
 
 resource "aws_iam_role_policy" "demo123_policy" {
   name = "demo123-policy"
-  role = aws_iam_role.github_radio_user.id
+  role = aws_iam_role.demo123.id
 
   policy = jsonencode({
     Version = "2012-10-17",
diff --git a/modules/iam/outputs.tf b/modules/iam/outputs.tf
new file mode 100644
index 0000000..1234567
--- /dev/null
+++ b/modules/iam/outputs.tf
@@ -0,0 +1,4 @@
+output "demo123_role_name" {
+  description = "Name of the demo-123 IAM role"
+  value       = aws_iam_role.demo123.name
+}
```