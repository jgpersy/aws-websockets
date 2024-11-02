import boto3
from os import environ
from json import loads

from boto3.dynamodb.conditions import Attr


def handler(event, context):
    dynamodb = boto3.resource('dynamodb')

    stage_name = environ.get("API_GW_STAGE_NAME", "")
    api_id = environ.get("API_GW_ID", "")
    region = environ.get("AWS_REGION", "eu-west-1")
    table = dynamodb.Table(environ.get("DYNAMODB_TABLE_NAME", ""))
    pk = environ.get("DYNAMODB_TABLE_PKEY", "")

    api_gw_mmgmt_api = boto3.client("apigatewaymanagementapi",
                                    endpoint_url=f"https://{api_id}.execute-api.{region}.amazonaws.com/{stage_name}")

    event_body = loads(event["body"])
    topic = event_body["topic"]

    results = table.scan(
        FilterExpression=Attr('Topic').eq(f'{topic}'),
    )

    connection_id = event["requestContext"]["connectionId"]
    message = event_body['message']

    for item in results['Items']:
        if item[f'{pk}'] != connection_id:
            print(f"Sending message {message} to {item[f'{pk}']}")
            try:
                api_gw_mmgmt_api.post_to_connection(
                    ConnectionId=item[f'{pk}'],
                    Data=f"{message}"
                )
            except Exception as e:
                print(f"Error: {e}")

    return {
        'statusCode': 200,
        'body': 'Connected'
    }
