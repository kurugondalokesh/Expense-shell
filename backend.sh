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

dnf module disable nodejs -y &>> $LOGS_FILE
VALIDATE $? "Disabling Node"

dnf module enable nodejs:20 -y &>> $LOGS_FILE
VALIDATE $? "Enabling Node"

dnf install nodejs -y &>> $LOGS_FILE
VALIDATE $? "Installing Node"

id expense &>> $LOGS_FILE

if [ $? -ne 0 ]
then
    echo "User is not created cating" | tee -a $LOGS_FILE
    useradd expense &>> $LOGS_FILE
    VALIDATE $? "Creating user"
else
    echo "User already created so skipping"
fi

mkdir -p /app

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>> $LOGS_FILE
VALIDATE $? "Downloading Backend application"

cd /app
rm -rf /app/* #remove the existing code
unzip /tmp/backend.zip &>> $LOGS_FILE
VALIDATE $? "Extracting code"

npm install &>> $LOGS_FILE
VALIDATE $? "Installing code"

cp /home/ec2-user/Expense-shell/backend.service /etc/systemd/system/backend.service &>> $LOGS_FILE
VALIDATE $? "Copying code"

#load the data before running Backend

dnf install mysql -y &>> $LOGS_FILE
VALIDATE $? "Installing mysql"

mysql -h 172.31.19.68 -uroot -pExpenseApp@1 < /app/schema/backend.sql &>> $LOGS_FILE
VALIDATE $? "Schema loading" 

systemctl daemon-reload &>> $LOGS_FILE
VALIDATE $? "Demon Reload"

systemctl enable backend &>> $LOGS_FILE
VALIDATE $? "Enable backend"

systemctl restart backend &>> $LOGS_FILE
VALIDATE $? "Restart backend"