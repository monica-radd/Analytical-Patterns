#####	APPLYING ANALYTICAL PATTERNS

#### 	A query that does state change tracking for players : New ; Retried ; Continued playing ; Retruned from Retirement ; Stayed Retiered

with previous_state as (
		select 
			player_name,
			is_active,
			current_season,
			lag(is_active, 1) over (partition by player_name order by current_season) as prev_is_active
		from players
)

select 
	player_name,
	current_season,
	case 
		when prev_is_active is null and is_active = true then 'New'
		when prev_is_active = true and is_active = false then 'Retired'
		when prev_is_active = true and is_active = true then 'Continued Playing'
		when prev_is_active = false and is_active = true then 'Returned from Retirement'
		when prev_is_active = false and is_active = false then 'Stayed Retired' 
	end as state_change
from previous_state;

#### 	A query that uses GROUPING SETS to do efficient aggregations of game_details data
##		Aggregate this dataset along the following dimensions : player and team ; player and season  ; team 

create table grouping_sets as 
select 
	--gd.player_name , t.nickname, g.season, sum(coalesce (gd.pts,0)) as sum_pts
	gd.player_name,
	t.nickname as team,
	g.season,
	sum(coalesce (gd.pts,0)) as sum_pts,
	count (distinct 
			case 
				when (t.team_id = g.team_id_home and g.home_team_wins = 1)
                        or (t.team_id = g.team_id_away and g.home_team_wins = 0)
                    	then g.game_id
			end
	      ) as wins_count
	
from game_details gd 
left join games g on gd.game_id =  g.game_id 
left join teams t on gd.team_id = t.team_id
group by 
	grouping sets (
	
					(gd.player_name , t.nickname),
					(gd.player_name , g.season),
					(t.nickname)
			      );


			
## 	Aggregate this dataset as player and team - Answer questions like who scored the most points playing for one team?who scored the most points playing ##	 for one team?

/*
select *
from grouping_sets
where season is null and player_name is not null
order by sum_pts desc
*/

## 	Aggregate this dataset as player and season - Answer questions like who scored the most points in one season?

/*
select *
from grouping_sets
where team is null
order by sum_pts desc
*/

## 	Aggregate this dataset as team - Answer questions like which team has won the most games?

/*
select *
from grouping_sets
where
    season is null and player_name is null
order by wins_count desc
*/

####	A query that uses window functions on game_details to find out the following things:

##		What is the most games a team has won in a 90 game stretch?

with
    rolling_window as (
        select
            teams.nickname as team_name
            , game_date_est
            , sum(
                case
                    when
                        (teams.team_id = games.team_id_home and games.home_team_wins = 1)
                        or (teams.team_id = games.team_id_away and games.home_team_wins = 0)
                        then 1 else 0
                end
            )
            over (
                partition by teams.team_id
                order by games.game_date_est
                rows between 89 preceding and current row
            ) as rolling_wins_90_games
        from games
        join teams on
        	games.home_team_id = teams.team_id
        	or games.visitor_team_id = teams.team_id
    )

select
    team_name
    , max(rolling_wins_90_games) as max_rolling_wins_90_games
from rolling_window
group by team_name
order by max_rolling_wins_90_games desc;


##	How many games in a row did LeBron James score over 10 points a game?


with
    filter_lebron_10_points as (
        select
            game_id
            , pts
            , case when pts > 10 then 1 else 0 end as is_over_10_pts
            , row_number() over (order by game_id) -
                row_number() over (
                    partition by
                        case when pts > 10 then 1 else 0 end
                    order by game_id
                ) as streak_groups
        from game_details
        where player_name = 'LeBron James'
    )

    , streaks as (
        select
            streak_groups
            , count(1) as streak
        from filter_lebron_10_points
        where is_over_10_pts = 1
        group by streak_groups
    )

select max(streak) as max_streak_over_10_pts
from streaks
