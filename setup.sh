#!/bin/bash

# Create the directory needed to run the sshd daemon
mkdir /var/run/sshd 

# Add cobalt user and generate a random password with 6 characters that includes at least one capital letter and number
COBALT_PASSWORD=`pwgen -c -n -1 6`
echo "<pwd>"User: cobalt Password: $COBALT_PASSWORD"<pwd>"
COBALT_DOCKER_ENCRYPYTED_PASSWORD=`perl -e 'print crypt('"$COBALT_PASSWORD"', "aa"),"\n"'`
useradd -m -d /home/cobalt -p $COBALT_DOCKER_ENCRYPYTED_PASSWORD cobalt
# sed -Ei 's/adm:x:4:/cobalt:x:4:cobalt/' /etc/group
# sed -i '$i cobalt:x:4:cobalt/' /etc/group
adduser cobalt sudo

# Set the default shell as bash for cobalt user
chsh -s /bin/bash cobalt

# Copy all cucumber project files into the cobalt user directory
mkdir /home/cobalt/cucumber
chown -R cobalt /home/cobalt/
cd /src/ && sudo -u cobalt cp -rf .[a-zA-Z]* [a-zA-Z]* /home/cobalt/cucumber

# Store the user's password to its home directory
echo $COBALT_PASSWORD > /home/cobalt/userpwd.txt

# Set up password for VNC connection
mkdir ~/.vnc
x11vnc -storepasswd cobalt ~/.vnc/passwd

# RVM, Ruby and application code installation needs to be performed by the cobalt user
su cobalt <<'EOF'
cd
echo $(id)

# Install RVM, use RVM to install Ruby version 2.3.1, and then installed required gems
cd /home/cobalt/cucumber
echo "Installing RVM..."
# gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
# In case direct key reception does not work due to network issue, use below two commands to download and import
curl -#LO https://rvm.io/mpapis.asc
gpg --import mpapis.asc
curl -sSL https://get.rvm.io | bash -s stable
source /home/cobalt/.rvm/scripts/rvm
source /home/cobalt/.profile
echo $(rvm -v)
echo "RVM installation completed."
echo "Installing Ruby (version 2.3.1) ..."
echo $PATH
rvm install 2.3.1
rvm use 2.3.1 --default
echo $(ruby -v)
echo "Ruby (version 2.3.1) installation completed."
cd /home/cobalt/cucumber
gem install bundler
bundle install
EOF