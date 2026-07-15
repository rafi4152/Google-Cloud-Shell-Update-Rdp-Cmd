#!/bin/bash

# Bypass all interactive frontend prompts to prevent freezing
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

clear
echo "===================================================="
echo "          CHROME REMOTE DESKTOP SETUP              "
echo "===================================================="
echo "INSTRUCTIONS:"
echo "1. Go to: https://remotedesktop.google.com/headless"
echo "2. Login, click 'Begin' -> 'Next' -> 'Authorize'"
echo "3. Copy the command line for 'Debian Linux'"
echo "4. Paste only the inside of --code=\"...\" below"
echo "===================================================="
echo ""

# STEP 1: Request Authentication Code first to ensure no skip
read -p "Enter Auth Code (Only the value inside --code=): " AUTH_CODE

# STEP 2: Request 6-Digit PIN
echo ""
echo "----------------------------------------------------"
echo "Set a 6-digit PIN to connect to your RDP"
echo "----------------------------------------------------"
read -s -p "Enter 6-Digit PIN: " RDP_PIN
echo ""
read -s -p "Confirm 6-Digit PIN: " RDP_PIN_CONFIRM
echo ""

# Validation check for PIN matching
if [ "$RDP_PIN" != "$RDP_PIN_CONFIRM" ]; then
    echo "Error: PIN codes do not match! Please run the script again."
    exit 1
fi

clear
echo "===================================================="
echo "   [1/3] INSTANTLY INSTALLING LIGHTWEIGHT CORE...  "
echo "===================================================="

# Update and install minimal desktop core & ffmpeg silently
sudo apt-get update -y -qq
sudo apt-get install -y -qq --no-install-recommends \
    xfce4 xfce4-goodies xvfb dbus-x11 wget curl ffmpeg software-properties-common

# Install OBS Studio
sudo add-apt-repository ppa:obsproject/obs-studio -y
sudo apt-get update -y -qq
sudo apt-get install -y -qq obs-studio

# Download and install Chrome Remote Desktop & Google Chrome
wget -q https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb
sudo dpkg -i chrome-remote-desktop_current_amd64.deb || sudo apt-get install -f -y -qq

wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb || sudo apt-get install -f -y -qq

# Configure XFCE Session and permissions
sudo bash -c 'echo "exec /etc/X11/Xsession /usr/bin/xfce4-session" > /etc/chrome-remote-desktop-session'
sudo groupadd chrome-remote-desktop 2>/dev/null
sudo usermod -a -G chrome-remote-desktop $USER

# Clean up downloaded setup files to save space
rm -f chrome-remote-desktop_current_amd64.deb google-chrome-stable_current_amd64.deb

echo "===================================================="
echo "   [2/3] STARTING LIGHTWEIGHT RDP HOST...           "
echo "===================================================="

# Launch the Remote Desktop Host service in background
/opt/google/chrome-remote-desktop/start-host \
    --code="$AUTH_CODE" \
    --redirect-url="https://remotedesktop.google.com/_/oauthredirect" \
    --name=$(hostname) \
    --pin="$RDP_PIN" &>/dev/null &

sleep 3
clear

echo "===================================================="
echo "   [3/3] SUCCESS! LIGHTWEIGHT XFCE RDP IS ONLINE    "
echo "===================================================="
echo "INSTRUCTIONS TO ACCESS RDP:"
echo "1. Go to: https://remotedesktop.google.com/access"
echo "2. Click on your computer name: $(hostname)"
echo "3. Enter the 6-digit PIN you created earlier."
echo "===================================================="

# Keep-alive loop to maintain the Cloud Shell session active
seq 1 43200 | while read i; do 
    echo -en "\r RDP Running Active . $i s / 43200 s"; sleep 1
done
