#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE TABLE games, teams")

#read the games.csv file to insert data into teams and games tables
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != "year" ]]
  then
    #insert data to teams table
    #get team_id for winner
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")

    #if not found
    if [[ -z $WINNER_ID ]]
    then
      #insert team
      INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]
      then
        echo Inserted into teams, $WINNER
      fi
    
      #get new team_id
      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    fi

    #get team_id for opponent
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

    #if not found
    if [[ -z $OPPONENT_ID ]]
    then
      #insert team
      INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]
      then
        echo Inserted into teams, $OPPONENT
      fi
    
      #get new team_id
      OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    fi

    #insert data to games table
    #get game_id
    GAME_ID=$($PSQL "SELECT game_id FROM games WHERE winner_id=$WINNER_ID AND round='$ROUND' AND year=$YEAR")
    
    #if not found
    if [[ -z $GAME_ID ]]
    then
      #insert game
      INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
      if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
      then
        echo Inserted into games, $YEAR $ROUND $WINNER $OPPONENT $WINNER_GOALS $OPPONENT_GOALS
      fi

      #get new game_id
      GAME_ID=$($PSQL "SELECT game_id FROM games WHERE winner_id=$WINNER_ID AND round='$ROUND' AND year=$YEAR")
    fi
  fi
done