#!/bin/bash

# ১. সিস্টেম প্যাকেজ লিস্ট আপডেট করা
echo "Updating system package lists..."
sudo apt update -y

# ২. ডেক্সটপ এনভায়রনমেন্ট ও অন্যান্য প্রয়োজনীয় টুলস ইনস্টল করা (উবুন্টু ২৪ এর জন্য পারফেক্ট)
echo "Installing XFCE4 Desktop Environment..."
sudo DEBIAN_FRONTEND=noninteractive apt install --assume-yes \
    xfce4 desktop-base dbus-x11 xscreensaver x11-utils xvfb

# ৩. ক্রোম রিমোট ডেক্সটপ (Latest) ডাউনলোড ও ইনস্টল করা
echo "Downloading and installing Chrome Remote Desktop..."
wget https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb
sudo dpkg -i chrome-remote-desktop_current_amd64.deb || sudo apt --fix-broken install -y

# ৪. গুগল ক্রোম ব্রাউজার (Latest) ডাউনলোড ও ইনস্টল করা
echo "Downloading and installing Google Chrome Browser..."
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb || sudo apt --fix-broken install -y

# ৫. ক্রোম রিমোট ডেক্সটপের জন্য XFCE সেশন কনফিগার করা
echo "Configuring XFCE session for Chrome Remote Desktop..."
sudo bash -c 'echo "exec /etc/X11/Xsession /usr/bin/xfce4-session" > /etc/chrome-remote-desktop-session'

# ৬. ডিসপ্লে ম্যানেজার (LightDM) নিষ্ক্রিয় করা (হেডলেস সার্ভারের জন্য জরুরি)
echo "Disabling LightDM service..."
sudo systemctl disable lightdm.service 2>/dev/null

# ৭. ডাউনলোড করা সাময়িক .deb ফাইলগুলো ডিলিট করে ক্লিন করা
rm -f chrome-remote-desktop_current_amd64.deb google-chrome-stable_current_amd64.deb

echo "===================================================="
echo " Installation Complete! Your Ubuntu 24.04 RDP is ready. "
echo "===================================================="
