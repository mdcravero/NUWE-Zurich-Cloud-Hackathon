# NUWE-Zurich-Cloud-Hackathon

## :memo: Objectives:

- Create a Lambda function that automates inserting data into DynamoDB.
- Create Terraform files to automatically create all the necessary resources.
- Automate the execution of the Lambda function to be triggered when uploading a JSON file to an s3 Bucket.
- Create a short README with the infrastructure created and the decisions taken during the process.

## Decisions taken during the process

In addition to the recommended configuration I personally decided to use [**tflocal**](https://docs.localstack.cloud/user-guide/integrations/terraform/), this made it easier for me to work with localstack and terrafom without having to define endpoints manually.
Therefore most of the commands with terraform I run with the **tflocal** command.

:bulb:For debug I used the following flags:
```bash
LAMBDA_EXECUTOR=docker-reuse DEBUG=1 SERVICES=lambda localstack start -d
```
I also make use of the following alias to avoid always writing the endpoint in the AWS CLI
```bash
alias awslc='aws --endpoint-url=http://localhost:4566'  
```
---

## Infrastructure created

### Infrastructure Diagram

![Infrastructure Diagram](https://github.com/mdcravero/NUWE-Zurich-Cloud-Hackathon/blob/main/Zurich%20Cloud%20Hackathon%20Diagram.jpg)

In addition to the resources shown in the diagram, we also created a role, policy and an S3 Bucket Notification, which we use to activate the trigger when the file is inserted into the S3.

:information_source::information_source: We must convert the file **s3_json_dynamodb.py** to .zip so that Lambda can use it when deploying the infrastructure.

```bash
zip s3_json_dynamodb.zip s3_json_dynamodb.py
```
---

### List of resourses

We deploy our infra:

```bash
tflocal apply --auto-approve
```

we obtain

```bash
aws_iam_role.lambda_iam: Refreshing state... [id=s3_lambda_role]
aws_s3_bucket.bucket-json: Refreshing state... [id=bucket-json]
aws_dynamodb_table.client_data: Refreshing state... [id=client_data]
aws_iam_role_policy.lambda_role_policy: Refreshing state... [id=s3_lambda_role:s3_lambda_policy]
aws_lambda_function.s3_json_lambda: Refreshing state... [id=lambda_json]
aws_s3_bucket_notification.aws_lambda_trigger: Refreshing state... [id=bucket-json]
```
>Even if they are not necessary, (in this case) I created a role and a policy to be able to upload and remove objects from the buckets.

Once we have all the infra deployed, we have to upload the .json to the s3 bucket
```bash
awslc s3 cp client_data.json s3://bucket-json
```
---

## Lambda Function

We import the necessary libraries for this lambda written in python.
```python
import os
import boto3
import json
import ast
```

:x::x:I tried to use the environment variables to call Localstack but for some strange reason they did not work.
```python
localstack_host = os.environ['LOCALSTACK_HOSTNAME']
edge_port = os.environ['EDGE_PORT']
```

To make Lambda work and not give errors with the API KEYs I used the endpoins in this way by calling the LocalStack host in the parent container.
```python
s3_client = boto3.client("s3", endpoint_url="http://172.17.0.2:4566")
dynamodb_client = boto3.resource('dynamodb', endpoint_url="http://172.17.0.2:4566")
```

We will use the event argument (which is a json) that contains the data we need to get both the bucket information and the .json file.
```python    
bucket = event['Records'][0]['s3']['bucket']['name']
json_file_name = event['Records'][0]['s3']['object']['key']
```    

Access to the file and decode it.
```python       
json_object = s3_client.get_object(Bucket=bucket,Key=json_file_name)
file_reader = json_object['Body'].read().decode("utf-8")
```

We convert the content of a file into a dict, because the input of the method requires an argument in dict.
```python      
file_reader = ast.literal_eval(file_reader)
```

Finally, if the information obtained is a list, we go through it and upload it, otherwise we upload it directly.
```python
table = dynamodb_client.Table('client_data')
    if type(file_reader) == type([]):
        for item in file_reader:
            table.put_item(Item=item) 
    else:
        table.put_item(Item=file_reader) 
```

---

We check that the file has been successfully uploaded to DynamoDB

```bash
awslc dynamodb scan --table-name client_data
```
```bash
{
    "Count": 10,
    "ScannedCount": 10,
    "ConsumedCapacity": null
}
```
