import boto3
from os import environ
from json import loads
import redis

TOPIC_PREFIX = "websocket-topic-"

def handler(event, context):
    event_body = loads(event["body"])
    topic = event_body["topic"]
    message = event_body['message']

    elasticache_endpoint = environ["ELASTICACHE_ENDPOINT"]
    cache = redis.Redis(host=elasticache_endpoint, port=6379, decode_responses=True, ssl=True)

    connection_ids = cache.lrange("websocket-topic-" + topic, 0, -1)

    stage_name = environ.get("API_GW_STAGE_NAME", "")
    api_id = environ.get("API_GW_ID", "")
    region = environ.get("AWS_REGION", "eu-west-1")

    api_gw_mmgmt_api = boto3.client("apigatewaymanagementapi",
                                    endpoint_url=f"https://{api_id}.execute-api.{region}.amazonaws.com/{stage_name}")

    for connection_id in connection_ids:
        if event["requestContext"]["connectionId"] != connection_id:
            try:
                api_gw_mmgmt_api.post_to_connection(
                    ConnectionId=connection_id,
                    Data=f"{message}"
                )
            except Exception as e:
                print(f"Error: {e}")

    return {
        'statusCode': 200,
        'body': 'Connected'
    }
