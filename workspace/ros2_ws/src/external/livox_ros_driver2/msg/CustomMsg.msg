# Livox's point cloud (livox_ros_driver2, MIT): only the message definition
std_msgs/Header header
uint64 timebase         # [ns] the first point's time
uint32 point_num
uint8 lidar_id
uint8[3] rsvd
CustomPoint[] points
