#
# Argments
# 
# 1 - slave host name
# 2 - ip address
# 3 - port
# 4 - base directory

# Moon Servie file
# ----------------
#
# [Unit]
# Description=Moon Server
# After=network.target
#
# [Service]
# PIDFile=/root/moon/pid\nExecStart=/usr/bin/python2 /usr/bin/moon.py \"$4\"/moon/moon.cfg start &> /dev/null &
# ExecStop=/usr/bin/python2 /usr/bin/moon.py /root/moon/moon.cfg stop &> /dev/null &
#
# [Install]
# WantedBy=multi-user.target
#

# Moon config file
# ----------------
#
# {
#   "name"   : $1 ,
#   "ip"     : $2 ,
#   "port"   : $3 ,
#   "pid"    : "$4/moon/pid\" ,
#   "stream" : 
#   {
#      "stdin"  : "default" ,
#      "stdout" : "$4/moon/moonserver.std\" ,
#      "stderr" : "$4/moon/moonserver.std\"
#   }
#     ,
#   
#   "directorys" :
#   {
#      "applications"         : "$4/moon/apps" ,
#      "application_profiles" : "$4/moon/app_profiles"
#   }
# }

# Strawberry Node
# ---------------
#
# Description='A basic static ethernet connection'
# Interface=eth0
# Connection=ethernet
# IP=static
# Address=('$2')
# SkipNoCarrier=yes
#

if [ "$#" -lt 4 ]; then
    
    echo -e "Wrong usage!\ncosmos_setup_environment.sh [slave_name] [ip] [port] [base_directory]"
    exit
fi

moon_service="[Unit]\nDescription=Moon Server\nAfter=network.target\n\n[Service]\nPIDFile=/root/moon/pid\nExecStart=/usr/bin/python2 /usr/bin/moon.py /root/moon/moon.cfg start &> /dev/null &\nExecStop=/usr/bin/python2 /usr/bin/moon.py /root/moon/moon.cfg stop &> /dev/null &\n\n[Install]\nWantedBy=multi-user.target\n"

moon_cfg="{\n    \n    \"name\" : \"$1\" ,\n    \"ip\"   : \"$2\" ,\n    \"port\" : \"$3\" ,\n    \"pid\"  : \"$4/moon/pid\" ,\n    \"stream\" : \n    {        \"stdin\"  : \"default\" ,\n        \"stdout\" : \"$4/moon/moonserver.std\" ,\n        \"stderr\" : \"$4/moon/moonserver.std\"\n    }\n    \n    ,\n    \n    \"directorys\" :\n    {\n        \"applications\"     : \"$4/moon/apps\" ,\n        \"application_profiles\" : \"$4/moon/app_profiles\"\n    }\n\n}\n"

strawberry_node="Description='A basic static ethernet connection'\nInterface=eth0\nConnection=ethernet\nIP=static\nAddress=('$2')\nSkipNoCarrier=yes\n"

cd $4

echo '[cosmos]['`pwd`'][creating folder hierarchy]'

echo '[cosmos]['`pwd`'][creating moon folder]'
echo "mkdir moon"
mkdir moon

cd moon
echo '[cosmos]['`pwd`'][creating app_profiles folder]'
echo "mkdir app_profiles"
mkdir app_profiles

echo '[cosmos]['`pwd`'][creating apps folder]'
echo "mkdir apps"
mkdir apps

echo '[cosmos]['`pwd`'][creating moon.cfg file]'
echo "touch moon.cfg"
touch moon.cfg

echo '[cosmos]['`pwd`'][filling up moon.cfg with]'
echo "echo -e \$moon_cfg"
echo -e $moon_cfg > $4/moon/moon.cfg

# - Configuring network

cd /etc/netctl/
echo '[cosmos]['`pwd`'][enabling moon service at boot]'

echo "echo -e \$strawberry_node > strawberry_node"
echo -e $strawberry_node > strawberry_node

echo "netctl enable strawberry_node"
netctl enable strawberry_node

# - Daemon service

cd /usr/lib/systemd/system/
echo '[cosmos]['`pwd`'][installing moon.service file]'
echo "echo -e \$moon_service > moon.service"
echo -e $moon_service > moon.service

cd
echo '[cosmos]['`pwd`'][enabling moon service at boot]'
echo "systemctl enable moon.service"
systemctl enable moon.service



