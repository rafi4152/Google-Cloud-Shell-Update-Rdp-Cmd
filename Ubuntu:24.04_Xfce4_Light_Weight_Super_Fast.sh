#!/bin/bash

clear
echo "===================================================="
echo "   [1/3] INSTALLING LIGHTWEIGHT XFCE4 & OBS STUDIO  "
echo "===================================================="

# ১. সিস্টেম আপডেট এবং শুধুমাত্র প্রয়োজনীয় লাইটওয়েট প্যাকেজ ইনস্টল
sudo apt update -y
sudo DEBIAN_FRONTEND=noninteractive apt install --assume-yes \
    xfce4 x11-utils xvfb dbus-x11 software-properties-common wget curl ffmpeg

# ২. ওবিএস স্টুডিও ইনস্টল (ফাস্ট ইনস্টলেশন)
sudo add-apt-repository ppa:obsproject/obs-studio -y && sudo apt update -y
sudo DEBIAN_FRONTEND=noninteractive apt install --assume-yes obs-studio

# ৩. ক্রোম ও ক্রোম রিমোট ডেক্সটপ ইনস্টল
wget -q https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb
sudo dpkg -i chrome-remote-desktop_current_amd64.deb || sudo apt --fix-broken install -y

wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb || sudo apt --fix-broken install -y

# XFCE সেশন কনফিগার ও জাঙ্ক ফাইল ক্লিন
sudo bash -c 'echo "exec /etc/X11/Xsession /usr/bin/xfce4-session" > /etc/chrome-remote-desktop-session'
rm -f chrome-remote-desktop_current_amd64.deb google-chrome-stable_current_amd64.deb
clear

echo "===================================================="
echo "           CHROME REMOTE DESKTOP SETUP              "
echo "===================================================="
echo "সাজেশন (Quick Guide):"
echo "১. যান: https://remotedesktop.google.com/headless"
echo "২. Authorize করে Debian Linux এর কোডটি কপি করুন।"
echo "===================================================="
echo ""

# সিরিয়াল ১: Auth Code ইনপুট
read -p "পাসপোর্ট/অথেন্টিকেশন কোডটি দিন (শুধু --code=\"...\" অংশটি): " AUTH_CODE

# সিরিয়াল ২: পিন কোড ইনপুট
echo ""
read -s -p "Enter 6-Digit PIN: " RDP_PIN
echo ""
read -s -p "Confirm 6-Digit PIN: " RDP_PIN_CONFIRM
echo ""

if [ "$RDP_PIN" != "$RDP_PIN_CONFIRM" ]; then
    echo "Error: PIN মেলেনি!"
    exit 1
fi

echo "===================================================="
echo "   [2/3] STARTING LIGHTWEIGHT RDP HOST...           "
echo "===================================================="

sudo groupadd chrome-remote-desktop 2>/dev/null
sudo usermod -a -G chrome-remote-desktop $USER

# হোস্ট স্টার্ট
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
echo "এখন আরডিপি স্ক্রিনটি দেখতে নিচের লিংকে যান:"
echo "👉 https://remotedesktop.google.com/access"
echo "===================================================="

# সেশন ধরে রাখার লুপ
seq 1 43200 | while read i; do 
    echo -en "\r RDP Running Active . $i s / 43200 s"; sleep 1
done
