# Docker-Workspaces
Headless Simulation Environment

Gazebo runs without a window inside Docker, and you watch the car in your browser
(3D view, camera, lidar, map) through [Lichtblick](https://github.com/lichtblick-suite/lichtblick),
the open-source version of Foxglove. There is no remote desktop (VNC), so it starts
faster, uses less CPU, and the viewer draws on your own computer's GPU.

For the VNC desktop version, use the `simulation-environment` branch.

## Clone Repository
```bash
git clone https://github.com/ITU-EMAV/Docker-Workspaces.git -b simulation-environment-headless --recursive
```

To update submodules recursively:
```bash
git submodule update --init --recursive
```

## Run
Install Docker, then run the script for your operating system:
- Windows: [`run.bat`](run.bat)
- Ubuntu or Mac: [`run.sh`](run.sh)

The first run builds the image and downloads the Sonoma Raceway model, which takes a
few minutes. When the log shows `Starting the simulation`, open this address in Chrome or Firefox:

**http://localhost:8090/?ds=foxglove-websocket&ds.url=ws://localhost:8765**

The viewer connects to the simulation and opens the default layout: 3D view, front
camera and map. (The script prints the same address.)

If the page shows no data, click **Open connection** and connect to `ws://localhost:8765`.

Press `Ctrl+C` in the script's window to stop everything. Running the script again while
the simulation is up opens a terminal in it, with ROS and the workspace already sourced:
```bash
ros2 topic list
ros2 topic pub /sac/actuators/cmd_vel geometry_msgs/msg/Twist "{linear: {x: 2.0}}"
```

The workspace in `workspace/ros2_ws/src` is built when the container starts; its build
output is kept in Docker volumes, not in your folder.

### Options
Environment variables read by the run scripts:

| Variable | Default | Meaning |
|---|---|---|
| `GPU` | `auto` | `off` forces software rendering. See [GPU](#gpu). |
| `VIEWER_PORT` | `8090` | Port of the viewer page. 8080 is often taken by other software. |
| `BIND_ADDR` | `127.0.0.1` | Only this computer can connect. `0.0.0.0` opens the viewer and the data stream to your network. |
| `LP_NUM_THREADS` | `4` | CPU threads per OpenGL context in software rendering. |

Example: `GPU=off ./run.sh` (Linux/Mac) or `set "GPU=off" && run.bat` (Windows).

## GPU
Only the sensors (camera, lidar) are rendered in the container, off-screen; the viewer
draws in your browser. The run scripts find a GPU and fall back to software rendering
when none works. The log shows which one was chosen (`* GPU: ...`).

| Host | What is used | What is needed |
|---|---|---|
| Windows | Any GPU through DirectX (Mesa d3d12) | Docker Desktop with the WSL 2 engine and an up-to-date GPU driver |
| Ubuntu + NVIDIA | NVIDIA EGL | The NVIDIA driver and the [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html) |
| Ubuntu + AMD/Intel | Mesa EGL on `/dev/dri` | Nothing extra |
| Mac | Software rendering | Docker Desktop for Mac has no GPU access |

## Map
The Sonoma world is placed at the real Sonoma Raceway, so the GPS topic
`/sac/sensors/navsat/navsat` gives real coordinates that line up with maps (about 5 m).

Known issue: the Map panel shows the map around the car but does not draw the car's
position yet (a Lichtblick problem that is being looked into). The 3D view is not affected.

## Windows: computer freezes while the simulation runs
By default the WSL 2 VM behind Docker Desktop may use every CPU core and about half of the RAM, and it keeps file cache without giving it back to Windows.
Limit it with `%UserProfile%\.wslconfig` (tested on 16 GB RAM, 12 threads):
```ini
[wsl2]
memory=6GB
processors=8
swap=4GB

[experimental]
autoMemoryReclaim=gradual
```
Then quit Docker Desktop, run `wsl --shutdown` and start Docker Desktop again.
