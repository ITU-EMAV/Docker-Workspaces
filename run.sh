#! /bin/bash

CONTAINER_NAME="simulation-environment"
IMAGE_NAME="simulation-environment-image"
DOCKERFILE="docker/Dockerfile"
CONTAINER_USER="ubuntu"

# Ports are only reachable from this computer. Set BIND_ADDR=0.0.0.0 to open
# them to the network (anyone who can reach port 6081 gets the desktop).
BIND_ADDR="${BIND_ADDR:-127.0.0.1}"
# GPU=auto uses a GPU when one is found, GPU=off forces software rendering,
# GPU=on also tries OpenGL through DirectX under WSL2 (experimental, Gazebo may crash).
GPU="${GPU:-auto}"

cd "$(dirname "$0")"


if [ "$(docker ps -a --quiet --filter status=running --filter name=$CONTAINER_NAME)" ]; then
    echo "Attaching to running container: $CONTAINER_NAME"
    docker exec -i -t -u $CONTAINER_USER -w /home/$CONTAINER_USER/workspace $CONTAINER_NAME /bin/bash
    exit 0
fi


echo "Building ${DOCKERFILE} as image: ${IMAGE_NAME}"


docker build -f $DOCKERFILE \
    -t $IMAGE_NAME \
    .



# DOCKER_ARGS+=("--network" "host")
DOCKER_ARGS+=("--name" "$CONTAINER_NAME")
DOCKER_ARGS+=("-v" "$(pwd)/workspace:/home/$CONTAINER_USER/workspace")
# Keeps downloaded Gazebo Fuel models (e.g. Sonoma Raceway) between runs
DOCKER_ARGS+=("-v" "$CONTAINER_NAME-gz-cache:/home/$CONTAINER_USER/.gz")
DOCKER_ARGS+=("-p" "$BIND_ADDR:6081:80")
DOCKER_ARGS+=("-p" "$BIND_ADDR:8765:8765")
DOCKER_ARGS+=("--security-opt" "seccomp=unconfined")
DOCKER_ARGS+=("--shm-size=2g")
DOCKER_ARGS+=("-e" "GPU=$GPU")
[ -n "$PASSWORD" ] && DOCKER_ARGS+=("-e" "PASSWORD")

# GPU passthrough. Each option is tried with a throwaway container first, so a
# missing driver or toolkit falls back to software rendering instead of failing.
gpu_works() {
    docker run --rm --entrypoint true "$@" $IMAGE_NAME > /dev/null 2>&1
}
if [ "$GPU" != "off" ]; then
    # NVIDIA: needs the NVIDIA Container Toolkit on Linux
    if command -v nvidia-smi > /dev/null && gpu_works --gpus all; then
        echo "GPU: NVIDIA"
        DOCKER_ARGS+=("--gpus" "all")
    fi
    if [ -e /dev/dxg ]; then
        # Inside WSL2 on Windows: any GPU vendor through DirectX. Only with GPU=on:
        # Gazebo aborts at random with "Out of GPU memory" on Mesa d3d12.
        if [ "$GPU" = "on" ] && gpu_works --device /dev/dxg -v /usr/lib/wsl:/usr/lib/wsl; then
            echo "GPU: WSL2 /dev/dxg"
            DOCKER_ARGS+=("--device" "/dev/dxg" "-v" "/usr/lib/wsl:/usr/lib/wsl")
        fi
    elif [ -d /dev/dri ]; then
        # AMD and Intel on Linux
        if gpu_works --device /dev/dri; then
            echo "GPU: /dev/dri"
            DOCKER_ARGS+=("--device" "/dev/dri")
        fi
    fi
fi




docker run -it --rm \
    "${DOCKER_ARGS[@]}" \
    $IMAGE_NAME
