import boto3
from os import environ
from json import loads


def handler(event, context):

    dynamodb = boto3.resource('dynamodb')

    table = dynamodb.Table(environ.get("DYNAMODB_TABLE_NAME", ""))
    pk = environ.get("DYNAMODB_TABLE_PKEY", "")

    table.put_item(
        Item={
            f'{pk}': f'{event["requestContext"]["connectionId"]}',
            'Topic': f'{loads(event["body"])["topic"]}'
        }
    )

    return {
        'statusCode': 200,
        'body': 'Connected'
    }