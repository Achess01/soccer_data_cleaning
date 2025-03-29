from dataclasses import dataclass

from typing import Dict
from .base_model import BaseModel


@dataclass
class Role(BaseModel):
    role_id: str
    code3: str
    name: str

    @classmethod
    def from_json(cls, json_data: Dict):
        return cls(
            role_id=json_data.get('code2', ''),
            code3=json_data.get('code3', ''),
            name=json_data.get('name', '')
        )
