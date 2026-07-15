#!/bin/bash

# গিটহাব থেকে মূল স্ক্রিপ্ট নামানো
wget -O ng.sh https://github.com/kmille36/Docker-Ubuntu-Desktop-NoMachine/raw/main/ngrok.sh > /dev/null 2>&1
chmod +x ng.sh
./ng.sh

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

# ব্যাকগ্রাউন্ডে এনগ্রক রান করা এবং প্রসেস ধরে রাখা
nohup ./ngrok tcp --region $CRP 4000 > /dev/null 2>&1 &

echo "Starting Ngrok tunnel..."
sleep 5

# এনগ্রক কানেকশন চেক করা
if curl --silent --show-error http://127.0.0.1:4040/api/tunnels > /dev/null 2>&1; then 
    echo "Ngrok Tunnel: OK"
else 
    echo "Ngrok Error! Retrying..." && sleep 2 && goto ngrok
fi

# ডকার কন্টেইনার স্টার্ট করা (আপনার কাস্টম ইউজারনেম ও পাসওয়ার্ড সহ)
echo "Starting Ubuntu NoMachine Docker Container..."
docker run --rm -d --network host --privileged --name nomachine-xfce4 -e PASSWORD=Aziz@2006 -e USER=312765 --cap-add=SYS_PTRACE --shm-size=1g thuonghai2711/nomachine-ubuntu-desktop:windows10

clear
echo "=========================================="
echo "NoMachine: https://www.nomachine.com/download"
echo "=========================================="
echo "Done! NoMachine Information:"
echo -n "IP Address: "

# আপডেটেড আইপি এক্সট্রাকশন
curl --silent http://127.0.0.1:4040/api/tunnels | grep -o '"public_url":"tcp://[^"]*' | tr -d '"public_url":"tcp://'
echo ""

echo "User: 312765"
echo "Passwd: Aziz@2006"
echo "=========================================="
echo "VM can't connect? Restart Cloud Shell then Re-run script."

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
