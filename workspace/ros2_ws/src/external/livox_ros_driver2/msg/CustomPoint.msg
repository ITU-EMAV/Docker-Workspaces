# Livox's point (livox_ros_driver2, MIT): only the message, for packages built against it
# (FAST_LIO_ROS2) where no Livox lidar is used
uint32 offset_time      # [ns] from timebase
float32 x               # [m]
float32 y
float32 z
uint8 reflectivity
uint8 tag
uint8 line              # laser number
