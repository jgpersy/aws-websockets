import boto3
from json import loads
import redis
from lambda_logging import log_config
from os import environ

logger = log_config('websockets_sendmessage', environ['LOG_LEVEL'])

cache = None

TOPIC_PREFIX = "websocket-topic-"

def handler(event, context):
    event_body = loads(event["body"])
    topic = event_body["topic"]
    message = event_body['message']

    elasticache_endpoint = environ["ELASTICACHE_ENDPOINT"]

    global cache
    if cache is None:
        logger.debug('Creating new redis connection')
        cache = redis.Redis(host=elasticache_endpoint, port=6379, decode_responses=True, ssl=True)

    connection_ids = cache.lrange("websocket-topic-" + topic, 0, -1)

    stage_name = environ.get("API_GW_STAGE_NAME", "")
    api_id = environ.get("API_GW_ID", "")
    region = environ.get("AWS_REGION", "eu-west-1")

    api_gw_mmgmt_api = boto3.client("apigatewaymanagementapi",
                                    endpoint_url=f"https://{api_id}.execute-api.{region}.amazonaws.com/{stage_name}")

    logger.debug(f"Posting message to topic: {topic}, \n{message}")
    for connection_id in connection_ids:
        if event["requestContext"]["connectionId"] != connection_id:
            try:
                logger.debug(f"Posting message to connection id: {connection_id}")
                api_gw_mmgmt_api.post_to_connection(
                    ConnectionId=connection_id,
                    Data=f"{message}"
                )
            except Exception as e:
                print(f"Error: {e}")

    return {
        'statusCode': 200,
        'body': 'Message sent'
    }
