import json
import boto3
import os

# Initialize Bedrock client
bedrock = boto3.client(
    service_name='bedrock-runtime',
    region_name=os.environ.get('AWS_REGION', 'us-east-1')
)

def lambda_handler(event, context):
    try:
        # Parse the incoming request
        body = json.loads(event.get('body', '{}'))
        user_message = body.get('message', '')
        
        if not user_message:
            return {
                'statusCode': 400,
                'body': json.dumps({'error': 'No message provided'})
            }

        # Educational system prompt
        system_prompt = (
            "You are an educational chatbot designed to help users learn new concepts clearly and interactively. "
            "Provide step-by-step explanations, simple examples, and ask follow-up questions to engage the learner. "
            "Avoid jargon and make learning enjoyable."
        )
#         system_prompt = (
#     "You are a compassionate health and wellness chatbot focused on guiding users toward healthier lifestyles. "
#     "Provide reliable, evidence-based advice on nutrition, fitness, sleep, and stress management. "
#     "Use an encouraging tone, explain concepts in simple terms, and personalize responses based on user needs. "
#     "Avoid medical jargon and always remind users to consult a healthcare professional for serious concerns."
# )
        # Prepare the request for Claude 3
        model_id = 'us.anthropic.claude-3-7-sonnet-20250219-v1:0'
        
        request_body = json.dumps({
            "anthropic_version": "bedrock-2023-05-31",
            "system": system_prompt,  
            "max_tokens": 200,
            "top_k": 250,
            "stop_sequences": [],
            "temperature": 1,
            "top_p": 0.999,
            "messages": [
                {
                    "role": "user",
                    "content": [
                        {
                            "type": "text",
                            "text": user_message
                        }
                    ]
                }
            ]
        })


        # Call Bedrock API
        response = bedrock.invoke_model(
            modelId=model_id,
            contentType="application/json",
            accept="application/json",
            body=request_body
        )

        # Parse the response
        response_body = json.loads(response['body'].read())
        assistant_message = response_body.get('content', [{}])[0].get('text', '').strip()

        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'message': assistant_message
            })
        }

    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': 'Internal server error',
                'message': str(e)
            })
        }