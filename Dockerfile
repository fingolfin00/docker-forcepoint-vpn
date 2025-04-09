FROM ubuntu:20.04

LABEL version = "0.1.0" \
      description = "Forcepoint VPN client" \
      author = fingolfin00

COPY forcepoint-client_2.5.2+bullseye_amd64.deb \
     libssl1.1_1.1.1w-0+deb11u1_amd64.deb \
     /opt/

COPY docker-forcepoint.sh \
     add_user_to_audio_group.sh \
     docker-ubuntu-x_startup.sh \
     setup_access_to_host_display.sh \
     /usr/bin/

RUN chmod +x /usr/bin/setup_access_to_host_display.sh /usr/bin/add_user_to_audio_group.sh /usr/bin/docker-ubuntu-x_startup.sh

RUN apt-get update

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    libevent-dev \
    libssl1.1 \
    libexpat1 libnl-route-3-200 libnl-3-200 \
    apt-utils debconf-utils dialog iputils-ping \
    ssh dbus iproute2 systemd \
    apulse \
    unzip \
    bzip2 xz-utils \
    wget \
    iputils-ping \
    curl \
    vim \
    xauth \
    ca-certificates \
    libgtk-3-0 \
    libdbus-glib-1-2 \
    libx11-xcb1 \
    libevent-dev \
    libxtst6

RUN useradd --shell /bin/false --create-home appuser

COPY config /etc/ssh/ssh_config.d/juno.conf
ARG VPN_USERNAME
ENV VPN_USERNAME=${VPN_USERNAME}
RUN sed -i "s|\${VPN_USERNAME}|${VPN_USERNAME}|g" "/etc/ssh/ssh_config.d/juno.conf"

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
RUN echo "resolvconf resolvconf/linkify-resolvconf boolean false" | debconf-set-selections
RUN apt-get update

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y resolvconf

RUN DEBIAN_FRONTEND=noninteractive dpkg -i \
    #/opt/libssl1.1_1.1.1w-0+deb11u1_amd64.deb
    /opt/forcepoint-client_2.5.2+bullseye_amd64.deb

ENV FF_INSTALLER_NAME=firefox-latest.tar.xz
RUN cd /tmp && \
    wget --progress=dot:mega -O ${FF_INSTALLER_NAME} 'https://download.mozilla.org/?product=firefox-latest-ssl&os=linux64&lang=en-US' && \
    ls -l /usr/local/bin && \
    tar xJvf ${FF_INSTALLER_NAME} -C /usr/local/bin && \
    chown -R appuser:appuser /usr/local/bin/firefox && \
    rm -f ${FF_INSTALLER_NAME}

ARG addons="722:{73a6fe31-595d-460b-a920-fcc0f8843232} 3971429:CookieAutoDelete@kennydo.com 464050:2.0@disconnect.me 3466053:foxyproxy@eric.h.jung"

RUN profile=docker.default && \
    addonsDir=/home/appuser/.mozilla/firefox/${profile}/extensions && \
    \
    mkdir -p ${addonsDir} && \
    \
    /bin/echo -e \
      "[General]\n\
       StartWithLastProfile=1\n\
       \n\
       [Profile0]\n\
       Name=default\n\
       IsRelative=1\n\
       Path=${profile}\n\
       Default=1" >> /home/appuser/.mozilla/firefox/profiles.ini && \
    \
    downloadAddon() { \
      wget --progress=dot:mega https://addons.mozilla.org/firefox/downloads/file/${1}/addon-${1}-latest.xpi || \
      wget --progress=dot:mega https://addons.mozilla.org/firefox/downloads/latest/${1}/addon-${1}-latest.xpi || \
      wget --progress=dot:mega \
           https://addons.mozilla.org/firefox/downloads/latest/${1}/platform:2/addon-${1}-latest.xpi; \
    } && \
    \
    addonNum() { \
      echo ${1%:*}; \
    } && \
    \
    addonId() { \
      echo ${1#*:}; \
    } && \
    \
    for addon in ${addons}; do \
      addonNum=$(addonNum ${addon}); \
      downloadAddon ${addonNum} || exit 1; \
      mv addon-${addonNum}-latest.xpi ${addonsDir}/$(addonId ${addon}).xpi; \
    done && \
    \
    chown -R appuser:appuser /home/appuser/.mozilla

RUN /bin/echo -e 'user_pref("browser.fixup.dns_first_for_single_words", true);' >> /home/appuser/.mozilla/firefox/docker.default/user.js

#ENTRYPOINT forcepoint-client ${VPN_IPADDR} --certaccept --resolver /usr/bin/systemd-resolve --verbose --daemonize --user ${VPN_USERNAME} --password ${VPN_PASSWORD}${VPN_OTP}
ENTRYPOINT docker-forcepoint.sh
