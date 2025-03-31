from dataclasses import dataclass

from typing import Dict
from .base_model import BaseModel


@dataclass
class Match(BaseModel):
    match_id: int
    home_team_id: int
    away_team_id: int
    status: str
    winner_team_id: int
    venue: str
    home_score: int
    away_score: int
    season_competition_id: int = 1

    @classmethod
    def from_json(cls, json_data: Dict):
        teamsDataJson = json_data.get('teamsData', {})
        teamsData = list(teamsDataJson.values()) if isinstance(teamsDataJson, dict) else []
        team1Json = teamsData[0] if len(teamsData) > 0 else {}
        team2Json = teamsData[1] if len(teamsData) > 1 else {}

        return cls(
            match_id=json_data.get('wyId', 0),
            home_team_id=team1Json.get('teamId', 0),
            away_team_id=team2Json.get('teamId', 0),
            status=json_data.get('status', ''),
            winner_team_id=json_data.get('winner', 0),
            venue=json_data.get('venue', ''),
            home_score=team1Json.get('score', 0),
            away_score=team2Json.get('score', 0),
        )
