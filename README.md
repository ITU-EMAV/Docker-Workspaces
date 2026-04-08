
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

## Scripts

### Launch Sonoma Environment in Gazebo
```
cd ~/workspace/ros2_ws/ && colcon build && source install/setup.bash && ros2 launch gazebo_environment sonoma.launch.py
```

## GPU access

### Amd GPUS 
```
https://rocm.docs.amd.com/projects/radeon/en/latest/docs/install/wsl/install-radeon.html
```

Install amd driver
```
https://www.amd.com/en/resources/support-articles/release-notes/RN-RAD-WIN-25-3-1.html
```

#### Ubuntu 22.04
```
sudo apt update
wget https://repo.radeon.com/amdgpu-install/6.3.4/ubuntu/jammy/amdgpu-install_6.3.60304-1_all.deb
sudo apt install ./amdgpu-install_6.3.60304-1_all.deb
```
#### Ubuntu 24.04
```
```
sudo apt update
wget https://repo.radeon.com/amdgpu-install/6.3.4/ubuntu/noble/amdgpu-install_6.3.60304-1_all.deb
sudo apt install ./amdgpu-install_6.3.60304-1_all.deb

#### Native
```
amdgpu-install -y,rocm --no-dkms
```

#### Wsl
```
amdgpu-install -y --usecase=wsl,rocm --no-dkms
```



If simulation crash 
```
export LIBGL_ALWAYS_SOFTWARE=1
```
or run with ogre
```
ign gazebo  --render-engine ogre
```
#### Uninstall 
```
sudo amdgpu-uninstall
```

