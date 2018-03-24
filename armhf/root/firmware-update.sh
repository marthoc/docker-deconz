#!/bin/bash

VERSION=0.1

echo "------------------------------------------------------------"
echo " "
echo "   marthoc/deconz Conbee/RaspBee Firmware Flashing Script"
echo " "
echo "                    Version: $VERSION"
echo " "
echo "------------------------------------------------------------"
echo " "
echo "Enter the Conbee/RaspBee device number, or L to list devices"
echo " "
read -p "Device Number : " deviceNum

if [ "$deviceNum" = "L" ] || [ "$deviceNum" = "l" ]; then
        echo " "
        /usr/bin/GCFFlasher_internal -l
        echo " "
        echo "Enter the Conbee/RaspBee device number"
        echo " "
        read -p "Device Number : " deviceNum
fi

echo "------------------------------------------------------------"
echo " "
echo "Firmware available for flashing:"
echo " "

curl -s https://www.dresden-elektronik.de/rpi/deconz-firmware/ | grep deCONZ_Rpi_ | cut -d \> -f 7 | sed "s/...$//g" | grep -v .md5 | sort

echo " "
echo "------------------------------------------------------------"
echo " "
echo "Enter the firmware file name from above, including extension"
echo " "

read -p "File Name : " fileName

echo " "
echo "Downloading firmware file and MD5 signature..."
echo " "
echo "------------------------------------------------------------"

wget -O /$fileName http://dresden-elektronik.de/rpi/deconz-firmware/$fileName
wget -O /$fileName.md5 http://dresden-elektronik.de/rpi/deconz-firmware/$fileName.md5

echo "------------------------------------------------------------"
echo " "
echo "Comparing firmware file with MD5 signature..."
echo " "

cd /
md5sum -c $fileName.md5
retVal=$?

if [ $retVal != 0 ]; then
        echo " "
        echo "MD5 mismatch! Exiting..."
        echo " "
        exit 1
else
        echo " "
        echo "MD5 match!"
        echo " "
fi

echo "------------------------------------------------------------"
echo " "
echo "Device Number: $deviceNum"
echo " "
echo "Firmware File: $fileName"
echo " "
echo "------------------------------------------------------------"
echo " "
read -p "Are the above device and firmware values correct? Y or N: " correctVal

if [ "$correctVal" = "Y" ] || [ "$correctVal" = "y" ]; then
        echo " "
        echo "Flashing..."
        echo " "
        /usr/bin/GCFFlasher_internal -d $deviceNum -f /$fileName
        retVal=$?
        if [ $retVal != 0 ]; then
                echo " "
                echo "Flashing Error! Please re-run this script..."
                echo " "
                exit $retVal
        fi
else
        echo " "
        echo "Exiting..."
        echo " "
        exit 1
fi
