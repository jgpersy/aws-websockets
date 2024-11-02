import boto3
from os import environ


def handler(event, context):
    print(event)
    print(context)
    dynamodb = boto3.resource('dynamodb')

    table = dynamodb.Table(environ.get("DYNAMODB_TABLE_NAME", ""))
    pk = environ.get("DYNAMODB_TABLE_PKEY", "")

    table.put_item(
        Item={
            f'{pk}': f'{event["requestContext"]["connectionId"]}',
        }
    )
    return {
        'statusCode': 200,
        'body': 'Connected'
    }
