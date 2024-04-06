def lambda_handler(event, context):
    
    response = {
        "statusCode": 200,
        "body": "Hello from Lambda!"
    }
    return response