# docker-cucumber
## Description

Cucumber is a popular test automation tool that supports Behavior Driven Development(BDD). It's been largely adopted for automated GUI test in CI/CD pipelines. It uses its unique DSL (the Gherkin language) to write executable test specifications in plain text and validates whether a piece of software works as specified. More detailed introductions and tutorials can be found on its [documentation page](https://docs.cucumber.io/guides/overview/). 

For GUI tests, internally cucumber runs on the Selenium webdriver and often it's found not easy to properly configure a cucumber running environment, and the environment itself is fragile with dependency changes. This is particularly true when trying to make Slenium works with the FireFox browser. Version compatibility is a little devil poking around. Hence an idea occurs to me that such configurations can be managed within a docker container, such that package dependencies, Ruby gem versions and browser versions can be persisted. A container also provides an isolated test running environment that is immune to changes at host level. 

This repository contains a Dockerfile that creates a docker container which runs Xvfb, X11VNC, SSH, NGINX, Firefox and Ruby services. 
Cucumber GUI tests can be run inside the container with test reports exposed through NGINX static web service. 

* SSH is used to provide encrypted data communication between the docker container and remote client machines.

* Xvfb creates a virtual display where GUI tests can be run.

* X11vnc creates a VNC session against the virtual display that can be accessed through a VNC viewer remotely (add-on, not compulsory)

* NGINX is used to serve the static contents of the cucumber test results through HTTP.

* A customized HTML formatter was written under the features/support folder to generate separated HTML reports for each feature. 

* An XSLT file junit-noframes.xsl was written to compile the JUnit XML reports into a consolidated HTML report. 

## Requirements
A Linux system (or any other OS that works for you) with docker installed.

## Getting Started
Clone the repository, build the docker image and run it. The APP_BUILD and TEST_PHASE environment variables are used to construct reporting URLs. 

    docker build -t cucumber -f Dockerfile.setup --build-arg APP_BUILD=build --build-arg TEST_PHASE=bvt .
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


## Contributing
Contact the owner before contributing.

1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

## License and Authors
* Ruifeng Ma (mrfflyer@gmail.com)

