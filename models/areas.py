from dataclasses import dataclass
from typing import Dict

from .base_model import BaseModel


@dataclass
class Area(BaseModel):
    location_area_id: int
    alpha_3_code: str
    alpha_2_code: str
    name: str

    @classmethod
    def from_json(cls, json_data: Dict):
        return cls(
            location_area_id=int(json_data.get('id', 0)),
            name=json_data.get('name', ''),
            alpha_3_code=json_data.get('alpha3code', ''),
            alpha_2_code=json_data.get('alpha2code', '')
        )

