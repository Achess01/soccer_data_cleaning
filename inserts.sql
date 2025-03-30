USE soccer_league;
GO

INSERT INTO competition (name)
VALUES (
    'Premier League'
);

INSERT INTO season (name)
VALUES (
    '2017-2018',
);

INSERT INTO season_competition(season_id, competition_id, description)
VALUES (
    1,
    1,
    'Premier League 2017-2018'
);