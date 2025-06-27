import os
import json
from jwt import decode, PyJWKClient, InvalidTokenError

COGNITO_REGION = os.getenv("COGNITO_REGION", "us-east-1")
COGNITO_USERPOOL_ID = os.getenv("COGNITO_USERPOOL_ID", "your_user_pool_id")
COGNITO_CLIENT_ID = os.getenv("COGNITO_CLIENT_ID", "your_app_client_id")

COGNITO_ISSUER = (
    f"https://cognito-idp.{COGNITO_REGION}.amazonaws.com/{COGNITO_USERPOOL_ID}"
)
JWKS_URL = f"{COGNITO_ISSUER}/.well-known/jwks.json"
jwk_client = PyJWKClient(JWKS_URL)


def verify_cognito_token(auth_header: str):
    if not auth_header or not auth_header.startswith("Bearer "):
        raise ValueError("Missing or invalid Authorization header")

    token = auth_header.split(" ")[1]

    try:
        signing_key = jwk_client.get_signing_key_from_jwt(token)
        payload = decode(
            token,
            signing_key.key,
            algorithms=["RS256"],
            audience=COGNITO_CLIENT_ID,
            issuer=COGNITO_ISSUER,
        )
        return payload
    except InvalidTokenError as e:
        raise ValueError(f"Token verification failed: {str(e)}")


def lambda_handler(event, context):
    # API Gateway Proxy integration structure
    try:
        headers = event.get("headers", {})
        auth_header = headers.get("Authorization") or headers.get("authorization")

        user = verify_cognito_token(auth_header)

        return {
            "statusCode": 200,
            "body": json.dumps(
                {
                    "sub": user.get("sub"),
                    "email": user.get("email"),
                    "groups": user.get("cognito:groups", []),
                    "claims": user,
                }
            ),
            "headers": {"Content-Type": "application/json"},
        }

    except ValueError as e:
        return {
            "statusCode": 401,
            "body": json.dumps({"error": str(e)}),
            "headers": {"Content-Type": "application/json"},
        }
