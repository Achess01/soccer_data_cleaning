-- Jugador con más goles en la temporada
SELECT TOP 1 
    p.player_id,
    p.first_name + ' ' + p.last_name AS player_name,
    t.name AS team_name,
    COUNT(*) AS goals_scored
FROM 
    match_event me
JOIN 
    event e ON me.event_id = e.event_id
JOIN 
    tag_match_event tme ON me.match_event_id = tme.match_event_id
JOIN 
    tag tg ON tme.tag_id = tg.tag_id
JOIN 
    player p ON me.player_id = p.player_id
JOIN 
    team t ON me.team_id = t.team_id
WHERE 
    e.name = 'Pass' AND tg.name = 'goal'
GROUP BY 
    p.player_id, p.first_name, p.last_name, t.name
ORDER BY 
    goals_scored DESC;

-- 5 equipos con mayor cantidad de puntos obtenidos como visitantes
SELECT TOP 5 
    t.team_id,
    t.name AS team_name,
    SUM(CASE 
        WHEN m.away_score > m.home_score THEN 3
        WHEN m.away_score = m.home_score THEN 1
        ELSE 0
    END) AS away_points
FROM 
    match m
JOIN 
    team t ON m.away_team_id = t.team_id
GROUP BY 
    t.team_id, t.name
ORDER BY 
    away_points DESC;

-- Portero con más partidos con portería a 0
SELECT TOP 1 
    p.player_id,
    p.first_name + ' ' + p.last_name AS goalkeeper_name,
    t.name AS team_name,
    COUNT(DISTINCT m.match_id) AS clean_sheets
FROM 
    player p
JOIN 
    player_match pm ON p.player_id = pm.player_id
JOIN 
    match m ON pm.match_id = m.match_id
JOIN 
    team t ON pm.team_id = t.team_id
JOIN 
    role r ON p.role_id = r.role_id
WHERE 
    r.name = 'Goalkeeper' AND
    ((pm.team_id = m.home_team_id AND m.away_score = 0) OR
     (pm.team_id = m.away_team_id AND m.home_score = 0))
GROUP BY 
    p.player_id, p.first_name, p.last_name, t.name
ORDER BY 
    clean_sheets DESC;

-- Jugador con mejor promedio de goles por minuto (mínimo 500 minutos)
WITH PlayerMinutes AS (
    SELECT 
        p.player_id,
        p.first_name + ' ' + p.last_name AS player_name,
        SUM(CASE 
            WHEN pm.is_starter = 1 THEN 90
            ELSE 30 -- Asumiendo que los sustitutos juegan en promedio 30 minutos
        END) AS total_minutes
    FROM 
        player p
    JOIN 
        player_match pm ON p.player_id = pm.player_id
    GROUP BY 
        p.player_id, p.first_name, p.last_name
    HAVING 
        SUM(CASE WHEN pm.is_starter = 1 THEN 90 ELSE 30 END) >= 500
),
PlayerGoals AS (
    SELECT 
        p.player_id,
        COUNT(*) AS total_goals
    FROM 
        match_event me
    JOIN 
        event e ON me.event_id = e.event_id
    JOIN 
        tag_match_event tme ON me.match_event_id = tme.match_event_id
    JOIN 
        tag tg ON tme.tag_id = tg.tag_id
    JOIN 
        player p ON me.player_id = p.player_id
    WHERE 
        e.name = 'Shot' AND tg.name = 'goal'
    GROUP BY 
        p.player_id
)
SELECT TOP 1 
    pm.player_id,
    pm.player_name,
    pg.total_goals,
    pm.total_minutes,
    CAST(pg.total_goals AS FLOAT) / pm.total_minutes AS goals_per_minute
FROM 
    PlayerMinutes pm
JOIN 
    PlayerGoals pg ON pm.player_id = pg.player_id
ORDER BY 
    goals_per_minute DESC;

-- Partidos con mayor cantidad de goles combinados
SELECT TOP 5 
    m.match_id,
    ht.name AS home_team,
    at.name AS away_team,
    m.home_score,
    m.away_score,
    m.home_score + m.away_score AS total_goals
