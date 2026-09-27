@echo off
rem Starts the headless simulation (Windows, Docker Desktop with the WSL 2 engine).
rem Running it again while the simulation is up opens a terminal in it.
rem   GPU=auto (default) uses the GPU through DirectX, GPU=off forces software rendering.
rem   BIND_ADDR=0.0.0.0 makes the viewer reachable from other computers.
rem   VIEWER_PORT=8090 (default) is the port of the viewer page.
setlocal
cd /d "%~dp0"
if not defined GPU set GPU=auto
if not defined VIEWER_PORT set VIEWER_PORT=8090

set runningContainer=
for /f %%i in ('docker ps --quiet --filter "status=running" --filter "name=^simulation-headless$"') do set runningContainer=%%i
if defined runningContainer (
    echo Opening a terminal in the running simulation
    docker exec -it -u ubuntu simulation-headless bash
    exit /b 0
)

docker compose build sim || exit /b 1

rem The GPU is tried with a throwaway container first, so a missing driver falls
rem back to software rendering instead of failing.
set FILES=-f compose.yaml
if /i not "%GPU%"=="off" docker run --rm --entrypoint true --device /dev/dxg -v /usr/lib/wsl:/usr/lib/wsl simulation-headless >nul 2>&1 && set FILES=-f compose.yaml -f compose.gpu-wsl.yaml

echo.
echo   Open this address in Chrome or Firefox to watch the simulation:
echo   http://localhost:%VIEWER_PORT%/?ds=foxglove-websocket^&ds.url=ws://localhost:8765
echo   Press Ctrl+C here to stop it.
echo.
docker compose %FILES% up
