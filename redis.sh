#!/bin/bash

LOGS_FOLDER="/var/log/roboshop"
sudo mkdir -p $LOGS_FOLDER
sudo chown -R ec2-user:ec2-user $LOGS_FOLDER
LOGS_FILE="$LOGS_FOLDER/redis.log"

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
N="\e[0m"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

if [ $USERID -ne 0 ]; then
    echo -e "$TIMESTAMP [ERROR] Run as root $R FAILED $N" | tee -a $LOGS_FILE
    exit 1
fi

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$TIMESTAMP [ERROR] $2 $R FAILED $N" | tee -a $LOGS_FILE
        exit 1
    else
        echo -e "$TIMESTAMP [INFO] $2 $G SUCCESS $N" | tee -a $LOGS_FILE
    fi
}

echo "$TIMESTAMP [INFO] Installing Redis 7..." | tee -a $LOGS_FILE

dnf module disable redis -y &>> $LOGS_FILE
dnf module enable redis:7 -y &>> $LOGS_FILE
VALIDATE $? "Enabling Redis module"

dnf install redis -y &>> $LOGS_FILE
VALIDATE $? "Installing Redis"


cp /etc/redis/redis.conf /etc/redis/redis.conf.bkp &>> $LOGS_FILE

sed -i 's/^bind 127.0.0.1/bind 0.0.0.0/' /etc/redis/redis.conf &>> $LOGS_FILE


sed -i 's/^protected-mode yes/protected-mode no/' /etc/redis/redis.conf &>> $LOGS_FILE

VALIDATE $? "Configuring Redis"


systemctl daemon-reload &>> $LOGS_FILE
systemctl enable redis &>> $LOGS_FILE
systemctl start redis &>> $LOGS_FILE

VALIDATE $? "Starting Redis"


redis-cli ping &>> $LOGS_FILE
VALIDATE $? "Redis health check"