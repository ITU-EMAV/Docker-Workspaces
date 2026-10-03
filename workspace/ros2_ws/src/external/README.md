# External packages (simulation only)

Third-party code kept apart from the sac_autonomy packages (MIT), built into the simulation
image only.

- `FAST_LIO_ROS2` (git submodule, [Ericsii/FAST_LIO_ROS2](https://github.com/Ericsii/FAST_LIO_ROS2),
  **GPL-2.0**): FAST-LIO2, a lidar-inertial odometry, run as its own process
  (sac_localization `lidar_odometry:=fast_lio`); its motion is a velocity input of the local
  filter. Tried against our own; not in the car's image.
- `livox_ros_driver2`: only the two message definitions of Livox's driver (MIT) that
  FAST_LIO_ROS2 is built against; the driver and the Livox SDK are not used with a Velodyne.
