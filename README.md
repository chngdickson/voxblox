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
# voxblox
