from fastapi import HTTPException, Header
from jwt import decode, PyJWKClient
import os

# --- Cognito settings (set via environment variables or .env) ---
COGNITO_REGION = os.getenv("COGNITO_REGION", "us-east-1")
COGNITO_USERPOOL_ID = os.getenv("COGNITO_USERPOOL_ID", "your_user_pool_id")
COGNITO_CLIENT_ID = os.getenv("COGNITO_CLIENT_ID", "your_client_id")
COGNITO_ISSUER = (
    f"https://cognito-idp.{COGNITO_REGION}.amazonaws.com/{COGNITO_USERPOOL_ID}"
)
JWKS_URL = f"{COGNITO_ISSUER}/.well-known/jwks.json"
jwk_client = PyJWKClient(JWKS_URL)


class auth:
    def verify_token(auth_header: str = Header(...)):
        if not auth_header.startswith("Bearer "):
            raise HTTPException(status_code=401, detail="Missing Bearer token")
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
        except Exception as e:
            raise HTTPException(status_code=401, detail=str(e))
