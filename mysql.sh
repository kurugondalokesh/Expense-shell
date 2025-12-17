#!/bin/bash

$LOGS_FOLDER="/var/log/expense"
$SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
$TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
$LOGS_FILE="$LOGS_FOLDER/$SCRIPT_NAME-$TIMESTAMP.log"
mkdir -p $LOGS_FOLDER

$USERID=$(id -u)

CHECKROOT (){
    if [ $USERID -ne 0 ]
    then
        echo "PLease runt the script with root privelages" | tee -a $LOGS_FILE
        exit 1
    fi
}

VALIDATE (){
    if [ $1 -ne 0 ]
    then
        echo "$2 is Failed" | tee -a $LOGS_FILE
        exit 1
    else
        echo "$2 is success" | tee -a $LOGS_FILE
    fi
}


echo "Script started executing at $(date)" | tee -a $LOGS_FILE

CHECKROOT

dnf install mysql-server -y
VALIDATE $? "Installing Mysql" | tee -a $LOGS_FILE

systemctl enable mysqld
VALIDATE $? "Enabling Mysql" | tee -a $LOGS_FILE

systemctl start mysqld
VALIDATE $? "Starting Mysql" | tee -a $LOGS_FILE

mysql_secure_installation --set-root-pass ExpenseApp@1
VALIDATE $? "Changing root password" | tee -a $LOGS_FILE

