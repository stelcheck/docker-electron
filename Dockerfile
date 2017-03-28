FROM ubuntu:xenial
MAINTAINER Marc Trudel <mtrudel@wizcorp.jp>

#
# Needed by wine
#
RUN dpkg --add-architecture i386

# Some dependenices needed to setup addtional repositories
#
RUN apt-get update \
  && apt-get install --no-install-recommends -y \
    software-properties-common \
    curl

#
# Node.js 6 Repository
#
RUN curl -sL https://deb.nodesource.com/setup_6.x \
  | bash

#
# Repository for Infinality
#
RUN echo "deb http://ppa.launchpad.net/no1wantdthisname/ppa/ubuntu xenial main" \
  >> /etc/apt/sources.list.d/infinality.list

RUN echo "deb-src http://ppa.launchpad.net/no1wantdthisname/ppa/ubuntu xenial main" \
  >> /etc/apt/sources.list.d/infinality.list

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E985B27B

#
# Repository for Wine
#
RUN add-apt-repository ppa:ubuntu-wine/ppa -y

#
# Repository for Mono
#
RUN apt-key adv \
  --keyserver hkp://keyserver.ubuntu.com:80 \
  --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF

RUN echo "deb http://download.mono-project.com/repo/debian wheezy main" \
  >> /etc/apt/sources.list.d/mono-xamarin.list

#
# Install dependencies
#
RUN apt-get update \
  && apt-get install --no-install-recommends -y \
    nodejs \
    icnsutils \
    graphicsmagick \
    xz-utils \
    rpm \
    wine1.8 \
    osslsigncode \
    mono-devel \
    ca-certificates-mono \
    locales \
    libgconf-2-4

#
# Desktop environment and tools
#
RUN apt-get update \
  && apt-get install --no-install-recommends -y \
    dbus \
    xvfb \
    x11vnc \
    openbox \
    geany \
    menu \
    feh \
    xterm \
    vim-tiny \
    less \
    sudo \
    git

#
# Symlink vim-tiny as vim
#
RUN ln -s /usr/bin/vim.tiny /usr/bin/vim

#
# Locale configuration
#
ENV LANG en_US.UTF-8
RUN sed -i "s/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/" /etc/locale.gen
RUN echo -e 'LANG="en_US.UTF-8"\nLANGUAGE="en_US:en"\n' > /etc/default/locale
RUN locale-gen --purge en_US.UTF-8
RUN dpkg-reconfigure --frontend=noninteractive locales

#
# User we will run under
#
RUN useradd -ms /bin/bash user
RUN sudo -u user -H bash -c "mkdir /home/user/.electron"
RUN sudo -u user -H bash -c "mkdir /home/user/.npm"

#
# Initial wine setup
#
RUN sudo \
  -u user \
  -H bash \
  -c "wineboot --init"

#
# Local mount
#
VOLUME  /tmp/project
VOLUME  /home/user/.electron
VOLUME  /home/user/.npm

# xvfb display
ENV DISPLAY :9.0

# x11vnc port
EXPOSE 5900
EXPOSE 8080
