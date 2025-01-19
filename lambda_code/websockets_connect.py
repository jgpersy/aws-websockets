from lambda_logging import log_config
from os import environ

logger = log_config('websockets_connect', environ['LOG_LEVEL'])

def handler(event, context):

    logger.debug(f'Connected with connection id: {event["requestContext"]["connectionId"]} from {event["requestContext"]["identity"]["sourceIp"]}')

    return {
        'statusCode': 200,
        'body': 'Connected'
    }


