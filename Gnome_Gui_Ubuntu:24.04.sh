#!/bin/bash

# ১. সিস্টেম রিসোর্স অপ্টিমাইজেশন ও প্যাকেজ আপডেট
echo "===================================================="
echo "    [1/6] Optimizing Resources & Updating System     "
echo "===================================================="
# ভার্চুয়াল মেমোরি বুস্ট (Swap space এমুলেশন ট্রিক)
sudo dd if=/dev/zero of=/swapfile bs=1M count=2048 > /dev/null 2>&1
sudo chmod 600 /swapfile > /dev/null 2>&1
sudo mkswap /swapfile > /dev/null 2>&1
sudo swapon /swapfile > /dev/null 2>&1

sudo apt update -y && sudo apt upgrade -y

# ২. লেটেস্ট উবুন্টু জিইউআই (GNOME) ও বেসিক প্যাকেজসমূহ ইনস্টল করা
echo "===================================================="
echo "    [2/6] Installing Full Ubuntu GNOME GUI & Tools  "
echo "===================================================="
# বেসিক সফটওয়্যার ম্যানেজমেন্ট এবং নেটওয়ার্কিং টুলসসহ ইনস্টল
sudo DEBIAN_FRONTEND=noninteractive apt install --assume-yes \
    ubuntu-desktop gnome-shell dbus-x11 xscreensaver x11-utils xvfb \
    software-properties-common build-essential curl wget git zip unzip nano \
    p7zip-full gdebi-core apt-transport-https ca-certificates synaptic

# ৩. OBS Studio ইনস্টল করা (অফিশিয়াল PPA থেকে লেটেস্ট ভার্সন)
echo "===================================================="
echo "    [3/6] Installing OBS Studio (Latest Version)    "
echo "===================================================="
sudo add-apt-repository ppa:obsproject/obs-studio -y
sudo apt update -y
sudo DEBIAN_FRONTEND=noninteractive apt install --assume-yes obs-studio ffmpeg

# ৪. ক্রোম রিমোট ডেক্সটপ এবং ক্রোম ব্রাউজার ইনস্টল করা
echo "===================================================="
echo "    [4/6] Installing Chrome Remote Desktop & Chrome "
echo "===================================================="
wget -q https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb
sudo dpkg -i chrome-remote-desktop_current_amd64.deb || sudo apt --fix-broken install -y

wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb || sudo apt --fix-broken install -y

# GNOME সেশন কনফিগার (Chrome Remote Desktop এর জন্য)
sudo bash -c 'echo "exec /etc/X11/Xsession /usr/bin/gnome-session" > /etc/chrome-remote-desktop-session'

# ফালতু ফাইল ক্লিন করে স্টোরেজ খালি করা
rm -f chrome-remote-desktop_current_amd64.deb google-chrome-stable_current_amd64.deb
sudo apt autoremove -y && sudo apt clean
clear

# ৫. সিরিয়াল অনুযায়ী ইনপুট ও সাজেশন পার্ট
echo "===================================================="
echo "       FULL POWER UBUNTU 24.04 RDP WITH OBS         "
echo "===================================================="
echo "সাজেশন (Step-by-Step Guide):"
echo "১. প্রথমে এই লিংকে যান: https://remotedesktop.google.com/headless"
echo "২. 'Begin' -> 'Next' -> 'Authorize' এ ক্লিক করুন।"
echo "৩. 'Debian Linux' এর পাশে থাকা কপি বাটনে ক্লিক করে পুরো কোডটি কপি করুন।"
echo "৪. সেই কোডের ভেতর থেকে শুধুমাত্র --code=\"৪/xxxx\" অংশটুকু নিচে পেস্ট করুন।"
echo "===================================================="
echo ""

# সিরিয়াল ১: Auth Code চাওয়া
read -p "পাসপোর্ট/অথেন্টিকেশন কোডটি দিন (--code= এর ভেতরের অংশটুকু): " AUTH_CODE

# সিরিয়াল ২: পিন কোড চাওয়া
echo ""
echo "----------------------------------------------------"
echo "আরডিপি কানেক্ট করার জন্য একটি ৬ ডিজিটের পিন (PIN) দিন"
echo "----------------------------------------------------"
read -s -p "Enter 6-Digit PIN: " RDP_PIN
echo ""
read -s -p "Confirm 6-Digit PIN: " RDP_PIN_CONFIRM
echo ""

# পিন ম্যাচিং চেক
if [ "$RDP_PIN" != "$RDP_PIN_CONFIRM" ]; then
    echo "Error: PIN মেলেনি! দয়া করে স্ক্রিপ্টটি আবার রান করুন।"
    exit 1
fi

# ৬. আরডিপি হোস্ট চালু করা
echo ""
echo "===================================================="
echo "    [5/6] Starting Remote Desktop Host Container... "
echo "===================================================="

sudo groupadd chrome-remote-desktop 2>/dev/null
sudo usermod -a -G chrome-remote-desktop $USER

/opt/google/chrome-remote-desktop/start-host \
    --code="$AUTH_CODE" \
    --redirect-url="https://remotedesktop.google.com/_/oauthredirect" \
    --name=$(hostname) \
    --pin="$RDP_PIN" &>/dev/null &

sleep 5
clear

# ফাইনাল স্ট্যাটাস ও সাজেশন ডিসপ্লে
echo "===================================================="
echo "   [6/6] SUCCESS! POWERFUL UBUNTU GNOME IS ONLINE   "
echo "===================================================="
echo "লগইন ইনফরমেশন (সাজেশন):"
echo "----------------------------------------------------"
echo "User Name : $USER"
echo "RDP PIN   : (আপনার দেওয়া ৬ ডিজিটের পিনটি)"
echo "সফটওয়্যার ম্যানেজার: Synaptic Package Manager ইনস্টল করা আছে।"
echo "----------------------------------------------------"
echo "এখন আরডিপি স্ক্রিনটি দেখতে নিচের লিংকে যান:"
echo "👉 https://remotedesktop.google.com/access"
echo "===================================================="

# ১২ ঘণ্টার লুপ প্রোটেকশন
seq 1 43200 | while read i; do 
    echo -en "\r RDP Running Active . $i s / 43200 s"; sleep 1
done
