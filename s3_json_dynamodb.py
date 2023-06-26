import boto3
import json
import ast
s3_client = boto3.client('s3')
dynamodb_client = boto3.resource('dynamodb')
def lambda_handler(event, context):
    bucket = event['Records'][0]['s3']['bucket']['name']
    json_file_name = event['Records'][0]['s3']['object']['key']
    json_object = s3_client.get_object(Bucket="bucket-json",Key="client_data")
    #file_reader = json_object.get()['Body'].read().decode("utf-8")
    print("##PRINT")
    print(event)
    print(json_file_name)
    print(bucket)
    print(json_object)
#    file_reader = ast.literal_eval(file_reader)
#    table = dynamodb_client.Table('client_data')
#    table.put_item(Item=file_reader)
#    return 'success'
