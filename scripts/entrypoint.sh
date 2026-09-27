#!/bin/bash
# Runs as root: picks how OpenGL renders the sensors, then drops to the ubuntu user.
set -e

# GPU=auto uses a GPU when one was passed in, GPU=off forces software rendering.
#   /dev/dxg         Windows host (WSL2), any vendor -> Mesa d3d12
#   /dev/nvidiactl   NVIDIA on Linux (--gpus all)    -> NVIDIA EGL
#   /dev/dri/render* AMD/Intel on Linux              -> Mesa EGL on that GPU
# Gazebo runs headless, so only EGL off-screen rendering is used; the GUI that
# crashes on d3d12 is never started.
ENV_FILE=/etc/simulation.env
: > $ENV_FILE
if [ "${GPU:-auto}" = "off" ]; then
    echo "* GPU: off, using software rendering"
    echo "export LIBGL_ALWAYS_SOFTWARE=1" >> $ENV_FILE
elif [ -e /dev/dxg ]; then
    echo "* GPU: WSL2 /dev/dxg found, using Mesa d3d12"
    echo "export GALLIUM_DRIVER=d3d12" >> $ENV_FILE
    echo "export LD_LIBRARY_PATH=/usr/lib/wsl/lib\${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}" >> $ENV_FILE
    # Prefer the NVIDIA GPU on laptops that also have an integrated one
    [ -e /usr/lib/wsl/lib/nvidia-smi ] && echo "export MESA_D3D12_DEFAULT_ADAPTER_NAME=NVIDIA" >> $ENV_FILE
elif [ -e /dev/nvidiactl ]; then
    echo "* GPU: NVIDIA found, using NVIDIA EGL"
elif ls /dev/dri/renderD* > /dev/null 2>&1; then
    echo "* GPU: $(ls /dev/dri/renderD* | head -1) found, using Mesa EGL"
else
    echo "* GPU: none found, using software rendering"
fi

# Give the ubuntu user access to the GPU device nodes, whose group ids come from the host
for dev in /dev/dri/* /dev/dxg; do
    [ -c "$dev" ] || continue
    gid=$(stat -c %g "$dev")
    [ "$gid" = "0" ] && continue
    group=$(getent group "$gid" | cut -d: -f1)
    if [ -z "$group" ]; then
        group="hostgpu$gid"
        groupadd -g "$gid" "$group"
    fi
    usermod -aG "$group" ubuntu
done

# Volumes are created empty and owned by root the first time
chown ubuntu:ubuntu /ws /ws/build /ws/install /ws/log /home/ubuntu/.gz

exec gosu ubuntu bash -c '. /etc/simulation.env; exec "$@"' bash "$@"
