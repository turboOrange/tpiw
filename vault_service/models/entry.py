from pydantic import BaseModel


class search_model(BaseModel):
    url: str
    name: str


class read_model(BaseModel):
    id: str
