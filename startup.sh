#!/bin/bash

## Start the ssh service
/usr/sbin/sshd

## Start the Xvfb virtual display service
cd 
# create an Xvfb virtual display in the background (another screen size: 1080x1440x24)
Xvfb :99 -ac -screen 0 1680x1080x24 &  
sleep 5 # wait for Xvfb display server session to be ready  
export DISPLAY=:99

## Run cucumber
su cobalt <<'EOF'
cd
source /home/cobalt/.rvm/scripts/rvm
echo $(ruby -v)
cd /home/cobalt/cucumber
echo "Xvfb display number:"
echo $DISPLAY
bundle exec parallel_cucumber features/ -o "-p bvt" &
EOF

## Start a vnc session to the virtual display created above
x11vnc -forever -usepw -display :99 
# -geometry 1680x1080
