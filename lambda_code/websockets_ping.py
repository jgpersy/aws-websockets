import boto3
from lambda_logging import log_config
from os import environ

logger = log_config('websockets_ping', environ['LOG_LEVEL'])

def handler(event, context):

    stage_name = environ.get("API_GW_STAGE_NAME", "")
    api_id = environ.get("API_GW_ID", "")
    region = environ.get("AWS_REGION", "eu-west-1")

    api_gw_mmgmt_api = boto3.client("apigatewaymanagementapi",
                                    endpoint_url=f"https://{api_id}.execute-api.{region}.amazonaws.com/{stage_name}")
    try:
        logger.debug(f"Replying to connection id: {event['requestContext']['connectionId']}, IP: {event['requestContext']['identity']['sourceIp']}")
        api_gw_mmgmt_api.post_to_connection(
            ConnectionId=event["requestContext"]["connectionId"],
            Data="PONG"
        )
    except Exception as e:
        print(f"Error: {e}")

    return {
        'statusCode': 200,
        'body': 'PONG'
    }