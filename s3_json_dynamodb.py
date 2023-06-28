import os
import boto3
import json
import ast

#localstack_host = os.environ['LOCALSTACK_HOSTNAME']
#edge_port = os.environ['EDGE_PORT']

s3_client = boto3.client("s3", endpoint_url="http://172.17.0.2:4566")
dynamodb_client = boto3.resource('dynamodb', endpoint_url="http://172.17.0.2:4566")

def lambda_handler(event, context):
     bucket = event['Records'][0]['s3']['bucket']['name']
     json_file_name = event['Records'][0]['s3']['object']['key']
     json_object = s3_client.get_object(Bucket=bucket,Key=json_file_name)
     file_reader = json_object['Body'].read().decode("utf-8")
     file_reader = ast.literal_eval(file_reader)
     table = dynamodb_client.Table('client_data')
     if type(file_reader) == type([]):
        for item in file_reader:
            table.put_item(Item=item)
     else:
        table.put_item(Item=file_reader)
     print("## File uploaded successfully ##")
     return 'success'
