FROM ros:humble

ENV DEBIAN_FRONTEND=noninteractive

# -----------------------------------------------------------------------------
# Locale
# -----------------------------------------------------------------------------
RUN apt-get update && apt-get install -y locales && \
    locale-gen en_US en_US.UTF-8 && \
    update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 && \
    rm -rf /var/lib/apt/lists/*

ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# -----------------------------------------------------------------------------
# Core tools
# -----------------------------------------------------------------------------
RUN apt-get update && apt-get install -y \
    ros-humble-desktop \
    ros-dev-tools \
    python3-colcon-common-extensions \
    python3-rosdep \
    python3-vcstool \
    build-essential \
    cmake \
    git \
    curl \
    wget \
    vim \
    nano \
    && rm -rf /var/lib/apt/lists/*

# -----------------------------------------------------------------------------
# rosdep (safe init)
# -----------------------------------------------------------------------------
RUN rosdep init || true && rosdep update

# -----------------------------------------------------------------------------
# UR5 + simulation stack
# -----------------------------------------------------------------------------
RUN apt-get update && apt-get install -y \
    ros-humble-ur \
    ros-humble-ur-moveit-config \
    ros-humble-moveit \
    ros-humble-moveit-ros-planning-interface \
    ros-humble-moveit-setup-assistant \
    ros-humble-gazebo-ros-pkgs \
    ros-humble-gazebo-ros2-control \
    ros-humble-gazebo-plugins \
    ros-humble-ros2-control \
    ros-humble-ros2-controllers \
    ros-humble-rviz2 \
    ros-humble-xacro \
    ros-humble-joint-state-publisher \
    ros-humble-joint-state-publisher-gui \
    ros-humble-robot-state-publisher \
    ros-humble-tf2-tools \
    && rm -rf /var/lib/apt/lists/*

# -----------------------------------------------------------------------------
# Workspace
# -----------------------------------------------------------------------------
WORKDIR /root/ur5_ws/src

# Official UR ROS2 description
RUN git clone -b humble https://github.com/UniversalRobots/Universal_Robots_ROS2_Description.git
RUN git clone -b humble https://github.com/UniversalRobots/Universal_Robots_ROS2_GZ_Simulation.git

# ros-gz packages
RUN apt-get update && apt-get install -y curl gnupg lsb-release

RUN curl -sSL https://packages.osrfoundation.org/gazebo.gpg \
    -o /usr/share/keyrings/gazebo-archive-keyring.gpg

RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/gazebo-archive-keyring.gpg] \
http://packages.osrfoundation.org/gazebo/ubuntu-stable \
$(lsb_release -cs) main" \
> /etc/apt/sources.list.d/gazebo-stable.list

RUN apt-get update && apt-get install -y \
    ros-humble-ros-gz \
    ros-humble-ros-gz-sim \
    ros-humble-ros-gz-bridge

WORKDIR /root/ur5_ws

# -----------------------------------------------------------------------------
# Dependencies
# -----------------------------------------------------------------------------
RUN /bin/bash -c "source /opt/ros/humble/setup.bash && \
    rosdep install --from-paths src --ignore-src -r -y"

# -----------------------------------------------------------------------------
# Build
# -----------------------------------------------------------------------------
RUN /bin/bash -c "source /opt/ros/humble/setup.bash && \
    colcon build --symlink-install"

# -----------------------------------------------------------------------------
# Environment
# -----------------------------------------------------------------------------
RUN echo "source /opt/ros/humble/setup.bash" >> /root/.bashrc && \
    echo "source /root/ur5_ws/install/setup.bash" >> /root/.bashrc && \
    echo "export ROS_DOMAIN_ID=30" >> /root/.bashrc

CMD ["bash"]
