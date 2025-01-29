# Docker only
Please check the origin one for official


## Option 1: build by yourself
```bash
docker build -t chngdickson/voxblox_ros -f Dockerfile .
```
## Option 2: pull directly
建议内地同学直接pull 不然catkin build里有很多3dparty 可能没法clone下来

```bash
docker pull chngdickson/voxblox_ros
```

## docker run => container
Please put your bag file in the `/home/ds1804/bags` or replace the path in your home,
here is my folder
```bash
ds1804@ds1804-ubuntu:~/bags$ tree -L 1
.
home/bags/
├── cow_eth_data
│   ├── data.bag
│   ├── voxblox_cow_extras
│   └── voxblox_cow_extras.zip
```

```bash
cd && docker run -it --net=host --gpus all --name voxblox_ros -v /home/ds1804/bags:/root/bags chngdickson/voxblox_ros /bin/zsh 
```


## RUN
after the link folder, you can directly build and run the launch
```bash
cd ~/catkin_ws/src/voxblox && git pull
cd ~/catkin_ws && catkin build && source devel/setup.zsh
roslaunch voxblox_ros cow_and_lady_dataset.launch
```

## Remove envs
```bash
docker ps -a # show all envs that is alive
docker rm voxblox_ros # Remove the env
```




# *OVSLAM2*
### 1.0 Prerequisites
### 1.1 Install Opencv v3.4.4
opencv prerequisites
```bash
sudo apt install cmake python-dev python-numpy gcc g++
sudo apt install python3-dev python3-numpy
sudo apt install build-essential libgtk2.0-dev pkg-config libavcodec-dev libavformat-dev libswscale-dev libavresample-dev
sudo apt install libtbb2 libtbb-dev libjpeg-dev libpng-dev libtiff-dev libdc1394-22-dev

sudo add-apt-repository "deb http://security.ubuntu.com/ubuntu xenial-security main"
sudo apt update
```
Building Opencv
```bash
cd
mkdir ~/opencv_build && cd ~/opencv_build
git clone https://github.com/opencv/opencv.git && cd ~/opencv_build/opencv && git checkout 3.4.4 
cd ~/opencv_build && git clone https://github.com/opencv/opencv_contrib.git && cd ~/opencv_build/opencv_contrib && git checkout 3.4.4 
mkdir -p ~/opencv_build/opencv/build && cd ~/opencv_build/opencv/build
cmake -D CMAKE_BUILD_TYPE=Release \
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
make -j4
sudo make install
```

### 1.2 Install glog
```bash
sudo apt-get install libgflags-dev libgoogle-glog-dev protobuf-compiler libprotobuf-dev
```

## 2.0 Building ov2slam

Clone the git repository in your catkin workspace:

```bash
cd ~/catkin_ws/src/
git clone https://github.com/ov2slam/ov2slam.git
```
### 2.1 Build Thirdparty libs

For convenience we provide a script to build the Thirdparty libs:

```bash
cd ~/catkin_ws/src/ov2slam
chmod +x build_thirdparty.sh
./build_thirdparty.sh
```

### 2.2 Build Ov
```bash
cd ~/catkin_ws/src/ov2slam
catkin build --this
source ~/catkin_ws/devel/setup.bash
```