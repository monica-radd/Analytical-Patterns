
 CREATE TYPE season_stats AS (
                        season INTEGER,
                        gp INTEGER,
                        pts REAL,
                         reb REAL,
                        ast REAL
                    );

                   
CREATE TABLE players (
     player_name TEXT,
     height TEXT,
     college TEXT,
     country TEXT,
     draft_year TEXT,
     draft_round TEXT,
     draft_number TEXT,
     season_stats season_stats[],
     --scoring_class scorer_class,
     --is_active BOOLEAN,
     current_season INTEGER,
     PRIMARY KEY (player_name, current_season)
 );