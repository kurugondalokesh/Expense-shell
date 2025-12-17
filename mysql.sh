#!/bin/bash

LOGS_FOLDER="/var/log/expense"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOGS_FILE="$LOGS_FOLDER/$SCRIPT_NAME-$TIMESTAMP.log"
mkdir -p $LOGS_FOLDER

USERID=$(id -u)

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

dnf install mysql-server -y &>>$LOGS_FILE
VALIDATE $? "Installing Mysql" 

systemctl enable mysqld &>>$LOGS_FILE   
VALIDATE $? "Enabling Mysql"

systemctl start mysqld &>>$LOGS_FILE
VALIDATE $? "Starting Mysql"

# mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOGS_FILE
# VALIDATE $? "Changing root password"


mysql -h 172.31.67.170 -u root -pExpenseApp@1 -e 'show databases' &>>$LOGS_FILE

if [ $? -ne 0 ]
then 
    mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOGS_FILE
else
    echo "Password already updated"
fi