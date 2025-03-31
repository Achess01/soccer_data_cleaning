from json_to_sql import JsonToSqlGenerator


if __name__ == "__main__":
    # Crear el generador
    generator = JsonToSqlGenerator()

    generator.process_teams_file('json/teams.json')
    generator.process_player_file('json/players.json')
    generator.process_matches_file('json/matches_England.json')
    generator.save()
