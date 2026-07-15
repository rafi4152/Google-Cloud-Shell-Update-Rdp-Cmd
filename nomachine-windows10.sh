#!/bin/bash

# যদি ngrok আগে থেকে না থাকে তবে ডাউনলোড করা
if [ ! -f "./ngrok" ]; then
    echo "Downloading Ngrok..."
    wget -O ng.sh https://github.com/kmille36/Docker-Ubuntu-Desktop-NoMachine/raw/main/ngrok.sh > /dev/null 2>&1
    chmod +x ng.sh
    ./ng.sh
fi

function goto
{
    label=$1
    cd 
    cmd=$(sed -n "/^:[[:blank:]][[:blank:]]*${label}/{:a;n;p;ba};" $0 | 
          grep -v ':$')
    eval "$cmd"
    exit
}

: ngrok
clear
echo "=========================================="
echo "Go to: https://dashboard.ngrok.com/get-started/your-authtoken"
echo "=========================================="
read -p "Paste Ngrok Authtoken: " CRP
./ngrok config add-authtoken $CRP 
clear

echo "=========================================="
echo "Choose Ngrok Region (e.g., ap, us, eu, jp, in)"
echo "=========================================="
echo "us - United States (Ohio)"
echo "eu - Europe (Frankfurt)"
echo "ap - Asia/Pacific (Singapore)"
echo "au - Australia (Sydney)"
echo "sa - South America (Sao Paulo)"
echo "jp - Japan (Tokyo)"
echo "in - India (Mumbai)"
read -p "Choose ngrok region: " CRP

# noVNC সাধারণত ৮০৮০ (8080) পোর্টে চলে, তাই এনগ্রক টানেল ৮০৮০ পোর্টে করা হলো
./ngrok http 8080 --region $CRP > /dev/null 2>&1 &

echo "Starting Ngrok tunnel for noVNC..."
sleep 7

# টানেল চেক করা
if curl --silent --show-error http://127.0.0.1:4040/api/tunnels > /dev/null 2>&1; then 
    echo "Ngrok Tunnel: OK"
else 
    echo "Ngrok failed to start! Retrying..."
    sleep 3
    goto ngrok
fi

# ব্রাউজার/noVNC সাপোর্টেড ডকার কন্টেইনার স্টার্ট করা
echo "Starting Ubuntu Desktop with noVNC..."
docker run -d --rm --network host --name ubuntu-novnc -e USER=312765 -e PASSWORD=Aziz@2006 -e VNC_PASSWORD=Aziz@2006 dorowu/ubuntu-desktop-lxde-vnc

clear
echo "=========================================="
echo "Open this Link in your Browser to access RDP:"
echo "=========================================="
echo -n "noVNC Link: "

# এনগ্রক থেকে সরাসরি ব্রাউজার লিংক জেনারেট করা
curl --silent http://127.0.0.1:4040/api/tunnels | grep -o '"public_url":"https://[^"]*' | sed 's/"public_url":"//'
echo ""
echo "User: 312765"
echo "Passwd: Aziz@2006"
echo "=========================================="

# ১২ ঘণ্টার লুপ প্রোটেকশন
seq 1 43200 | while read i; do 
    echo -en "\r Running .     $i s /43200 s"; sleep 0.1
    echo -en "\r Running ..    $i s /43200 s"; sleep 0.1
    echo -en "\r Running ...   $i s /43200 s"; sleep 0.1
    echo -en "\r Running ....  $i s /43200 s"; sleep 0.1
    echo -en "\r Running ..... $i s /43200 s"; sleep 0.1
    echo -en "\r Running     . $i s /43200 s"; sleep 0.1
    echo -en "\r Running  .... $i s /43200 s"; sleep 0.1
    echo -en "\r Running   ... $i s /43200 s"; sleep 0.1
    echo -en "\r Running    .. $i s /43200 s"; sleep 0.1
    echo -en "\r Running     . $i s /43200 s"; sleep 0.1
done
