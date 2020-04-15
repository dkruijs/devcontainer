# Ubuntu 18.04 base image
FROM ubuntu:18.04

WORKDIR /home/docker

COPY provisioning_script.sh /home/docker/
COPY .env /home/docker/

RUN ["bash", "provisioning_script.sh"]

# 8889 for ssh, 8888 for jupyter
EXPOSE 8889 8888

# entry on commandline
CMD ["/bin/bash"]