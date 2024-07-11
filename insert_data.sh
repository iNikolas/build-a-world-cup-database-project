#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

insert_team_if_not_exists() {
  local team_name=$1
  local team_id=$($PSQL "SELECT team_id FROM teams WHERE name='$team_name'")
  
  if [[ -z $team_id ]]
  then
    local insert=$($PSQL "INSERT INTO teams(name) VALUES('$team_name')")
    team_id=$($PSQL "SELECT team_id FROM teams WHERE name='$team_name'")
  fi
  
  echo "$team_id"
}

$PSQL "TRUNCATE TABLE games, teams;"

cat games.csv | while IFS=',' read -r YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ "$WINNER" == "winner" || "$OPPONENT" == "opponent" ]]
  then
    continue
  fi

  TEAM_WINNER_ID=$(insert_team_if_not_exists "$WINNER")
  TEAM_OPPONENT_ID=$(insert_team_if_not_exists "$OPPONENT")

  INSERT_GAMES_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $TEAM_WINNER_ID, $TEAM_OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
done