FROM 
    match m
JOIN 
    team ht ON m.home_team_id = ht.team_id
JOIN 
    team at ON m.away_team_id = at.team_id
ORDER BY 
    total_goals DESC;

-- Jugador con más tarjetas amarillas y su equipo

SELECT TOP 1 
    p.player_id,
    p.first_name + ' ' + p.last_name AS player_name,
    t.name AS team_name,
    COUNT(*) AS yellow_cards
FROM 
    match_event me
JOIN 
    event e ON me.event_id = e.event_id
JOIN 
    tag_match_event tme ON me.match_event_id = tme.match_event_id
JOIN 
    tag tg ON tme.tag_id = tg.tag_id
JOIN 
    player p ON me.player_id = p.player_id
JOIN 
    team t ON me.team_id = t.team_id
WHERE 
    e.name = 'Card' AND tg.name = 'yellow'
GROUP BY 
    p.player_id, p.first_name, p.last_name, t.name
ORDER BY 
    yellow_cards DESC;

-- Promedio de goles por partido en la liga y equipos por encima
WITH LeagueAvg AS (
    SELECT 
        AVG(home_score + away_score) AS avg_goals_per_match
    FROM 
        match
),
TeamStats AS (
    SELECT 
        t.team_id,
        t.name AS team_name,
        AVG(CASE 
            WHEN m.home_team_id = t.team_id THEN m.home_score
            ELSE m.away_score
        END) AS avg_goals_scored,
        AVG(CASE 
            WHEN m.home_team_id = t.team_id THEN m.away_score
            ELSE m.home_score
        END) AS avg_goals_conceded
    FROM 
        team t
    JOIN 
        match m ON t.team_id = m.home_team_id OR t.team_id = m.away_team_id
    GROUP BY 
        t.team_id, t.name
)
SELECT 
    (SELECT avg_goals_per_match FROM LeagueAvg) AS league_avg_goals_per_match,
    ts.team_id,
    ts.team_name,
    ts.avg_goals_scored + ts.avg_goals_conceded AS team_total_avg_goals
FROM 
    TeamStats ts
WHERE 
    ts.avg_goals_scored + ts.avg_goals_conceded > (SELECT avg_goals_per_match FROM LeagueAvg)
ORDER BY 
    team_total_avg_goals DESC;

-- Equipos con mejor diferencia de goles en los últimos 10 minutos
WITH LateGoals AS (
    SELECT 
        m.match_id,
        m.home_team_id,
        m.away_team_id,
        SUM(CASE 
            WHEN me.team_id = m.home_team_id AND me.match_period = '2H' AND me.event_sec >= 80*60 THEN 1
            ELSE 0
        END) AS home_late_goals,
        SUM(CASE 
            WHEN me.team_id = m.away_team_id AND me.match_period = '2H' AND me.event_sec >= 80*60 THEN 1
            ELSE 0
        END) AS away_late_goals
    FROM 
        match m
    JOIN 
        match_event me ON m.match_id = me.match_id
    JOIN 
        event e ON me.event_id = e.event_id
    JOIN 
        tag_match_event tme ON me.match_event_id = tme.match_event_id
    JOIN 
        tag tg ON tme.tag_id = tg.tag_id
    WHERE 
        e.name = 'Pass' AND tg.name = 'goal'
    GROUP BY 
        m.match_id, m.home_team_id, m.away_team_id
)
SELECT 
    t.team_id,
    t.name AS team_name,
    SUM(CASE 
        WHEN lg.home_team_id = t.team_id THEN lg.home_late_goals - lg.away_late_goals
        ELSE lg.away_late_goals - lg.home_late_goals
    END) AS late_goal_difference
FROM 
    team t
JOIN 
    LateGoals lg ON t.team_id = lg.home_team_id OR t.team_id = lg.away_team_id
GROUP BY 
    t.team_id, t.name
ORDER BY 
    late_goal_difference DESC;

