
# Docker-Workspaces  
Simulation Environment  

## Clone Repository  
Clone the repository with submodules using this command:  
```bash
git clone https://github.com/ITU-EMAV/Docker-Workspaces.git -b simulation-environment --recursive
```

To update submodules recursively:  
```bash
git submodule update --init --recursive
```  

## Run  
After installing Docker, run the appropriate script for your operating system:  
```
cd Docker-Workspaces
./run.sh
```
- Use [```run.bat```](run.bat) for Windows.  
- Use [```run.sh```](run.sh) for Ubuntu or Mac.

Running the script again while the container is up opens a terminal in it as the `ubuntu` user.

Optional settings (environment variables read by the run scripts):

| Variable | Default | Meaning |
|---|---|---|
| `PASSWORD` | `ubuntu` | Password of the `ubuntu` user and of the VNC desktop |
| `BIND_ADDR` | `127.0.0.1` | Only this computer can open the desktop. `0.0.0.0` opens it to your network, so anyone who can reach port 6081 gets the desktop (with sudo). |
| `GPU` | `auto` | `off` forces software rendering. See [GPU](#gpu). |

Example: `PASSWORD=secret ./run.sh` (Linux/Mac) or `set "PASSWORD=secret" && run.bat` (Windows).

If you can not connect to the repository
```
docker login -u my-user-name
```
Replace my-user-name with your username, and then it'll ask for password.
Go back to Docker-Workspaces and do ./[```run.sh```](run.sh) or ./[```run.bat```](run.bat)

## Open Environment  
1. Run the [```run.sh```](run.sh)/[```run.bat```](run.bat) script.  
2. Open **Google Chrome**.  
3. Type `localhost:6081` in the address bar and click **Connect**.  
    ![StartScreen](imgs/StartScreen.png)  
4. You are now in a virtual environment for developing ROS and Gazebo projects.  
    ![DesktopScreen](imgs/DesktopScreen.png)  
5. In **Ubuntu's Home** folder, there is a `workspace` directory containing `ros2_ws` and `gazebo_environment`.  
    ![alt text](imgs/WorkspaceScreen.png)  
6. Open a terminal inside the `ros2_ws` folder.  
    ![alt text](imgs/OpenTerminalScreen.png)  
7. Run the following commands in the terminal:  
    ```bash
    colcon build
    source install/setup.bash
    ```
    ![alt text](imgs/TypeCommandScreen.png)  
8. Your environment is now ready.  

## Test the Environment  
In the same terminal, type:  
```bash
ros2 launch gazebo_environment sonoma.launch.py
```
![alt text](imgs/GazeboScreen.png)  

The Gazebo environment should now open on your screen.  

## GPU
Without a GPU everything is rendered on the CPU, which is slow for Gazebo's cameras and lidars.
The run scripts look for a GPU and use it when the checks below pass; otherwise they fall back to software rendering.
The container log prints which one was chosen (`* GPU: ...`).

| Host | NVIDIA | AMD / Intel | What is needed |
|---|---|---|---|
| Ubuntu | yes | yes | NVIDIA: the proprietary driver and the [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html) (`sudo nvidia-ctk runtime configure --runtime=docker && sudo systemctl restart docker`). AMD/Intel: nothing extra. Use Docker Engine, not Docker Desktop for Linux, which runs containers in a VM without GPU access. |
| Windows | yes | yes | Docker Desktop with the WSL 2 engine and an up-to-date GPU driver. OpenGL goes through DirectX (Mesa d3d12), so every vendor works. |
| Mac | no | no | Docker Desktop for Mac has no GPU passthrough; software rendering only. |

On Linux the desktop runs under [VirtualGL](https://virtualgl.org), so every OpenGL program (Gazebo, RViz) renders on the GPU.

To check, open a terminal in the desktop and run:
```bash
/opt/VirtualGL/bin/glxinfo -B | grep "renderer string"
```
It should name your GPU (for example `NVIDIA GeForce ...`, `AMD Radeon ...` or `D3D12 (...)`), not `llvmpipe`.

## Scripts

### Launch Sonoma Environment in Gazebo
```
cd ~/workspace/ros2_ws/ && colcon build && source install/setup.bash && ros2 launch gazebo_environment sonoma.launch.py
```