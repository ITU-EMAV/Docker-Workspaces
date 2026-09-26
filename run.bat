@echo off
setlocal

set CONTAINER_NAME=simulation-environment
set IMAGE_NAME=simulation-environment-image
set DOCKERFILE=docker/Dockerfile
set CONTAINER_USER=ubuntu

rem Ports are only reachable from this computer. Set BIND_ADDR=0.0.0.0 to open
rem them to the network (anyone who can reach port 6081 gets the desktop).
if not defined BIND_ADDR set BIND_ADDR=127.0.0.1
rem GPU=auto uses a GPU when one is found, GPU=off forces software rendering,
rem GPU=on also tries OpenGL through DirectX (experimental, Gazebo may crash).
if not defined GPU set GPU=auto

cd /d "%~dp0"

rem Check if the container is already running
for /f %%i in ('docker ps -a --quiet --filter "status=running" --filter "name=%CONTAINER_NAME%"') do set runningContainer=%%i
if defined runningContainer (
    echo Attaching to running container: %CONTAINER_NAME%
    docker exec -i -t -u %CONTAINER_USER% -w /home/%CONTAINER_USER%/workspace %CONTAINER_NAME% /bin/bash
    exit /b 0
)

echo Building %DOCKERFILE% as image: %IMAGE_NAME%

docker build -f %DOCKERFILE% -t %IMAGE_NAME% .

rem Define Docker arguments. The gz-cache volume keeps downloaded Gazebo Fuel models between runs.
set DOCKER_ARGS=--name %CONTAINER_NAME% -v "%cd%/workspace:/home/%CONTAINER_USER%/workspace" -v %CONTAINER_NAME%-gz-cache:/home/%CONTAINER_USER%/.gz -p %BIND_ADDR%:6081:80 -p %BIND_ADDR%:8765:8765 --security-opt seccomp=unconfined --shm-size=2g -e GPU=%GPU%
if defined PASSWORD set DOCKER_ARGS=%DOCKER_ARGS% -e PASSWORD
if defined LP_NUM_THREADS set DOCKER_ARGS=%DOCKER_ARGS% -e LP_NUM_THREADS

rem GPU passthrough (Docker Desktop with the WSL 2 engine). Each option is tried with a
rem throwaway container first, so a missing driver falls back to software rendering.
rem   --gpus all  NVIDIA (CUDA)
rem   /dev/dxg    OpenGL on any GPU vendor (NVIDIA, AMD, Intel) through DirectX. Only with
rem               GPU=on: Gazebo aborts at random with "Out of GPU memory" on Mesa d3d12.
set GPU_NVIDIA=
set GPU_DXG=
if /i not "%GPU%"=="off" docker run --rm --entrypoint true --gpus all %IMAGE_NAME% >nul 2>&1 && set "GPU_NVIDIA=--gpus all"
if /i "%GPU%"=="on" docker run --rm --entrypoint true --device /dev/dxg -v /usr/lib/wsl:/usr/lib/wsl %IMAGE_NAME% >nul 2>&1 && set "GPU_DXG=--device /dev/dxg -v /usr/lib/wsl:/usr/lib/wsl"
if defined GPU_NVIDIA echo GPU: NVIDIA
if defined GPU_DXG echo GPU: WSL2 /dev/dxg

rem Run the container
docker run -it --rm %DOCKER_ARGS% %GPU_NVIDIA% %GPU_DXG% %IMAGE_NAME%
