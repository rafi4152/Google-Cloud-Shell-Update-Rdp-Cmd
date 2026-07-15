#!/bin/bash

# Prevent any interactive prompt freezes
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

clear
echo "===================================================="
echo "   [1/3] PRE-INSTALLING ESSENTIAL CORE PACKAGES     "
echo "===================================================="
# ফেইলুর ঠেকাতে ছোট ছোট বেসিক প্যাকেজগুলো সবার আগে ইনস্টল করে নেওয়া
sudo apt-get update -y -qq
sudo apt-get install -y -qq curl wget gnupg2 software-properties-common apt-transport-https &>/dev/null

clear
echo "===================================================="
echo "          CHROME REMOTE DESKTOP SETUP              "
echo "===================================================="
echo "INSTRUCTIONS:"
echo "1. Go to: https://remotedesktop.google.com/headless"
echo "2. Login and click Authorize"
echo "3. Copy the Debian Linux command"
echo "===================================================="
echo ""

# সবার আগে ডেবিয়ান অথেন্টিকেশন কোড ও পিন ইনপুট ফিক্স করা
printf "👉 Paste Debian Auth Code (inside --code=\"...\"): "
ln -sf /dev/tty /dev/stdin 2>/dev/null
read -r AUTH_CODE < /dev/tty

echo ""
echo "----------------------------------------------------"
echo " Set your 6-digit RDP Login Password / PIN"
echo "----------------------------------------------------"
printf "👉 Enter VNC/RDP PIN: "
read -s -r RDP_PIN < /dev/tty
echo ""
printf "👉 Confirm VNC/RDP PIN: "
read -s -r RDP_PIN_CONFIRM < /dev/tty
echo ""

if [ "$RDP_PIN" != "$RDP_PIN_CONFIRM" ]; then
    echo "❌ Error: PIN codes do not match! Please run again."
    exit 1
fi

clear
echo "===================================================="
echo "   [2/3] RUNNING LIGHTWEIGHT GRAPHICS & OBS SETUP   "
echo "===================================================="

# লাইটওয়েট ডেক্সটপ এনভায়রনমেন্ট
sudo apt-get install -y -qq --no-install-recommends \
    xfce4 xfce4-goodies xvfb dbus-x11 ffmpeg

# ওবিএস স্টুডিও রিপোজিটরি ও ইনস্টল
sudo add-apt-repository ppa:obsproject/obs-studio -y &>/dev/null
sudo apt-get update -y -qq
sudo apt-get install -y -qq obs-studio

# ক্রোম রিমোট ডেক্সটপ ও অফিশিয়াল ক্রোম ব্রাউজার
wget -q https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb
sudo dpkg -i chrome-remote-desktop_current_amd64.deb || sudo apt-get install -f -y -qq

wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb || sudo apt-get install -f -y -qq

# সেশন পারমিশন সেটআপ
sudo bash -c 'echo "exec /etc/X11/Xsession /usr/bin/xfce4-session" > /etc/chrome-remote-desktop-session'
sudo groupadd chrome-remote-desktop 2>/dev/null
sudo usermod -a -G chrome-remote-desktop $USER

# জাঙ্ক ফাইল রিমুভ
rm -f chrome-remote-desktop_current_amd64.deb google-chrome-stable_current_amd64.deb

echo "===================================================="
echo "   [3/3] STARTING LIGHTWEIGHT RDP HOST...           "
echo "===================================================="

# রিমোট ডেক্সটপ হোস্ট সার্ভিস ব্যাকগ্রাউন্ডে চালু করা
/opt/google/chrome-remote-desktop/start-host \
    --code="$AUTH_CODE" \
    --redirect-url="https://remotedesktop.google.com/_/oauthredirect" \
    --name=$(hostname) \
    --pin="$RDP_PIN" &>/dev/null &

sleep 3
clear

echo "===================================================="
echo "   🎉 SUCCESS! LIGHTWEIGHT XFCE RDP IS ONLINE       "
echo "===================================================="
echo "👉 Access Link: https://remotedesktop.google.com/access"
echo "👉 Computer Name: $(hostname)"
echo "===================================================="

# একটিভ সেশন ধরে রাখার লুপ
seq 1 43200 | while read i; do 
    echo -en "\r RDP Running Active . $i s / 43200 s"; sleep 1
done
