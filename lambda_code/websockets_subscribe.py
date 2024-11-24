import boto3
from os import environ
from json import loads
import redis

TOPIC_PREFIX = "websocket-topic-"

def handler(event, context):

    elasticache_endpoint = environ["ELASTICACHE_ENDPOINT"]
    cache = redis.Redis(host=elasticache_endpoint, port=6379, decode_responses=True, ssl=True)

    cache.lpush(TOPIC_PREFIX + loads(event["body"])["topic"], event["requestContext"]["connectionId"])
    return {
        'statusCode': 200,
        'body': 'Connected'
    }
