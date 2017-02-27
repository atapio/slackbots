FROM golang:1.7-wheezy
MAINTAINER antti.tapio@foreach.fi

ENV TZ=Europe/Helsinki
RUN echo $TZ | tee /etc/timezone
RUN dpkg-reconfigure --frontend noninteractive tzdata

# Add backports
RUN echo 'deb http://http.debian.net/debian wheezy-backports main' > /etc/apt/sources.list.d/wheezy-backports.list

# Install Packages and pup
RUN apt-get update && apt-get -y install busybox-static jq && go get github.com/ericchiang/pup

# Add crontab file to root cron
ADD crontab /var/spool/cron/crontabs/root

#ADD limetti.bash /slackbots/limetti.bash
ADD mau-kas.bash /slackbots/mau-kas.bash
RUN chmod +x /slackbots/mau-kas.bash

# Run the command on container startup
CMD /bin/busybox crond -l 2 -f -L /dev/stderr
