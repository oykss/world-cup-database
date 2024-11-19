#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
CLEAR=$($PSQL "TRUNCATE TABLE games, teams RESTART IDENTITY;")

function check() {
    FIND_ID_TEAM=$($PSQL "SELECT team_id FROM teams WHERE name = '$1';")
    
    if [[ -z $FIND_ID_TEAM ]]; then
        TEAM_ID=$($PSQL "INSERT INTO teams(name) VALUES('$1')")
        TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$1';")
    else
        TEAM_ID=$FIND_ID_TEAM
    fi
}

while IFS=',' read -r YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
    if [[ $YEAR == 'year' ]]; then
        continue
    fi

    check "$WINNER"
    WINNER_ID=$TEAM_ID

    check "$OPPONENT"
    OPPONENT_ID=$TEAM_ID

    echo "Winner ID: $WINNER_ID"

    GAME=$($PSQL "INSERT INTO games (year, round, winner_id, opponent_id, winner_goals, opponent_goals)
                         VALUES ($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS);")
done < games.csv
