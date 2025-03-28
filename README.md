# TerraformAutomateS3Cleanup

This project automates the deletion of S3 objects older than 7 days using AWS Lambda, Terraform, and CloudWatch Event Rules.  <br>
The Lambda function runs daily at 10 AM IST and removes expired files from an S3 bucket.

Architecture Overview
---------------------
![AutomateS3Cleanup (2)](https://github.com/user-attachments/assets/acfe2345-34d4-4b1b-b068-404a22fa994a)

Technologies Used
------------------
Terraform → Infrastructure as Code (IaC) <br>
AWS Lambda → Executes Python script <br>
Amazon S3 → Stores objects for cleanup <br>
IAM Roles & Policies → Provides required permissions <br>
CloudWatch Events → Schedules Lambda execution at 10 AM IST <br>
Boto3 (Python SDK) → Interacts with S3 <br>

Features
---------
✔ Automates cleanup of old files from an S3 bucket <br>
✔ Uses Terraform for infrastructure setup <br>
✔ Scheduled execution using CloudWatch Events <br>
✔ Logs all execution details in CloudWatch Logs <br>
✔ Secure IAM Role with least privilege permissions <br>

Prerequisites
--------------
Terraform Installed: Download Terraform<br>
AWS CLI Installed & Configured: aws configure<br>
AWS Account with necessary permissions <br>

Setup Instructions
--------------------
Clone the Repository<br>
git clone https://github.com/Jeyagomathi-lab/TerraformAutomateS3Cleanup.git<br>
Initialize Terraform<br>
terraform init<br>
Modify Variables (if needed)<br>
Update terraform.tfvars with your bucket name.<br>
Apply Terraform Configuration<br>
terraform apply -auto-approve
Verify Deployment<br>
Check AWS Lambda, IAM, and CloudWatch for created resources.<br>

Future Enhancements
------------------------
Add logging for deleted files.<br>
Encrypt S3 bucket data.<br>
Integrate AWS SNS for notifications.<br>




