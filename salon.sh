#!/bin/bash

PSQL=$(echo "psql -t --username=freecodecamp --dbname=salon -c")

# salon program title:
echo -e "\n~~~~ Welcome to Bash Salon ~~~~\n"

MAIN_MENU() {

  # if any message is passed into the function, print it:
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  # the program's main menu, with user input:
  echo -e "Select the service you would like:\n1) Hair Cut\n2) Hair Wash\n3) Hair Dye\n4) Exit"
  read SERVICE_ID_SELECTED

  # check the user's input;
  # if not a number, display menu again with message:
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "You have not entered a number; please enter a number."
  else
    # check the number:
    # if not a valid service_id number (1-4), display menu again with message:
    # else, go ahead with selected service:
    case $SERVICE_ID_SELECTED in
    1) GET_CUSTOMER_INFO $SERVICE_ID_SELECTED ;;
    2) GET_CUSTOMER_INFO $SERVICE_ID_SELECTED ;;
    3) GET_CUSTOMER_INFO $SERVICE_ID_SELECTED ;;
    4) EXIT ;;
    *) MAIN_MENU "Please enter a valid menu number."
    esac

  fi

}

GET_CUSTOMER_INFO() {
  # the function will take in a service_id as $1.
  SERVICE_ID=$1

  # ask for the customer's phone number to check if the phone is in the database:
  echo -e "\nMay I get your phone number, first?"
  read CUSTOMER_PHONE

  CUSTOMER_PHONE_FROM_DATABASE=$($PSQL "SELECT phone FROM customers WHERE phone='$CUSTOMER_PHONE';")

  # if the phone isn't there, get the customer's name, register customer into the database:
  if [[ -z $CUSTOMER_PHONE_FROM_DATABASE ]]
  then
    echo -e "\nIt looks like you are not registered with us; please enter your name so we can register you:"
    read CUSTOMER_NAME

    # register new customer into the database:
    INSERT_NEW_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME');")
  else
    # the customer's name can be found in the database as the phone number is found in the database:
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE';")
  fi

  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")

  # now that the customer's info has been registered / taken, we can book them for an appointment.
  BOOK_APPOINTMENT $CUSTOMER_ID $CUSTOMER_PHONE $CUSTOMER_NAME $SERVICE_ID
}

BOOK_APPOINTMENT() {
  CUSTOMER_ID=$1
  CUSTOMER_PHONE=$2
  CUSTOMER_NAME=$3
  SERVICE_ID=$4
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID;")

  echo -e "\n$CUSTOMER_ID $CUSTOMER_PHONE $CUSTOMER_NAME\n"

  # ask them to give a time for their appointment:
  echo -e "\nAt what time would you like your appointment, $CUSTOMER_NAME?"
  read SERVICE_TIME

  # add an appointment:
  INSERT_NEW_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID, '$SERVICE_TIME');")
  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
}

EXIT() {
  echo -e "\nExiting program...\n"
}

MAIN_MENU
