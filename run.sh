#!/bin/bash
# Starts the headless simulation (Linux, Mac, or inside WSL 2).
# Running it again while the simulation is up opens a terminal in it.
#   GPU=auto (default) uses a GPU when one is found, GPU=off forces software rendering.
#   BIND_ADDR=0.0.0.0 makes the viewer reachable from other computers.
#   VIEWER_PORT=8090 (default) is the port of the viewer page.
set -e
cd "$(dirname "$0")"
export GPU="${GPU:-auto}"

if [ -n "$(docker ps --quiet --filter status=running --filter name=^simulation-headless$)" ]; then
    echo "Opening a terminal in the running simulation"
    exec docker exec -it -u ubuntu simulation-headless bash
fi

docker compose build sim

# Each GPU option is tried with a throwaway container first, so a missing
# driver or toolkit falls back to software rendering instead of failing.
gpu_works() {
    docker run --rm --entrypoint true "$@" simulation-headless > /dev/null 2>&1
}
FILES=(-f compose.yaml)
if [ "$GPU" != "off" ]; then
    if [ -e /dev/dxg ]; then
        # Inside WSL 2 on Windows: any GPU vendor through DirectX
        gpu_works --device /dev/dxg -v /usr/lib/wsl:/usr/lib/wsl && FILES+=(-f compose.gpu-wsl.yaml)
    elif command -v nvidia-smi > /dev/null && gpu_works --gpus all; then
        FILES+=(-f compose.gpu-nvidia.yaml)
    elif ls /dev/dri/renderD* > /dev/null 2>&1 && gpu_works --device /dev/dri; then
        FILES+=(-f compose.gpu-dri.yaml)
    fi
fi

echo
echo "  Open this address in Chrome or Firefox to watch the simulation:"
echo "  http://localhost:${VIEWER_PORT:-8090}/?ds=foxglove-websocket&ds.url=ws://localhost:8765"
echo "  Press Ctrl+C here to stop it."
echo
docker compose "${FILES[@]}" up
