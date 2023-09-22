#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table --no-align --tuples-only -c"

ELEMENT_LOOKUP() {

  ELEMENT=$1

  if [[ ! $ELEMENT ]]
  then
    echo "Please provide an element as an argument."
    exit
  fi

  if [[ $ELEMENT =~ ^[0-9]+$ ]]
  then
    ATOMIC_NUMBER=$ELEMENT
    NAME=$($PSQL "SELECT name from ELEMENTS where atomic_number = '$ELEMENT'")
  elif [[ ${#ELEMENT} < 3 ]]
  then
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE LOWER(symbol) = LOWER('$ELEMENT')")
    NAME=$($PSQL "SELECT name from ELEMENTS where atomic_number = '$ATOMIC_NUMBER'")
  else
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE LOWER(name) = LOWER('$ELEMENT')")
    NAME=$($PSQL "SELECT name from ELEMENTS where atomic_number = '$ATOMIC_NUMBER'")
  fi

  if [[ -z $NAME ]]
  then
    echo "I could not find that element in the database."
    exit
  fi

  SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE atomic_number = '$ATOMIC_NUMBER'")
  TYPE=$($PSQL "SELECT type FROM types LEFT JOIN properties ON types.type_id = properties.type_id LEFT JOIN elements ON properties.atomic_number = elements.atomic_number where properties.atomic_number = '$ATOMIC_NUMBER'")
  MASS=$($PSQL "SELECT atomic_mass FROM properties WHERE atomic_number = '$ATOMIC_NUMBER'")
  MELTING_POINT=$($PSQL "SELECT melting_point_celsius FROM properties WHERE atomic_number = '$ATOMIC_NUMBER'")
  BOILING_POINT=$($PSQL "SELECT boiling_point_celsius FROM properties WHERE atomic_number = '$ATOMIC_NUMBER'")

  echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."

}

ELEMENT_LOOKUP $1
