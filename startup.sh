#!/bin/bash

## Start the ssh service
/usr/sbin/sshd

## Clear the src folder
cd /src
rm -rf *

## Start the Xvfb virtual display service
cd 
# create an Xvfb virtual display in the background (another screen size: 1080x1440x24)
Xvfb :99 -ac -screen 0 1680x1080x24 &  
sleep 5 # wait for Xvfb display server session to be ready  
export DISPLAY=:99

## Start a vnc session to the virtual display created above
x11vnc -forever -usepw -display :99 &
# -geometry 1680x1080

## Run cucumber
su cobalt <<'EOF'
cd
source /home/cobalt/.rvm/scripts/rvm
echo $(ruby -v)
cd /home/cobalt/cucumber
echo "Xvfb display number:"
echo $DISPLAY
bundle exec parallel_cucumber features/ -o "-p parallel"
# cucumber -p ci features/
EOF

## Copy cucumber html results to the default Nginx content folder
# cp /home/cobalt/cucumber/results.html /usr/share/nginx/html
# cp -rf /home/cobalt/cucumber_results /usr/share/nginx/html

## Start Nginx server
# using global directive 'daemon off' to 
# ensure the docker container does not halt after Nginx spawns its processes
echo "Starting Nginx server with customized configuration..."
/usr/sbin/nginx -g 'daemon off;' -c /home/cobalt/cucumber/cucumber_nginx.conf
