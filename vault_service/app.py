from fastapi import FastAPI, Depends
from mangum import Mangum
from ..share.auth import auth
from routes.vault import router as vault_router

app = FastAPI()

app.include_router(vault_router)

# --- Lambda handler ---
handler = Mangum(app)
