#!/bin/bash
sudo apt install mysql-server -y
sudo apt update -y
sudo pm2 startup
sudo pm2 save
