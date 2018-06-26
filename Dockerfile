# Dockerfile for cucumber test environment setup
#
# VERSION 0.1
# AUTHOR  Ruifeng Ma (ruifengm@sg.ibm.com)
# CREATED 2016-Jun-16
# LAST MODIFIED 2017-Apr-24

# This file creates a docker image of ubuntu nature that runs
# Xvfb, X11vnc, SSH, NGINX, Firefox and Ruby services. It serves as a base image
# for cucumber test execution.
#
# SSH is used to provide encrypted and remote data
# communication between the docker container and client machines.
#
# Xvfb creates a virtual display where GUI tests can be run.
#
# X11vnc creates a VNC session against the virtual display that can be accessed through a VNC viewer remotely.
#
# NGINX is used to serve the static contents of the cucumber test results through HTTP.
#
# NOTE: if the image built from this Dockerfile needs to be used by Dockerfile.exec, the ENV statements
#       should be removed as the environment variables persist in docker images.



FROM ubuntu:14.04
MAINTAINER Ruifeng Ma "ruifengm@sg.ibm.com"

# Ensure the package repository is up to date
# RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list
RUN apt-get update -y
RUN apt-get upgrade -y

# Set the env variable DEBIAN_FRONTEND to noninteractive such that no user prompts will be given during package installation process
ENV DEBIAN_FRONTEND noninteractive

# Install the packages required to create a fake display (x11vnc, xvfb) and other common tools
RUN apt-get install -y openssh-server pwgen sudo curl x11vnc xvfb && \
    apt-get clean -y

# Install Nginx server
RUN \
    # apt-get install -y software-properties-common && \
    # add-apt-repository -y ppa:nginx/stable && \
    # apt-get update && \
    apt-get install -y nginx && \
    apt-get clean -y && \
    # echo "\ndaemon off;" >> /etc/nginx/nginx.conf && \
    chown -R www-data:www-data /var/lib/nginx

# Fix PAM (Pluggable Authentication Modules) login issue with sshd
RUN sed -i 's/session    required     pam_loginuid.so/#session    required     pam_loginuid.so/g' /etc/pam.d/sshd

# Upstart and DBus have issues inside docker. We work around in order to install firefox.
RUN dpkg-divert --local --rename --add /sbin/initctl && ln -sf /bin/true /sbin/initctl

# Install Firefox and its dependency packages (using version 46 to ensure compatibility with Selenium Webdriver)
# RUN apt-get install -y firefox=28.0+build2-0ubuntu2 && \
    # apt-mark hold firefox
RUN apt-get -y install \
    acl at-spi2-core colord dbus dconf-gsettings-backend dconf-service fontconfig \
    hicolor-icon-theme libapparmor1 libasound2 libasound2-data \
    libatk-bridge2.0-0 libatk1.0-0 libatk1.0-data libatspi2.0-0 libavahi-client3 \
    libavahi-common-data libavahi-common3 libcairo-gobject2 libcairo2 \
    libcanberra0 libcolord1 libcolorhug1 libcups2 libdatrie1 libdbusmenu-glib4 \
    libdbusmenu-gtk4 libdconf1 libexif12 libgdk-pixbuf2.0-0 \
    libgdk-pixbuf2.0-common libgphoto2-6 libgphoto2-l10n libgphoto2-port10 \
    libgraphite2-3 libgtk-3-0 libgtk-3-bin libgtk-3-common libgtk2.0-0 \
    libgtk2.0-bin libgtk2.0-common libgudev-1.0-0 libgusb2 libharfbuzz0b libice6 \
    libieee1284-3 libjasper1 liblcms2-2 libltdl7 libogg0 libpam-systemd \
    libpango-1.0-0 libpangocairo-1.0-0 libpangoft2-1.0-0 libpixman-1-0 \
    libpolkit-agent-1-0 libpolkit-backend-1-0 libpolkit-gobject-1-0 libsane \
    libsane-common libsm6 libstartup-notification0 libsystemd-daemon0 \
    libsystemd-login0 libtdb1 libthai-data libthai0 libusb-1.0-0 libv4l-0 \
    libv4lconvert0 libvorbis0a libvorbisfile3 libwayland-client0 \
    libwayland-cursor0 libx11-xcb1 libxcb-render0 libxcb-shm0 libxcb-util0 \
    libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 \
    libxinerama1 libxkbcommon0 libxrandr2 libxrender1 libxt6 libxtst6 libdbus-glib-1-2 \
    policykit-1 sound-theme-freedesktop systemd-services systemd-shim x11-common \
    xul-ext-ubufox && \
    apt-get clean -y
# ADD firefox-mozilla-build_46.0.1-0ubuntu1_amd64.deb /
RUN wget sourceforge.net/projects/ubuntuzilla/files/mozilla/apt/pool/main/f/firefox-mozilla-build/firefox-mozilla-build_46.0.1-0ubuntu1_amd64.deb && \
    dpkg -i firefox-mozilla-build_46.0.1-0ubuntu1_amd64.deb && \
    apt-mark hold firefox && \
    apt-get clean -y && \
    rm -f /firefox-mozilla-build_46.0.1-0ubuntu1_amd64.deb

# Set locale (fix the locale warnings)
RUN localedef -v -c -i en_US -f UTF-8 en_US.UTF-8 || :

# Install OS package dependencies required by RVM and the cucumber scripts
# and empty the application lists afterwards
RUN apt-get -y install libgdbm-dev libncurses5-dev automake libtool bison libffi-dev libpq-dev && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/* 

# Copy the files into the container
ADD . /src

# Enable passwordless sudo for users under the "sudo" group
RUN sed -i.bkp -e 's/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/%sudo ALL=NOPASSWD:ALL/g' /etc/sudoers

# Expose SSH port 
EXPOSE 22

# Expose VNC port
EXPOSE 5900

# Expose HTTP port
EXPOSE 80

# Create user, install ruby and required gems
RUN ["/bin/bash", "/src/setup.sh"]

# Pass application build name as a docker build argument
ARG APP_BUILD
ARG TEST_PHASE

# Check if the build argument has been set
RUN if [ -z "$APP_BUILD" ]; then echo "APP_BUILD not set - ERROR"; exit 1; else : ; fi
RUN if [ -z "$TEST_PHASE" ]; then echo "TEST_PHASE not set - ERROR"; exit 1; else : ; fi

# Transfer args as env vars
ENV APP_BUILD ${APP_BUILD}
ENV TEST_PHASE ${TEST_PHASE}

# Start Xvfb, x11vnc, ssh services and run cucumber (using CMD shell form to parse the env vars)
# CMD ["/bin/bash", "/src/startup.sh", "$APP_BUILD", "$TEST_PHASE"]
# CMD /bin/bash
CMD /bin/bash /src/startup.sh $APP_BUILD $TEST_PHASE