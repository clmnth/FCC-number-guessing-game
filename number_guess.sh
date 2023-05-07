#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=number_guess --tuples-only -c"

# generate a random number
NUMBER=$($PSQL "SELECT floor(random() * 1000) + 1")

# ask for name
echo "Enter your username:"
read USERNAME_INPUT

USERNAME_EXIST=$($PSQL "SELECT username FROM users WHERE username = '$USERNAME_INPUT'")

# if user doesn't exist
if [[ -z $USERNAME_EXIST ]]; then
  echo "Welcome, $USERNAME_INPUT! It looks like this is your first time here."
  INSERT_USERNAME=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME_INPUT')") 
else
# if user exist
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username = '$USERNAME_INPUT'")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username = '$USERNAME_INPUT'")
  echo "Welcome back, $USERNAME_INPUT! You have played $(echo $GAMES_PLAYED | sed -r 's/^ *| *$//g') games, and your best game took $(echo $BEST_GAME | sed -r 's/^ *| *$//g') guesses."
fi

# ask for a number
echo "Guess the secret number between 1 and 1000:"
COUNTER=0

while true; do
  read NUMBER_INPUT
  
  # if input is not an integer
  if [[ ! $NUMBER_INPUT =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
  else
  # if input is an integer
    ((COUNTER++))
    if [[ $NUMBER_INPUT -gt $NUMBER ]]; then
      echo "It's lower than that, guess again:"
    elif [[ $NUMBER_INPUT -lt $NUMBER ]]; then
      echo "It's higher than that, guess again:"
    else
      echo "You guessed it in $COUNTER tries. The secret number was $(echo $NUMBER | sed -r 's/^ *| *$//g'). Nice job!"
      GAMES_PLAYED=$((GAMES_PLAYED + 1))
      UPDATE_GAMES_PLAYED=$($PSQL "UPDATE users SET games_played = $GAMES_PLAYED WHERE username = '$USERNAME_INPUT'")
      if [[ -z $BEST_GAME ]] || [[ $COUNTER -lt $BEST_GAME ]]; then
        UPDATE_BEST_GAME=$($PSQL "UPDATE users SET best_game = $COUNTER WHERE username = '$USERNAME_INPUT'")
        echo "You set a new best game with $COUNTER guesses!"
      fi
      break
    fi
  fi
done

 
