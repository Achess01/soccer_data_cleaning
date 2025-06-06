import json
import pandas as pd
from dataclasses import asdict
from typing import List, Dict
from models import Player, Team, BaseModel, Match
from pathlib import Path


class JsonToSqlGenerator:
    def __init__(self):
        self.scripts = {
            'teams': [],
            'areas': [],
            'roles': [],
            'players': [],
            'team_player': [],
            'matches': []
        }

    def save(self):
        self._save_scripts_to_files()

    def load_json_file(self, file_path: str) -> List[Dict]:
        """Carga un archivo JSON y devuelve una lista de diccionarios"""
        with open(file_path, 'r', encoding='utf-8') as file:
            file_content = file.read()  # Leer todo el contenido como string
            data = json.loads(file_content)

        return data

    def json_to_objects(self, json_data: List[Dict], class_type) -> List[BaseModel]:
        return [class_type.from_json(item) for item in json_data]

    def process_player_file(self, file_path: str):
        """Procesa un archivo de jugadores y genera scripts SQL"""
        # Cargar y convertir datos
        json_data = self.load_json_file(file_path)
        players = self.json_to_objects(json_data, Player)

        # Convertir a DataFrames de pandas
        df_players = pd.DataFrame([asdict(p) for p in players])

        # Extraer áreas únicas (versión corregida)
        df_passport_areas = pd.json_normalize(
            df_players['passportArea'].dropna())
        df_birth_areas = pd.json_normalize(df_players['birthArea'].dropna())

        # SOLUCIÓN: Conservar solo la primera ocurrencia de cada ID
        df_areas = pd.concat([df_passport_areas, df_birth_areas]).drop_duplicates(
            'location_area_id', keep='first')

        # Extraer roles únicos
        df_roles = pd.json_normalize(
            df_players['role'].dropna()).drop_duplicates('role_id', keep='first')

        # Generar scripts SQL
        self._generate_area_script(df_areas)
        self._generate_role_script(df_roles)
        self._generate_player_script(df_players)

        # Guardar scripts en archivos

        print(
            f"Procesados {len(players)} jugadores, {len(df_areas)} áreas y {len(df_roles)} roles")

    def process_teams_file(self, file_path: str):
        json_data = self.load_json_file(file_path)
        teams = self.json_to_objects(json_data, Team)
        df_teams = pd.DataFrame([asdict(t) for t in teams])
        self._generate_teams_script(df_teams)
        print(f"Procesados {len(df_teams)} equipos")

    def process_matches_file(self, file_path: str):
        json_data = self.load_json_file(file_path)
        matches = self.json_to_objects(json_data, Match)
        df_matches = pd.DataFrame([asdict(t) for t in matches])
        self._generate_matches_script(df_matches)
        print(f"Procesados {len(df_matches)} partidos")

    def _generate_matches_script(self, df_teams: pd.DataFrame):
        """Genera script SQL para áreas"""
        if df_teams.empty:
            return
        # Generar INSERT statements
        for _, row in df_teams.iterrows():
            insert = f"""INSERT INTO match (season_competition_id, home_team_id, away_team_id, status, winner_team_id, venue, home_score, away_score)
VALUES ({row['season_competition_id']}, {row['home_team_id']}, {row['away_team_id']}, '{row['status']}', {row['winner_team_id']}, N'{row['venue'].replace("'", "''")}', {row['home_score']}, {row['away_score']});
"""
            self.scripts['matches'].append(insert)

    def _generate_teams_script(self, df_teams: pd.DataFrame):
        """Genera script SQL para áreas"""
        if df_teams.empty:
            return
        # Generar INSERT statements
        for _, row in df_teams.iterrows():
            insert = f"""INSERT INTO team (team_id, type, city, name)
VALUES ({row['team_id']}, '{row['type']}', N'{row['city'].replace("'", "''")}', N'{row['name'].replace("'", "''")}');

"""
            self.scripts['teams'].append(insert)

    def _generate_area_script(self, df_areas: pd.DataFrame):
        """Genera script SQL para áreas"""
        if df_areas.empty:
            return
        # Generar INSERT statements
        for _, row in df_areas.iterrows():
            insert = f"""INSERT INTO location_area (location_area_id, name, alpha_3_code, alpha_2_code)
VALUES ({row['location_area_id']}, N'{row['name'].replace("'", "''")}', '{row['alpha_3_code']}', '{row['alpha_2_code']}');
"""
            self.scripts['areas'].append(insert)

    def _generate_role_script(self, df_roles: pd.DataFrame):
        """Genera script SQL para roles"""
        if df_roles.empty:
            return

        # Generar INSERT statements
        for _, row in df_roles.iterrows():
            insert = f"""INSERT INTO role (role_id, code3, name)
VALUES ('{row['role_id']}', '{row['code3']}', N'{row['name'].replace("'", "''")}');
"""
            self.scripts['roles'].append(insert)

    def _generate_player_script(self, df_players: pd.DataFrame):
        """Genera script SQL para jugadores"""
        if df_players.empty:
            return
        # Generar INSERT statements
        for _, row in df_players.iterrows():
            # Manejar valores nulos
            passport_id = f"'{row['passportArea']['location_area_id']}" if pd.notna(
                row['passportArea']) else 'NULL'
            birth_id = f"'{row['birthArea']['location_area_id']}" if pd.notna(
                row['birthArea']) else 'NULL'
            role_code = f"'{row['role']['role_id']}'" if pd.notna(
                row['role']) else 'NULL'

            insert = f"""INSERT INTO player (
    player_id, first_name, middle_name, last_name, short_name, birth_date,
    weight, height, foot, passport_area_id, birth_area_id, role_id,
)
VALUES (
    {row['player_id']},
    N'{row['first_name'].replace("'", "''")}',
    N'{row['middle_name'].replace("'", "''")}',
    N'{row['last_name'].replace("'", "''")}',
    N'{row['short_name'].replace("'", "''")}',
    '{row['birth_date']}',
    {row['weight']},
    {row['height']},
    '{row['foot']}',
    {passport_id},
    {birth_id},
    {role_code},
);
"""
            self.scripts['players'].append(insert)

            if (row['currentTeamId'] is not None and row['currentTeamId'] != "null"):
                insert_team_player = f"""INSERT INTO team_player (
    player_id, team_id, dorsal,
)
VALUES ({row['player_id']}, {row['currentTeamId']}, 1);
"""
                self.scripts['team_player'].append(insert_team_player)

            if (row['currentNationalTeamId'] is not None and row['currentNationalTeamId'] != "null"):
                insert_team_player = f"""INSERT INTO team_player (
    player_id, team_id, dorsal,
)
VALUES ({row['player_id']}, {row['currentNationalTeamId']}, 1);
"""
                self.scripts['team_player'].append(insert_team_player)

    def _save_scripts_to_files(self):
        Path("sql_scripts").mkdir(parents=True, exist_ok=True)
        """Guarda los scripts SQL en archivos separados"""
        inserts = ''
        for _, script_lines in self.scripts.items():
            inserts += '\n'.join(script_lines)

        if inserts:  # Solo crear archivo si hay contenido
            with open(f'sql_scripts/entity_inserts.sql', 'w', encoding='utf-8') as f:
                f.write(inserts)
