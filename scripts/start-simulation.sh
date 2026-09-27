#!/bin/bash
# Builds the workspace, then starts the Foxglove bridge and the headless Sonoma simulation.
set -e
source /opt/ros/jazzy/setup.bash

cd /ws
echo "* Building the workspace (/ws/src)"
colcon build --symlink-install --event-handlers console_direct- summary+
source /ws/install/setup.bash

# Stop the bridge when the simulation exits (or on Ctrl+C / docker stop)
ros2 launch foxglove_bridge foxglove_bridge_launch.xml port:=8765 &
BRIDGE_PID=$!
trap 'kill $BRIDGE_PID 2>/dev/null' EXIT

echo "* Starting the simulation. Open the address printed by run.sh / run.bat to watch it."
ros2 launch gazebo_environment sonoma.launch.py gui:=false
