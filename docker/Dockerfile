# Headless Gazebo simulation: no desktop, no VNC. Gazebo runs without a window
# and the robot is watched in the browser through foxglove_bridge + Lichtblick.
FROM ros:jazzy-ros-base

ARG DEBIAN_FRONTEND=noninteractive

# Gazebo Harmonic (ros_gz), the Foxglove WebSocket bridge, robot description
# tools, and Mesa for rendering the sensors (software, or GPU through d3d12/EGL).
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ros-jazzy-ros-gz \
        ros-jazzy-foxglove-bridge \
        ros-jazzy-xacro \
        ros-jazzy-robot-state-publisher \
        ros-jazzy-tf2-ros \
        ros-jazzy-tf2-tools \
        ros-jazzy-depth-image-proc \
        libgl1-mesa-dri \
        libegl-mesa0 \
        python3-pil \
        python3-pip \
        gosu && \
    rm -rf /var/lib/apt/lists/*

# trimesh converts the Sonoma track model to GLB for the browser viewer
# (gazebo_environment's track_visual node); it is not packaged for Ubuntu.
RUN pip3 install --no-cache-dir --break-system-packages trimesh==5.1.0

# Let `--gpus all` mount the NVIDIA OpenGL/EGL libraries, not only CUDA.
ENV NVIDIA_DRIVER_CAPABILITIES=all
# Threads per OpenGL context for software rendering (llvmpipe).
ENV LP_NUM_THREADS=4

# The workspace sources are bind-mounted into /ws/src; build, install and log
# live in Docker volumes so they never mix with files on the host.
RUN mkdir -p /ws/src /ws/build /ws/install /ws/log /home/ubuntu/.gz && \
    chown -R ubuntu:ubuntu /ws /home/ubuntu/.gz

COPY scripts/entrypoint.sh scripts/start-simulation.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh /usr/local/bin/start-simulation.sh && \
    sed -i 's/\r$//' /usr/local/bin/entrypoint.sh /usr/local/bin/start-simulation.sh && \
    echo '[ -f /etc/simulation.env ] && . /etc/simulation.env' >> /home/ubuntu/.bashrc && \
    echo 'source /opt/ros/jazzy/setup.bash' >> /home/ubuntu/.bashrc && \
    echo '[ -f /ws/install/setup.bash ] && source /ws/install/setup.bash' >> /home/ubuntu/.bashrc && \
    echo 'cd /ws' >> /home/ubuntu/.bashrc

WORKDIR /ws
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["start-simulation.sh"]
