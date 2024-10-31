from os import environ
from json import dumps
from datetime import datetime
import boto3

def handler(event, context):
    stage_name = environ.get("API_GW_STAGE_NAME", "")
    api_id = environ.get("API_GW_ID", "")
    region = environ.get("AWS_REGION", "eu-west-1")
    connection_id = event["requestContext"]["connectionId"]

    api_gw_mmgmt_api = boto3.client("apigatewaymanagementapi",
                                    endpoint_url=f"https://{api_id}.execute-api.{region}.amazonaws.com/{stage_name}")

    connection_info = api_gw_mmgmt_api.get_connection(ConnectionId=connection_id)

    for key in connection_info:
        if isinstance(connection_info[key], datetime):
            connection_info[key] = connection_info[key].isoformat()

    try:
        api_gw_mmgmt_api.post_to_connection(
        ConnectionId=connection_id,
        Data=f"Send a message:\n"
             f" {{\"action\": \"sendmessage\", \"topic\": \"YOUR_TOPIC_HERE\", \"message\": \"YOUR_MSG_HERE\"}} \n\n"
             f"Subscribe to a topic:\n"
             f" {{\"action\": \"subscribe\", \"topic\": \"YOUR_TOPIC_HERE\"}} \n\n"
             f"Your connection info: \n{dumps(connection_info)}"
    )
    except Exception as e:
        print(f"Error: {e}")

    return {
        'statusCode': 200,
        'body': 'Default route, info message returned'
    }