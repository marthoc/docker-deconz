#!/bin/bash

VERSION=0.5

echo "-------------------------------------------------------------------"
echo " "
echo "             marthoc/deconz Firmware Flashing Script"
echo " "
echo "                       Version: $VERSION"
echo " "
echo "-------------------------------------------------------------------"
echo " "
echo " "
echo "Listing attached devices..."
echo " "

/usr/bin/GCFFlasher_internal -l

echo " "
echo "Enter the full device path, or press Enter now to exit."
echo " "
read -p "Device Path : " deviceName

if [[ -z "${deviceName// }" ]]; then
        echo "Exiting..."
        exit 1
fi

echo " "
echo "-------------------------------------------------------------------"
echo " "
echo "Firmware available for flashing:"
echo " "

ls -1 /usr/share/deCONZ/firmware

echo " "
echo "Enter the firmware file name from above, including extension,"
echo "or press Enter now to exit."
echo " "

read -p "File Name : " fileName
echo " "
if [[ -z "${fileName// }" ]]; then
        echo "Exiting..."
        exit 1
fi

echo "-------------------------------------------------------------------"
echo " "
echo "Device: $deviceName"
echo " "
echo "Firmware File: $fileName"
echo " "
echo "Are the above device and firmware values correct?"
read -p "Enter Y to proceed, any other entry to exit: " correctVal

if [ "$correctVal" = "Y" ] || [ "$correctVal" = "y" ]; then
        echo " "
        echo "Flashing..."
        echo " "
        /usr/bin/GCFFlasher_internal -d $deviceName -f /usr/share/deCONZ/firmware/$fileName
        
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
