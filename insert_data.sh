#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database. 
# wyczyszczenie zawartosci tabel games i teams

echo $($PSQL "TRUNCATE TABLE games, teams;")

#zaczytanie csv z rozgrywkami, "," jako znak podziału, zaczytanie roku (YEAR), rundy (ROUND), zwycięzcy (WIN), przeciwnika (OPP), liczbę goli zwycięzcy (WIN_G), liczbę goli przeciwnika (OPP_G)

cat games.csv | while IFS="," read YEAR ROUND WIN OPP WIN_G OPP_G

do 

# pominięcie pierwszej linijki
  if [[ $WIN != "winner" ]]

    then 

# przypisanie do WIN_ID team_id dla zespołu WIN (zwycięzcy) 

    WIN_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WIN'")
    
# jeśli team_id dla zwycięcy nie istenieje, do tabeli dodawany jest nowy element (WIN) i automatycznie przypisywany jest mu team_id

      if [[ -z $WIN_ID ]] 
        then
        INSERT_WIN_RESULT=$($PSQL "INSERT INTO teams(name) values('$WIN')")

          if [[ $INSERT_WIN_RESULT == "INSERT 0 1" ]]
            then
            echo "Inserted into teams (winner), $WIN"
          fi
	WIN_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WIN'")
      fi

# przypisanie do OPP_ID team_id dla zespołu OPP (przeciwnika)

   OPP_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPP'")

      if [[ -z $OPP_ID ]] 
        then
        INSERT_OPP_RESULT=$($PSQL "INSERT INTO teams(name) values('$OPP')")

          if [[ $INSERT_OPP_RESULT == "INSERT 0 1" ]]
            then
            echo "Inserted into teams (opponent), $OPP"
          fi
        OPP_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPP'")
      fi
  fi

# zapełnienie tabeli games 
INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WIN_ID, $OPP_ID, $WIN_G, $OPP_G)")

done
