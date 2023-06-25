variable "aws_region" {
  description = "The region where the instance will be deployed to"
  type        = string
  default     = "eu-west-1"
 }
  
 #IAM

 variable "lambda_role_name"{
   description = "Lamba IAM Role"
   type = string
   default = "s3_lambda_role"
}

 variable "lambda_iam_policy_name"{
   description = "Lamba IAM Policy"
   type = string
   default = "s3_lambda_policy"
}

#DYNAMODB

 variable "table_name" {
  description = "Dynamodb table name"
  type = string
  default = "client_data"
} 

#S3

 variable "bucket_name" {
  description = "Bucket name"
  type = string
  default = "bucket-json"
}

# LAMBDA

 variable "lambda_name" {
  description = "Lambda name"
  type = string
  default = "lambda_json"
}
 variable "lambda_runtime" {
  description = "Runtime"
  type = string
  default = "python3.8"
}

 variable "lambda_handler" {
  description = "File name and function name"
  type = string
  default = "s3_json_dynamodb.lambda_handler"
}

 variable "lambda_zip_path" {
  description = "Path Zip file"
  type = string
  default = "s3_json_dynamodb.zip"
}

