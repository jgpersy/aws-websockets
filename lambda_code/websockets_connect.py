import boto3
from os import environ
import ssl
from pymemcache.client.base import Client

def handler(event, context):
    print(event)
    print(context)



    context = ssl.create_default_context()
    cluster_endpoint = "websockets-cache-ax0tfv.serverless.euw1.cache.amazonaws.com"
    target_port = 11211
    memcached_client = Client((f"{cluster_endpoint}", target_port), tls_context=context)
    memcached_client.set("key", "value", expire=500, noreply=False)
    assert memcached_client.get("key").decode() == "value"

    dynamodb = boto3.resource('dynamodb')

    table = dynamodb.Table(environ.get("DYNAMODB_TABLE_NAME", ""))
    pk = environ.get("DYNAMODB_TABLE_PKEY", "")

    table.put_item(
        Item={
            f'{pk}': f'{event["requestContext"]["connectionId"]}',
        }
    )
    return {
        'statusCode': 200,
        'body': 'Connected'
    }
