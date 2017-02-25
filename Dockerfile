FROM golang:1.7-wheezy
MAINTAINER antti.tapio@foreach.fi

ENV TZ=Europe/Helsinki
RUN echo $TZ | tee /etc/timezone
RUN dpkg-reconfigure --frontend noninteractive tzdata

# Add backports
RUN echo 'deb http://http.debian.net/debian wheezy-backports main' > /etc/apt/sources.list.d/wheezy-backports.list

# Install Packages
RUN apt-get update && apt-get -y install cron jq

# Install PUP
RUN go get github.com/ericchiang/pup

# Add crontab file in the cron directory
ADD crontab /etc/cron.d/slackbots

# Give execution rights on the cron job
RUN chmod 0644 /etc/cron.d/slackbots

# Create the log file to be able to run tail
RUN touch /var/log/cron.log

#ADD limetti.bash /slackbots/limetti.bash
ADD mau-kas.bash /slackbots/mau-kas.bash

# Run the command on container startup
CMD cron && tail -f /var/log/cron.log