-- Jugadores con más asistencias y sus promedios por partido
WITH PlayerAssists AS (
    SELECT 
        p.player_id,
        p.first_name + ' ' + p.last_name AS player_name,
        t.name AS team_name,
        COUNT(*) AS total_assists,
        COUNT(DISTINCT me.match_id) AS matches_with_assists
    FROM 
        match_event me
    JOIN 
        event e ON me.event_id = e.event_id
    JOIN 
        tag_match_event tme ON me.match_event_id = tme.match_event_id
    JOIN 
        tag tg ON tme.tag_id = tg.tag_id
    JOIN 
        player p ON me.player_id = p.player_id
    JOIN 
        team t ON me.team_id = t.team_id
    WHERE 
        e.name = 'Pass' AND tg.name = 'assist'
    GROUP BY 
        p.player_id, p.first_name, p.last_name, t.name
),
PlayerMatches AS (
    SELECT 
        p.player_id,
        COUNT(DISTINCT pm.match_id) AS total_matches_played
    FROM 
        player p
    JOIN 
        player_match pm ON p.player_id = pm.player_id
    GROUP BY 
        p.player_id
)
SELECT TOP 10 
    pa.player_id,
    pa.player_name,
    pa.team_name,
    pa.total_assists,
    pm.total_matches_played,
    CAST(pa.total_assists AS FLOAT) / pm.total_matches_played AS assists_per_match
FROM 
    PlayerAssists pa
JOIN 
    PlayerMatches pm ON pa.player_id = pm.player_id
ORDER BY 
    total_assists DESC, assists_per_match DESC;

-- Penales anotados por equipo y porcentaje de efectividad
WITH PenaltyAttempts AS (
    SELECT 
        t.team_id,
        t.name AS team_name,
        COUNT(*) AS penalty_attempts,
        SUM(CASE WHEN tg.name = 'goal' THEN 1 ELSE 0 END) AS penalty_goals
    FROM 
        match_event me
    JOIN 
        event e ON me.event_id = e.event_id
    JOIN 
        tag_match_event tme ON me.match_event_id = tme.match_event_id
    JOIN 
        tag tg ON tme.tag_id = tg.tag_id
    JOIN 
        team t ON me.team_id = t.team_id
    WHERE 
        e.name = 'Shot' AND tg.name IN ('goal', 'missed', 'saved') AND
        EXISTS (
            SELECT 1 FROM tag_match_event tme2 
            JOIN tag tg2 ON tme2.tag_id = tg2.tag_id
            WHERE tme2.match_event_id = me.match_event_id AND tg2.name = 'penalty'
        )
    GROUP BY 
        t.team_id, t.name
)
SELECT 
    team_id,
    team_name,
    penalty_attempts,
    penalty_goals,
    CASE 
        WHEN penalty_attempts = 0 THEN 0
        ELSE CAST(penalty_goals AS FLOAT) / penalty_attempts * 100
    END AS success_percentage
FROM 
    PenaltyAttempts
ORDER BY 
    penalty_goals DESC, success_percentage DESC;

-- Jugadores sustituidos más veces y minutos más frecuentes
WITH Substitutions AS (
    SELECT 
        p.player_id,
        p.first_name + ' ' + p.last_name AS player_name,
        t.name AS team_name,
        COUNT(*) AS substitution_count,
        AVG(me.event_sec / 60) AS avg_substitution_minute
    FROM 
        match_event me
    JOIN 
        event e ON me.event_id = e.event_id
    JOIN 
        player p ON me.player_id = p.player_id
    JOIN 
        team t ON me.team_id = t.team_id
    WHERE 
        e.name = 'Substitution' AND
        EXISTS (
            SELECT 1 FROM tag_match_event tme 
            JOIN tag tg ON tme.tag_id = tg.tag_id
            WHERE tme.match_event_id = me.match_event_id AND tg.name = 'out'
        )
    GROUP BY 
        p.player_id, p.first_name, p.last_name, t.name
)
SELECT TOP 10 
    player_id,
    player_name,
    team_name,
    substitution_count,
    ROUND(avg_substitution_minute, 2) AS avg_substitution_minute
FROM 
    Substitutions
ORDER BY 
    substitution_count DESC, avg_substitution_minute;
