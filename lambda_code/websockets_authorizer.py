from json import loads, dumps
from os import environ
from lambda_logging import log_config

logger = log_config('websockets_authorizer', environ['LOG_LEVEL'])


def handler(event, context):

    headers = event['headers']
    if 'x-api-key' in headers:
        if headers['x-api-key'] == '1234':
            logger.debug('Authorized on api key')
            response = generate_allow('me', '*')
        else:
            logger.error('Unauthorized, incorrect api key')
            response = {
                'statusCode': 401,
                'body': dumps({'message': 'Unauthorized, incorrect api key'})
            }
        return loads(response)

    queryStringParameters = event['queryStringParameters']

    if queryStringParameters["QueryString1"] == "queryValue1":
        logger.debug('Authorized on query string value')
        response = generate_allow('me', '*')
    else:
        logger.error('Unauthorized, incorrect query string value')
        response = {
            'statusCode': 401,
            'body': dumps({'message': 'Unauthorized, incorrect query string value'})
        }
    return loads(response)


def generate_policy(principalId, effect, resource):
    authResponse = {'principalId': principalId}
    if effect and resource:
        policyDocument = {'Version': '2012-10-17', 'Statement': []}
        statementOne = {'Action': 'execute-api:Invoke', 'Effect': effect, 'Resource': resource}
        policyDocument['Statement'] = [statementOne]
        authResponse['policyDocument'] = policyDocument

    authResponse['context'] = {
        "stringKey": "stringval",
        "numberKey": 123,
        "booleanKey": True
    }

    authResponse_JSON = dumps(authResponse)

    return authResponse_JSON


def generate_allow(principalId, resource):
    return generate_policy(principalId, 'Allow', resource)
