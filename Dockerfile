FROM osrf/ros:noetic-desktop-full
LABEL maintainer="Zhuang Chi Sheng <chngdickson@gmail.com>"
# Just in case we need it
ENV DEBIAN_FRONTEND noninteractive

# install zsh
RUN apt update && apt install -y wget git zsh tmux vim g++ rsync
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.1.2/zsh-in-docker.sh)" -- \
    -t robbyrussell \
    -p git \
    -p ssh-agent \
    -p https://github.com/agkozak/zsh-z \
    -p https://github.com/zsh-users/zsh-autosuggestions \
    -p https://github.com/zsh-users/zsh-completions \
    -p https://github.com/zsh-users/zsh-syntax-highlighting

RUN apt update && apt install -y python3-wstool python3-catkin-tools ros-noetic-cmake-modules protobuf-compiler autoconf build-essential libtool

RUN mkdir -p /root/catkin_ws/src
WORKDIR /root/catkin_ws
# Added recently
RUN catkin init
RUN catkin config --extend /opt/ros/noetic
RUN catkin config --cmake-args -DCMAKE_BUILD_TYPE=Release
RUN catkin config --merge-devel
WORKDIR /root/catkin_ws/src/
RUN git clone https://github.com/chngdickson/voxblox.git
RUN wstool init . ./voxblox/voxblox_https.rosinstall
RUN wstool update

# 2. Install OV2Slam

# 2a) Opencv
# 2a.I Prerequisites
RUN apt-get update && apt-get install -y software-properties-common
RUN add-apt-repository "deb http://security.ubuntu.com/ubuntu xenial-security main"
RUN apt update
RUN apt install -y cmake python-dev python-numpy gcc g++ python3-dev python3-numpy build-essential libgtk2.0-dev pkg-config libavcodec-dev libavformat-dev libswscale-dev libavresample-dev libtbb2 libtbb-dev libjpeg-dev libpng-dev libtiff-dev libdc1394-22-dev

# 2a.II Build Opencv3
RUN mkdir -p /root/opencv_build 
WORKDIR /root/opencv_build
RUN git clone https://github.com/opencv/opencv.git --branch 3.4.4 --single-branch
RUN git clone https://github.com/opencv/opencv_contrib.git --branch 3.4.4 --single-branch
RUN mkdir -p /root/opencv_build/opencv/build 
WORKDIR /root/opencv_build/opencv/build
RUN cmake -D CMAKE_BUILD_TYPE=Release \
-D CMAKE_INSTALL_PREFIX=/usr/local \
-D INSTALL_C_EXAMPLES=ON \
-D OPENCV_ENABLE_NONFREE=True \
-D BUILD_EXAMPLES=ON \
-D BUILD_opencv_java=OFF \
-D OPENCV_EXTRA_MODULES_PATH=/root/opencv_build/opencv_contrib/modules \
-D PYTHON3_EXECUTABLE=$(which python3) \
-D PYTHON3_INCLUDE_DIR=$(python3 -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())") \
-D PYTHON3_PACKAGES_PATH=$(python3 -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())") \
..
RUN make
RUN make install

# 2b) Install glog
RUN apt-get install -y libgflags-dev libgoogle-glog-dev protobuf-compiler libprotobuf-dev

# 2c) Build Third Party OV2Slam
WORKDIR /root/catkin_ws/src/
RUN git clone https://github.com/chngdickson/ov2slam.git
WORKDIR /root/catkin_ws/src/ov2slam
RUN chmod +x build_thirdparty.sh
RUN ./build_thirdparty.sh

# 2D) Build OV2SLAM
WORKDIR /root/catkin_ws/src/ov2slam
RUN catkin build --this

# 3) Build voxblox
WORKDIR /root/catkin_ws
RUN catkin build


# # 5) Build Pytorch
# RUN apt-get install python3-rosdep python3-rosinstall-generator python3-vcstools python3-vcstool build-essential
RUN apt-get install python3-pip -y
RUN pip3 install --upgrade pip
RUN python3 -m pip install --no-cache-dir torch==1.8.0+cu111 torchvision==0.9.0+cu111 torchaudio==0.8.0 -f https://download.pytorch.org/whl/torch_stable.html
RUN python3 -m pip install --no-cache-dir open3d==0.10.0.0 
RUN python3 -m pip install --no-cache-dir simplejson==3.17.5 pandas

# 4) Source and set default workDir
RUN echo "source /root/catkin_ws/devel/setup.bash" >> /etc/bash.bashrc
WORKDIR /root/catkin_ws/
ENTRYPOINT ["/bin/bash"]