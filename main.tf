# 1) Create s3 bucket
resource "aws_s3_bucket" "tempBucket" {
    bucket = var.bucket_name
    tags = {
      Name = "Temp Bucket"
      Environment = "dev"
    }
}

# 2) Create local file with content
resource "local_file" "myFile" {
    filename = "myFile.txt"
    content = <<-EOT
        Hello This is from Terraform!!
        and this is generated to check automate s3 cleanup
    EOT
}

# 3) Upload localfile to aws s3
resource "aws_s3_object" "uploadFile" {
    bucket = aws_s3_bucket.tempBucket.id
    key = "checkFile.txt"
    source = "myFile.txt"
}

# 4) Create IAM assume role for aws lambda
resource "aws_iam_role" "lambdaRole" {
    name = "automated_s3_cleanup_lambda"
    description = "Role for aws lambda to automate s3 cleanup"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect = "Allow"
            Action = "sts:AssumeRole"
            Principal = {
                Service = "lambda.amazonaws.com"
            }
        }]
    }) 
}

#5) Create policy to list s3 bucket and get, delete object from that bucket
resource "aws_iam_policy" "lambdaS3policy" {
    name = "lambda_policy"
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect = "Allow"
            Action = "s3:ListBucket"
            Resource = aws_s3_bucket.tempBucket.arn
        },
        {
            Effect = "Allow"
            Action = [
                "s3:GetObject",
                "s3:DeleteObject"
            ]
            Resource = "arn:aws:s3:::${aws_s3_bucket.tempBucket.id}/*"
        }
        ]
    }) 
}

# 6) Attach policy to role
resource "aws_iam_role_policy_attachment" "lambdaRolePolicyAttchment" {
    role = aws_iam_role.lambdaRole.id
    policy_arn = aws_iam_policy.lambdaS3policy.arn
}

# 7) Zip python file for lambda
resource "archive_file" "zipPythonFile" {
    type = "zip"
    output_path = "python_function.zip"
    source_file = "python_function.py"
}

# 8) Create and deploy lambda
resource "aws_lambda_function" "s3cleanupauto" {
    function_name = "s3_cleanup_automation"
    role = aws_iam_role.lambdaRole.arn
    handler = "python_function.lambda_handler"
    runtime = "python3.8"
    timeout = 60
    filename = archive_file.zipPythonFile.output_path
    environment {
      variables = {
        "BUCKET_NAME" = "${aws_s3_bucket.tempBucket.id}"
      }
    } 
}

# 9) Cloud watch event rule for trigger
resource "aws_cloudwatch_event_rule" "triggertime" {
    name = "my_event_s3_cleanup"
    description = "Event rule for s3 cleanup daily"
    schedule_expression = "cron (30 4 * * ? *)"
}
/*Field	Value	Explanation
cron(30 4 * * ? *)
Minutes	30	Runs at 30th minute
Hours	4	4 AM UTC (10 AM IST)
Day	*	Runs every day
Month	*	Runs every month
Day of Week	?	Any day of the week
Year	*	Runs every year
*/

# 10) Set cloud watch event target for lambda
resource "aws_cloudwatch_event_target" "targetLambda" {
    rule = aws_cloudwatch_event_rule.triggertime.id
    target_id = "LambdaTrigger"
    arn = aws_lambda_function.s3cleanupauto.arn
}

# 11) Add lambda permission for cloud watch trigger
resource "aws_lambda_permission" "addTriggerPermission" {
    function_name = aws_lambda_function.s3cleanupauto.function_name
    action = "lambda:InvokeFunction"
    principal = "events.amazonaws.com"
    statement_id  = "AllowExecutionFromCloudWatchStart"
    source_arn = aws_cloudwatch_event_rule.triggertime.arn
  
}
# Attach AWS Managed Policy for CloudWatch Logs
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambdaRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
