from fastapi import APIRouter, Depends
from vault_service.models.entry import *
from share.auth import auth

router = APIRouter()


@router.post("/vault/search")
def list_vault_entries(request: search_model, user=Depends(auth.verify_token)):
    return {"message": "Vault entries would go here.", "user_id": user.get("sub")}


@router.post("/vault/read")
def create_vault_entry(request: read_model, user=Depends(auth.verify_token)):
    return {"message": "Vault entry created.", "user_id": user.get("sub")}
