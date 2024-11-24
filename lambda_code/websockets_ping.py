import boto3
from os import environ

def handler(event, context):

    stage_name = environ.get("API_GW_STAGE_NAME", "")
    api_id = environ.get("API_GW_ID", "")
    region = environ.get("AWS_REGION", "eu-west-1")

    api_gw_mmgmt_api = boto3.client("apigatewaymanagementapi",
                                    endpoint_url=f"https://{api_id}.execute-api.{region}.amazonaws.com/{stage_name}")
    try:
        api_gw_mmgmt_api.post_to_connection(
            ConnectionId=event["requestContext"]["connectionId"],
            Data="PONG"
        )
    except Exception as e:
        print(f"Error: {e}")

    return {
        'statusCode': 200,
        'body': 'Connected'
    }