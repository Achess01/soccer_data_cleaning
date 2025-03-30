from dataclasses import dataclass
from typing import Dict

from models import Area, Role
from .base_model import BaseModel


@dataclass
class Player(BaseModel):
    player_id: int
    first_name: str
    middle_name: str
    last_name: str
    short_name: str
    birth_date: str
    weight: int
    height: int
    foot: str
    passportArea: Area
    birthArea: Area
    role: Role
    currentTeamId: int
    currentNationalTeamId: int

    @classmethod
    def from_json(cls, json_data: Dict):
        passport_area = Area.from_json(
            json_data['passportArea']) if 'passportArea' in json_data else None
        birth_area = passport_area = Area.from_json(
            json_data['birthArea']) if 'birthArea' in json_data else None
        role = Role.from_json(
            json_data['role']) if 'role' in json_data else None

        if (json_data['currentNationalTeamId'] is None):
            print(json_data)

        return cls(
            player_id=int(json_data.get('wyId')),
            first_name=json_data.get('firstName', ''),
            middle_name=json_data.get('middleName', ''),
            last_name=json_data.get('lastName', ''),
            short_name=json_data.get('shortName', ''),
            birth_date=json_data.get('birthDate'),
            weight=json_data.get('weight'),
            height=json_data.get('height'),
            foot=json_data.get('foot', ''),
            passportArea=passport_area,
            birthArea=birth_area,
            role=role,
            currentTeamId=json_data.get('currentTeamId', None),
            currentNationalTeamId=json_data.get('currentNationalTeamId', None)
        )
