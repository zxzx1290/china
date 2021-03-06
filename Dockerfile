# Create an up to date minimal Debian Jessi build

# run =>  sudo docker run -m="600M" -i -t -p 23:22 -p 127.0.0.1:81:80 lukedocker /bin/bash

# Pull base image
FROM debian:jessie
# Set the locale
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN apt-get update && \
    apt-get install -y openssh-server git squid3 curl python net-tools vim


RUN echo "root:password"|chpasswd
RUN sed -ri 's/^PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
	sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config

RUN git clone -b manyuser https://github.com/zxzx1290/shadowsocksr.git ssr

COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

RUN sed -i '/ulimit -n 65535/d' /etc/init.d/squid3

# Configure container to run as an executable
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
EXPOSE 22 6080 8888