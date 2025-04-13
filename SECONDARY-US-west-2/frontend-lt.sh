#!/bin/bash
sudo apt update -y
sleep 90
sudo systemctl start apache2.service
sudo systemctl enable apache2.service