from json import loads, dumps

def handler(event, context):
    queryStringParameters = event['queryStringParameters']

    if queryStringParameters is None:
        return {
            'statusCode': 400,
            'body': dumps({'message': 'Missing queryStringParameters'})
        }
    if queryStringParameters["QueryString1"] == "queryValue1":
        response = generateAllow('me', event['methodArn'])

        return loads(response)
    else:
        return {
        'statusCode': 401,
        'body': dumps({'message': 'Unauthorized'})
    }

def generatePolicy(principalId, effect, resource):
    authResponse = {'principalId': principalId}
    if effect and resource:
        policyDocument = {'Version': '2012-10-17', 'Statement': []}
        statementOne = {'Action': 'execute-api:Invoke', 'Effect': effect, 'Resource': resource}
        policyDocument['Statement'] = [statementOne]
        authResponse['policyDocument'] = policyDocument

    # authResponse['context'] = {
    #     "stringKey": "stringval",
    #     "numberKey": 123,
    #     "booleanKey": True
    # }

    authResponse_JSON = dumps(authResponse)

    return authResponse_JSON


def generateAllow(principalId, resource):
    return generatePolicy(principalId, 'Allow', resource)