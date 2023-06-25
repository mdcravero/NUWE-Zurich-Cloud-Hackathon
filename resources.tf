# Creating Lambda IAM resource
resource "aws_iam_role" "lambda_iam" {
  name = var.lambda_role_name

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "lambda_role_policy" {
  name = var.lambda_iam_policy_name
  role = aws_iam_role.lambda_iam.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_dynamodb_table" "client_data" {
  name           = var.table_name
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "id"
  range_key      = "name"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "name"
    type = "S"
  }

  attribute {
    name = "surname"
    type = "S"
  }
  
ttl {
    attribute_name = "TimeToExist"
    enabled        = false
  }

  global_secondary_index {
    name               = "NameIndex"
    hash_key           = "name"
    range_key          = "surname"
    write_capacity     = 5
    read_capacity      = 5
    non_key_attributes = []
    projection_type    = "ALL"
 }
}

resource "aws_lambda_function" "s3_json_lambda" {
  function_name = var.lambda_name
  role          = aws_iam_role.lambda_iam.arn

  runtime = var.lambda_runtime

  handler = var.lambda_handler

  filename      = var.lambda_zip_path

  timeout = 60   
  memory_size = 128  

 }
resource "aws_s3_bucket" "bucket-json" {
  bucket = var.bucket_name
  force_destroy = true   

}
resource "aws_s3_bucket_notification" "aws_lambda_trigger" {
  bucket = aws_s3_bucket.bucket-json.id
  lambda_function {
    lambda_function_arn = aws_lambda_function.s3_json_lambda.arn
    events              = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]

  }
}

