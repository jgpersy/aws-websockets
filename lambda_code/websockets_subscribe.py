from json import loads
import redis
from lambda_logging import log_config
from os import environ

logger = log_config('websockets_subscribe', environ['LOG_LEVEL'])

cache = None

TOPIC_PREFIX = "websocket-topic-"

def handler(event, context):
    elasticache_endpoint = environ["ELASTICACHE_ENDPOINT"]

    global cache
    if cache is None:
        logger.debug('Creating new redis connection')
        cache = redis.Redis(host=elasticache_endpoint, port=6379, decode_responses=True, ssl=True)

    logger.debug(f"Subscribing connection id: {event['requestContext']['connectionId']} to topic: {loads(event['body'])['topic']}")
    cache.lpush(TOPIC_PREFIX + loads(event["body"])["topic"], event["requestContext"]["connectionId"])
    return {
        'statusCode': 200,
        'body': 'Subscribed'
    }
