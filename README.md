# Analytical-Patterns

Applying analytical patterns to the tables : **players**, **team**, **games**,

1. A query that does state change tracking for **players**

    1.1 A player entering the league should be 'New'
    1.2 A player leaving the league should be 'Retired'
    1.3 A player staying in the league should be 'Continued Playing'
    1.4 A player that comes out of retirement should be 'Returned from Retirement'
    1.5 A player that stays out of the league should be 'Stayed Retired'

2.  A query that uses GROUPING SETS to do efficient aggregations of **game_details** data
    Aggregate this dataset along the following dimensions
           2.1  player and team -  Answer questions like who scored the most points playing for one team?
           2.2  player and season - Answer questions like who scored the most points in one season?
           2.3  team - Answer questions like which team has won the most games?

3.  A query that uses window functions on **game_details** to find out the following things:

      3.1 What is the most games a team has won in a 90 game stretch?
      3.2 How many games in a row did LeBron James score over 10 points a game?
