from os import environ

import redis

cache = None

TOPIC_PREFIX = "websocket-topic-"

def handler(event, context):
    elasticache_endpoint = environ["ELASTICACHE_ENDPOINT"]

    global cache
    if cache is None:
        cache = redis.Redis(host=elasticache_endpoint, port=6379, decode_responses=True, ssl=True)

    topics = []
    cursor = '0'
    while cursor != 0:
        cursor, new_topics = cache.scan(cursor, match=TOPIC_PREFIX + "*")
        topics.extend(new_topics)

    for topic in topics:
        cache.lrem(topic, 0, event["requestContext"]["connectionId"])

    return {
        'statusCode': 200,
        'body': 'Connected'
    }
