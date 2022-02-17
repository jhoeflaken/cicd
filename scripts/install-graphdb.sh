#!/bin/bash
downloadLocation='https://download.ontotext.com/owlim/b691074a-2c3d-11ec-9319-42843b1b6b38/graphdb-se-9.10.0-dist.zip'

echo "Start: GraphDB installation script"

# update
sudo apt update -y
sudo apt install unzip -y

# install JRE
sudo apt install default-jre -y

# download and unzip GraphDB
sudo mkdir /usr/local/graphdb
sudo wget -O /usr/local/graphdb/install-files.zip $downloadLocation
sudo unzip /usr/local/graphdb/install-files.zip -d /usr/local/graphdb
sudo rm -f /usr/local/graphdb/install-files.zip

# create a systemd service unit
sudo cat /etc/systemd/system/graphdb.service <<EOF
[Unit]
Description=GraphDB Server (running on port 7200)
WantedBy=multi-user.target

[Service]
Type=forking
PIDFile=/usr/local/graphdb/graphdb-se-9.10.0/bin/graphdb.pid
ExecStart=/usr/local/graphdb/graphdb-se-9.10.0/bin/graphdb -d -p /usr/local/graphdb/graphdb-se-9.10.0/bin/graphdb.pid
ExecStop=/bin/kill -15 $MAINPID
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# configure and start the service
sudo systemctl daemon-reload
sudo systemctl enable graphdb.service
sudo systemctl start graphdb.service

echo "Finished: GraphDB installation script"