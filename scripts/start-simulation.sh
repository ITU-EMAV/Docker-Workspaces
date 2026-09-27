#!/bin/bash
# Builds the workspace, then starts the Foxglove bridge and the headless Sonoma simulation.
set -e
source /opt/ros/jazzy/setup.bash

cd /ws
echo "* Building the workspace (/ws/src)"
# --symlink-install leaves links to files that were deleted from the sources, and colcon
# then fails with "can't copy ...: doesn't exist". Drop them before building.
find /ws/build /ws/install -xtype l -delete 2>/dev/null || true
colcon build --symlink-install --event-handlers console_direct- summary+
source /ws/install/setup.bash

# Stop the bridge when the simulation exits (or on Ctrl+C / docker stop)
# Without ROS_DISTRO the bridge does not announce the distro, and Lichtblick then does
# not preload its built-in ROS Humble message definitions. Those clash with Jazzy's
# NavSatFix and Marker, and the Map panel and the track model would stay empty.
env -u ROS_DISTRO ros2 run foxglove_bridge foxglove_bridge --ros-args -p port:=8765 &
BRIDGE_PID=$!
trap 'kill $BRIDGE_PID 2>/dev/null' EXIT

echo "* Starting the simulation. Open the address printed by run.sh / run.bat to watch it."
# SIM_LAUNCH_ARGS adds launch arguments, e.g. "ground_truth_tf:=false"
ros2 launch gazebo_environment sonoma.launch.py gui:=false ${SIM_LAUNCH_ARGS}
