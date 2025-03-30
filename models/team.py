
from dataclasses import dataclass
from models.base_model import BaseModel


@dataclass
class Team(BaseModel):
    team_id: int
    type: str
    city: str
    name: str

    @classmethod
    def from_json(cls, json_data: dict) -> 'Team':
        """Crea una instancia de Team a partir de un diccionario JSON."""
        return cls(
            team_id=json_data['wyId'],
            type=json_data['type'],
            city=json_data['city'],
            name=json_data['name']
        )
