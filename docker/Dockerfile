# rs_user_policy
# DOCKER-VERSION 1.0.1
# VERSION 0.0.1
FROM ubuntu:13.04

MAINTAINER Ryan J. Geyer <me@ryangeyer.com>

RUN apt-get install -y ruby 1.9.3
# Effectively the build-essential packages for debian from
# https://github.com/opscode-cookbooks/build-essential
RUN apt-get install -y autoconf binutils-doc bison build-essential flex gettext ncurses-dev
RUN gem install rs_user_policy -v 0.1.10 --no-ri --no-rdoc
RUN mkdir -p /opt/rs_user_policy/audits /opt/rs_user_policy/logs /opt/rs_user_policy/user_assignments

# Allow some persistence of the policy file, audit data, etc.
VOLUME ["/opt/rs_user_policy"]

WORKDIR "/opt/rs_user_policy/user_assignments"

ADD run.sh /
RUN chmod +x /run.sh

ENTRYPOINT /run.sh
