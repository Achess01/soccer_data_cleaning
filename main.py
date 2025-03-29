from json_to_sql import JsonToSqlGenerator


if __name__ == "__main__":
    # Crear el generador
    generator = JsonToSqlGenerator()

    # Procesar un archivo de jugadores
    generator.process_player_file('json/players.json')
