#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=number_guess --tuples-only -c"

HANDLE_USERNAME() {

  # ask for name
  echo "Enter your username:"
  read USERNAME_INPUT

  # check if user is new
  USERNAME_EXIST=$($PSQL "SELECT username FROM users WHERE username = '$USERNAME_INPUT'")
  if [[ -z $USERNAME_EXIST ]]; then
    INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME_INPUT')")
    echo "Welcome, $USERNAME_INPUT! It looks like this is your first time here."
  else
    GET_TRIES=$($PSQL "SELECT best_game FROM users WHERE username = '$USERNAME_INPUT'")
    GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username = '$USERNAME_INPUT'")
    echo "Welcome back, $(echo $USERNAME_EXIST | sed -r 's/^ *| *$//g')! You have played $(echo $GAMES_PLAYED | sed -r 's/^ *| *$//g') games, and your best game took $(echo $GET_TRIES | sed -r 's/^ *| *$//g') guesses."
  fi
}

HANDLE_NUMBER() {

  echo "Guess the secret number between 1 and 1000:"

  while true; do
    read NUMBER_INPUT

    # check if input is integer
    if [[ ! $NUMBER_INPUT =~ ^[0-9]+$ ]]; then
      echo "That is not an integer, guess again:"
    else
      HANDLE_GAME
      break
    fi
  done
}

HANDLE_GAME() {

  NUMBER=$(( RANDOM % 1000 + 1 ))
  TRIES=1

  while true; do
    if [[ $NUMBER_INPUT -lt $NUMBER ]]; then
      echo "It's higher than that, guess again:"
      read NUMBER_INPUT
      (( TRIES++ ))
    elif [[ $NUMBER_INPUT -gt $NUMBER ]]; then
      echo "It's lower than that, guess again:"
      read NUMBER_INPUT
      (( TRIES++ ))
    else
      GAMES_PLAYED=$((GAMES_PLAYED + 1))
      UPDATE_GAMES_PLAYED=$($PSQL "UPDATE users SET games_played = $GAMES_PLAYED WHERE username = '$USERNAME_INPUT'")
      echo "You guessed it in $TRIES tries. The secret number was $NUMBER. Nice job!"
      if [[ $TRIES -lt $GET_TRIES ]] || [[ -z $GET_TRIES ]]; then
        INSERT_TRIES=$($PSQL "UPDATE users SET best_game = $TRIES WHERE username = '$USERNAME_INPUT'")
      fi
      break
    fi
  done
}

HANDLE_USERNAME
HANDLE_NUMBER
