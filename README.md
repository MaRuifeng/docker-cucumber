# docker-cucumber

Description
---------------
This branch takes 2 input build arguments to be supplied for reporting URLs. The reporting directory is structured by these two arguments. 

APP_BUILD

TEST_PHASE

This repository contains a Dockerfile that creates a docker container which runs Xvfb, X11VNC, SSH, NGINX, Firefox and Ruby services. 
Cucumber GUI tests can be run inside the container with test reports exposed through NGINX static web service. 

* SSH is used to provide encrypted and remote data communication between the docker container and client machines.

* Xvfb creates a virtual display where GUI tests can be run.

* X11vnc creates a VNC session against the virtual display that can be accessed through a VNC viewer remotely.

* NGINX is used to serve the static contents of the cucumber test results through HTTP.

Owners
------
Author: Ruifeng Ma

Organization: IBM

Requirements
------------
A Linux system (or any other OS that works for you) with docker installed.

Usage
-----
Clone the repository to your git folder, build the docker image and run it. 

    docker build -t cucumber -f Dockerfile.setup .
    CONTAINER_ID=$(docker run -d -P -p 9080:80 cucumber)
    
This will expose 3 ports from the container, SSH(22), VNC(5900) and TCP(80). Use below command to checkout the port numbers.

    docker ps -a
    
Navigate into the container with bash interface if needed (e.g. check user password from userpwd.txt).

    docker exec -i -t $CONTAINER_ID /bin/bash
    
Connect to the docker container remotely via SSH (cobalt is the user name created in the image).

    ssh cobalt@<docker_host_ip> -p <ssh_port_number>
    
Connect to the virtual display via TigerVNC viewer (password: cobalt). 

    <docker_host_ip>:<vnc_port_number>
    
Once the cucumber scripts are finished with running, view the test results report in HTML, test logs and screen shots via a browser.

    http://<docker_host_ip>:9080


Contributing
------------
Contact the owner before contributing.

1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

License and Authors
-------------------
Authors: ruifengm@sg.ibm.com mrfflyer@gmail.com

