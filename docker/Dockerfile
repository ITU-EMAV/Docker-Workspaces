# Ubuntu 24.04 (Noble) + ROS 2 Jazzy + Gazebo Harmonic
FROM ubuntu:noble

ARG TARGETPLATFORM
LABEL maintainer="akdalyunus <yunus.akdal@gmail.com>"

SHELL ["/bin/bash", "-c"]
ENV DEBIAN_FRONTEND=noninteractive

# ---------------------------------------------------------
# Base system
# ---------------------------------------------------------
RUN apt-get update -q && \
    apt-get upgrade -y && \
    apt-get autoclean && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# Desktop
RUN apt-get update -q && \
    apt-get install -y ubuntu-mate-desktop && \
    apt-get autoclean && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*
# RUN apt-get update -q && \
#     apt-get install -y \
#         xfce4 xfce4-goodies \
#         dbus-x11 x11-xserver-utils && \
#     apt-get autoclean && \
#     apt-get autoremove -y && \
#     rm -rf /var/lib/apt/lists/*


# Tools
RUN apt-get update && \
    apt-get install -y \
        tigervnc-standalone-server tigervnc-common \
        supervisor wget curl gosu git sudo python3-pip tini \
        build-essential vim lsb-release locales \
        bash-completion tzdata terminator dos2unix \
        ca-certificates software-properties-common && \
    apt-get autoclean && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# ---------------------------------------------------------
# noVNC + Websockify
# ---------------------------------------------------------
# RUN git clone https://github.com/AtsushiSaito/noVNC.git -b add_clipboard_support /usr/lib/novnc && \
#     python3 -m pip install --no-cache-dir --break-system-packages \
#         "git+https://github.com/novnc/websockify.git@v0.10.0" && \
#     ln -s /usr/lib/novnc/vnc.html /usr/lib/novnc/index.html
RUN apt-get update -q && \
    apt-get install -y websockify novnc && \
    rm -rf /var/lib/apt/lists/*

ENV NOVNC_PATH="/usr/share/novnc"

RUN sed -i "s/UI.initSetting('resize', 'off');/UI.initSetting('resize', 'remote');/g" "$NOVNC_PATH/app/ui.js"

# Disable auto update and crash report
RUN sed -i 's/Prompt=.*/Prompt=never/' /etc/update-manager/release-upgrades
RUN sed -i 's/enabled=1/enabled=0/g' /etc/default/apport

# ---------------------------------------------------------
# Firefox (APT version)
# ---------------------------------------------------------
# RUN add-apt-repository ppa:mozillateam/ppa -y && \
#     echo 'Package: *' > /etc/apt/preferences.d/mozilla-firefox && \
#     echo 'Pin: release o=LP-PPA-mozillateam' >> /etc/apt/preferences.d/mozilla-firefox && \
#     echo 'Pin-Priority: 1001' >> /etc/apt/preferences.d/mozilla-firefox && \
#     apt-get update -q && \
#     apt-get install -y firefox && \
#     apt-get autoclean && \
#     apt-get autoremove -y && \
#     rm -rf /var/lib/apt/lists/*

# ---------------------------------------------------------
# VSCodium (supports ARM & AMD64)
# ---------------------------------------------------------
RUN wget https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg \
      -O /usr/share/keyrings/vscodium-archive-keyring.asc && \
    echo 'deb [ signed-by=/usr/share/keyrings/vscodium-archive-keyring.asc ] https://paulcarroty.gitlab.io/vscodium-deb-rpm-repo/debs vscodium main' \
      | tee /etc/apt/sources.list.d/vscodium.list && \
    apt-get update -q && \
    apt-get install -y codium && \
    apt-get autoclean && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# ---------------------------------------------------------
# ROS 2 Jazzy
# ---------------------------------------------------------
ENV ROS_DISTRO jazzy
ARG INSTALL_PACKAGE=desktop

RUN apt-get update -q && \
    apt-get install -y curl && \
    ROS_APT_SOURCE_VERSION=$(curl -s https://api.github.com/repos/ros-infrastructure/ros-apt-source/releases/latest | grep -F "tag_name" | awk -F\" '{print $4}') && \
    curl -L -o /tmp/ros2-apt-source.deb "https://github.com/ros-infrastructure/ros-apt-source/releases/download/${ROS_APT_SOURCE_VERSION}/ros2-apt-source_${ROS_APT_SOURCE_VERSION}.$(. /etc/os-release && echo ${UBUNTU_CODENAME:-${VERSION_CODENAME}})_all.deb" && \
    dpkg -i /tmp/ros2-apt-source.deb && \
    rm -f /tmp/ros2-apt-source.deb && \
    apt-get update -q

RUN apt-get update -q && \
    apt-get install -y \
        ros-${ROS_DISTRO}-${INSTALL_PACKAGE} \
        ros-dev-tools \
        python3-argcomplete \
        python3-colcon-common-extensions \
        python3-rosdep \
        python3-vcstool && \
    rosdep init || true

RUN rosdep update

# ---------------------------------------------------------
# RQt tools
# ---------------------------------------------------------
RUN apt-get update -q && \
    apt-get install -y \
        ros-${ROS_DISTRO}-rqt* 

# ---------------------------------------------------------
# Gazebo Harmonic via ros-gz
# ---------------------------------------------------------
RUN apt-get update -q && \
    apt-get install -y ros-${ROS_DISTRO}-ros-gz

# ---------------------------------------------------------
# Foxglove bridge
# ---------------------------------------------------------
RUN apt-get update -q && \
    apt-get install -y ros-${ROS_DISTRO}-foxglove-bridge

# ---------------------------------------------------------
# PyTorch (multi-arch safe)
# ---------------------------------------------------------
# CPU wheels exist for both ARM64 + AMD64
RUN python3 -m pip install --no-cache-dir --break-system-packages \
    torch torchvision torchaudio \
    --index-url https://download.pytorch.org/whl/cpu

# ---------------------------------------------------------
# Entry point
# ---------------------------------------------------------
RUN rm -f /etc/apt/apt.conf.d/docker-clean || true
COPY ./scripts/entrypoint.sh /
RUN chmod +x /entrypoint.sh && dos2unix /entrypoint.sh

ENTRYPOINT ["/bin/bash", "-c", "/entrypoint.sh"]

ENV USER ubuntu
ENV PASSWD ubuntu
