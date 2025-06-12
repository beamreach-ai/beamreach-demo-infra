```diff
diff --git a/modules/iam/main.tf b/modules/iam/main.tf
index 1234567..abcdefg 100644
--- a/modules/iam/main.tf
+++ b/modules/iam/main.tf
@@ -17,7 +17,7 @@ resource "aws_iam_role" "demo123" {
 
 resource "aws_iam_role_policy" "demo123_policy" {
   name = "demo123-policy"
-  role = aws_iam_role.github_radio_user.id
+  role = aws_iam_role.demo123.id
 
   policy = jsonencode({
     Version = "2012-10-17",
@@ -36,6 +36,25 @@ resource "aws_iam_role_policy" "demo123_policy" {
   })
 }
 
+resource "aws_iam_role_policy" "demo123_s3_readonly_policy" {
+  name = "demo123-s3-readonly-policy"
+  role = aws_iam_role.demo123.id
+
+  policy = jsonencode({
+    Version = "2012-10-17",
+    Statement = [
+      {
+        Effect = "Allow",
+        Action = [
+          "s3:GetObject",
+          "s3:GetObjectVersion",
+          "s3:ListBucket",
+          "s3:ListAllMyBuckets"
+        ],
+        Resource = "*"
+      }
+    ]
+  })
+}
+
 resource "aws_iam_role" "github_radio_user" {
   name = "github-radio-user-role"
```