#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --no-align --tuples-only -c"

echo -e "\n~~~~ MY SALON ~~~~\n"

echo -e "Welcome to My Salon, how can I help you?\n"

MAIN_MENU() {
	echo $1
	I=1
	while [[ $I < 5 ]] 
		do
  	SER=$($PSQL "SELECT name FROM services WHERE service_id=$I;")
  	echo "$I) $SER"
  	((I++))
	done

	read SERVICE_ID_SELECTED
	if [[ -z $($PSQL "SELECT * FROM services WHERE service_id=$SERVICE_ID_SELECTED") ]]
  then
		MAIN_MENU "I could not find that service. What would you like today?"
  else 
	  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
		#get phone
		echo -e "\nWhat's your phone number?" 
		read CUSTOMER_PHONE
		#check if known
		CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
	if [[ -z $CUSTOMER_ID ]]
	then 
		#if not ask for name
		echo -e "\nI don't have a record for that phone number, what's your name?" 
		IFS=$'\n\t\r' read CUSTOMER_NAME
		#insert customer if needed
		INSERT_CUST_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
		CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE name='$CUSTOMER_NAME'")
	else
		CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id=$CUSTOMER_ID")
	fi
	#ask for time
	echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
	read SERVICE_TIME
	#insert apt
	INSERT_APT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
	#confirm booking
	echo -e "\nI have put you down for a $( echo "$SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME" | sed -E 's/^ +| +$//g')."
fi
}

MAIN_MENU
