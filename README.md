# Docker only
Please check the origin one for official


## Option 1: build by yourself
```bash
docker build -t dschng/voxblox_ros -f Dockerfile .
```
## Option 2: pull directly
建议内地同学直接pull 不然catkin build里有很多3dparty 可能没法clone下来

```bash
docker pull dschng/voxblox_ros
```

# 2 Docker run File Structure and Containers 
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

- /root/bags   -> is folder in docker, this should remain unchanged
- /home/ds1804/bags -> is the folder in my linux pc
- c:\Users\swacker\MINT -> Folder in windows pc

xhost command must be run for xcb to run
```bash
xhost local:docker 

cd && docker run -it \
--net=host \
--gpus all \
--privileged \
--volume /dev:/dev \
--volume /tmp/.x11-unix:/tmp/.x11-unix \
--volume ~/.ssh/ssh_auth_sock:/ssh-agent \
--env SSH_AUTH_SOCK=/ssh-agent \
--env DISPLAY=$DISPLAY \
--env TERM=xterm-256color \
--name voxblox_ros \
-v /home/ds1804/bags:/root/bags dschng/voxblox_ros 

```
For windows
```bash
docker run -it --net=host --name voxblox_ros -v c:\Users\swacker\MINT:/root/bags dschng/voxblox_ros:latest
```

# 3 Updating docker container
## 1. RUN Voxblox
after the link folder, you can directly build and run the launch
```bash
cd ~/catkin_ws/src/voxblox && git pull
cd ~/catkin_ws && catkin build voxblox && source devel/setup.bash
roslaunch voxblox_ros cow_and_lady_dataset.launch
```

## 2. RUN OV2SLAM
```bash
cd ~/catkin_ws/src/ov2slam && git pull && \
cd ~/catkin_ws && catkin build ov2slam && source devel/setup.bash && roslaunch ov2slam carla.launch
roslaunch ov2slam ov2slam_node ~/catkin_ws/src/ov2slam/parameter_files/fast/euroc/euroc_stereo.yaml
```
## 3. RUN Extra Docker terminal
```bash
docker exec -it voxblox_ros bash
```


## Remove envs
```bash
docker ps -a # show all envs that is alive
docker rm voxblox_ros # Remove the env
```

## Help
```bash
docker run \
-v `pwd`/home/ds1804/Documents/dockers/PointCloud_Tree_Modelling/pctm:/usr/local/app/pctm \
-v `pwd`/home/ds1804/bags:/usr/local/app/dataset \
-it -p 8888:8888 treemodelling:latest
```

