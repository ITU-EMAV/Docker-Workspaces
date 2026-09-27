# Docker-Workspaces
Headless Simulation Environment

Gazebo runs without a window inside Docker, and you watch the car in your browser
(3D view, camera, lidar, map) through [Lichtblick](https://github.com/lichtblick-suite/lichtblick),
the open-source version of Foxglove. There is no remote desktop (VNC), so it starts
faster, uses less CPU, and the viewer draws on your own computer's GPU.

For the VNC desktop version, use the `simulation-environment` branch.

## Clone Repository
```bash
git clone https://github.com/ITU-EMAV/Docker-Workspaces.git --recursive
```

To update submodules recursively:
```bash
git submodule update --init --recursive
```

The workspace (`workspace/ros2_ws/src`) holds two submodules:
- [gazebo_environment](https://github.com/ITU-EMAV/gazebo_environment): the world, the
  simulated sensors and the bridge; only used in simulation.
- [sac_autonomy](https://github.com/ITU-EMAV/sac_autonomy): the car's description and the
  autonomy packages, shared with the real car's
  [Vehicle-Workspace](https://github.com/ITU-EMAV/Vehicle-Workspace).

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
| `SIM_LAUNCH_ARGS` | | Extra arguments for `sonoma.launch.py`, e.g. `ground_truth_tf:=false` to leave `map -> odom -> base_footprint` to your own localization. |
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

## Driving from the browser
The Teleop panel (bottom right) drives the car like a cruise control:
- hold **up** / **down** to raise / lower the target speed; it stays when you let go.
  Holding down stops the car at 0; press down again to reverse.
- hold **left** / **right** to turn at the current speed.

It only sends commands while you use it or the car is moving on its set speed, so your own
code can drive `/sac/actuators/cmd_vel` otherwise.

## What the viewer shows
- **3D:** the car, the lidar point cloud and the textured Sonoma Raceway model
  (`/environment/track`, converted from Gazebo's model the first time, a few seconds).
- **Camera:** `/sac/sensors/front_camera/image`.
- **Map:** the car on OpenStreetMap. The Sonoma world is placed at the real Sonoma
  Raceway, so the GNSS topics (`/sac/sensors/navsat_front_right/navsat`, `.../navsat_rear_left/navsat`) give real coordinates (about 5 m accuracy).

The layout lives in [`config/lichtblick-layout.json`](config/lichtblick-layout.json). Your
browser keeps its own copy after the first visit; to get the file's version again, clear
the site data for `localhost:8090` in the browser and reload.

Sensors are only simulated while something subscribes to them, so a closed viewer or an
unused topic costs nothing.

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
