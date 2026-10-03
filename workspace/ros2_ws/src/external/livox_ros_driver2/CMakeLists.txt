# Only the messages of Livox's livox_ros_driver2 (MIT): FAST_LIO_ROS2 is built against them, the
# driver itself (and the Livox SDK it needs) is not used with a Velodyne
cmake_minimum_required(VERSION 3.8)
project(livox_ros_driver2)
find_package(ament_cmake REQUIRED)
find_package(rosidl_default_generators REQUIRED)
find_package(std_msgs REQUIRED)
rosidl_generate_interfaces(${PROJECT_NAME} msg/CustomPoint.msg msg/CustomMsg.msg DEPENDENCIES std_msgs)
ament_export_dependencies(rosidl_default_runtime)
ament_package()
