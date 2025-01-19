import redis
from lambda_logging import log_config
from os import environ

logger = log_config('websockets_disconnect', environ['LOG_LEVEL'])
cache = None

TOPIC_PREFIX = "websocket-topic-"

def handler(event, context):

    elasticache_endpoint = environ["ELASTICACHE_ENDPOINT"]

    global cache
    if cache is None:
        logger.debug('Creating new redis connection')
        cache = redis.Redis(host=elasticache_endpoint, port=6379, decode_responses=True, ssl=True)

    logger.debug("Building list of all websocket topics")
    topics = []
    cursor = '0'
    while cursor != 0:
        cursor, new_topics = cache.scan(cursor, match=TOPIC_PREFIX + "*")
        topics.extend(new_topics)

    logger.debug("Removing connection id from all topics")
    for topic in topics:
        cache.lrem(topic, 0, event["requestContext"]["connectionId"])

    return {
        'statusCode': 200,
        'body': 'Disconnected'
    }
