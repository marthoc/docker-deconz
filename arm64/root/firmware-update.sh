#!/bin/bash

# ===========================
# Configuration
# ===========================
VERSION=0.7
FLASHER=/usr/bin/GCFFlasher_internal
FW_PATH=/usr/share/deCONZ/firmware/
FW_ONLINE_BASE=http://deconz.dresden-elektronik.de/deconz-firmware/

# ===========================
# exit functions
# ===========================
# ---------------------------
# Exit the script
# - on exit print 1st param or "Exiting..." as message
# - use 2nd param or 1 as exit-code
# ---------------------------
function exit_with_error() {
    typeset msg="${1:-Exiting...}"
    typeset -i retVal="${2:-1}"
    printf "\n%s\n\n" "$msg"
    exit $retVal
}

# ---------------------------
# Check last return-code or 2nd param
# - if non-zero exit with message
# - on exit print 1st param or "Exiting..." as message
# ---------------------------
function exit_on_error() {
    typeset -i retVal="${2:-$?}"
    typeset msg="$1"
    (( retVal == 0 )) || exit_with_error "$msg" $retVal
}

# ---------------------------
# Check last return-code or 3rd param
# - if non-zero exit with message
# - on exit remove file (1st param) if present
# - on exit print 2nd param or "Exiting..." as message
# ---------------------------
function delete_and_exit_on_error() {
    typeset -i retVal="${3:-$?}"
    typeset file="$1"
    typeset msg="$2"
    if (( retVal != 0 )); then
        [[ -f $file ]] && rm "$file"
        exit_with_error "$msg" $retVal
    fi
}

# ---------------------------
# Check 1st param as user-input
# - exit script on empty input
# ---------------------------
function exit_on_enter() {
    typeset input="$1"
    [[ -n $input ]] || exit_with_error
}

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

$FLASHER -l

echo " "
echo "Enter the full device path, or press Enter now to exit."
echo " "

read -p "Device path : " deviceName
exit_on_enter $deviceName

echo " "
echo "-------------------------------------------------------------------"
echo " "
echo "Firmware available for flashing:"
ls -1 "$FW_PATH"

echo " "
echo "Enter the firmware file name from above, including extension."
echo "Alternatively, you may enter the name of a firmware file to download"
echo "from $FW_ONLINE_BASE"
echo "or press Enter now to exit."
echo " "

read -p "File Name : " fileName
exit_on_enter $fileName

echo " "
filePath="${FW_PATH%/}/$fileName"
if [[ ! -f $filePath ]]; then
    echo "File not found locally. Try to download?"
    read -p "Enter Y to proceed, any other entry to exit: " answer
    [[ $answer == [yY] ]] || exit_with_error

    echo " "
    echo "Downloading..."
    echo " "
    curl --fail --output "$filePath" "${FW_ONLINE_BASE%/}/$fileName" && [[ -f $filePath ]]
    delete_and_exit_on_error "$filePath" "Download Error! Please re-run this script..."
    echo " "
    echo "Download complete! Checking md5 checksum..."
    md5=$(curl --fail --silent "${FW_ONLINE_BASE%/}/${fileName}.md5")
    [[ -n $md5 ]] || delete_and_exit_on_error "$filePath" "Checksum file '${fileName}.md5' not found! Please re-run this script..."
    echo "${md5% *} ${filePath}" | md5sum --check
    delete_and_exit_on_error "$filePath" "Error comparing checksums! Please re-run this script..."
    echo " "
fi

echo "-------------------------------------------------------------------"
echo " "
echo "Device ......: $deviceName"
echo "Firmware File: $fileName"
echo " "
echo "Are the above device and firmware values correct?"
read -p "Enter Y to proceed, any other entry to exit: " correctVal
[[ $correctVal == [yY] ]] || exit_with_error

echo " "
echo "Flashing..."
echo " "
$FLASHER -t 60 -d $deviceName -f "$filePath"
exit_on_error "Flashing Error! Please re-run this script..."
