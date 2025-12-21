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

dnf install nginx -y &>> $LOGS_FILE
VALIDATE $? "Installing Nginx"

systemctl enable nginx &>> $LOGS_FILE
VALIDATE $? "Enabling Nginx"

systemctl start nginx &>> $LOGS_FILE
VALIDATE $? "Starting Nginx"

rm -rf /usr/share/nginx/html/* &>> $LOGS_FILE
VALIDATE $? "Removing Existing files"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>> $LOGS_FILE
VALIDATE $? "Downloading frontend code"

cd /usr/share/nginx/html
unzip /tmp/frontend.zip &>> $LOGS_FILE
VALIDATE $? "Extracting frontend code"

cp /home/ec2-user/Expense-shell/expense.conf /etc/nginx/default.d/expense.conf &>> $LOGS_FILE
VALIDATE $? "Copying frontend config"

systemctl restart nginx &>> $LOGS_FILE
VALIDATE $? "Restarting nginx"
