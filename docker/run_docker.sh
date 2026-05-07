#!/bin/bash

xhost +local:docker || true

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

IMAGE_NAME=ss2026_ur5_humble
CONTAINER_NAME=ss2026_ur5_container

HOST_WS="$ROOT_DIR/ur5_ws"

mkdir -p "$HOST_WS"

# -----------------------------------------------------------------------------
# STEP 1: Create temporary container
# -----------------------------------------------------------------------------
echo "[+] Creating temporary container..."
docker create --name temp_$CONTAINER_NAME $IMAGE_NAME

# -----------------------------------------------------------------------------
# STEP 2: Copy FULL workspace from container → host
# -----------------------------------------------------------------------------
echo "[+] Copying UR5 workspace from Docker → host..."
docker cp temp_$CONTAINER_NAME:/root/ur5_ws/. "$HOST_WS"

# Cleanup temp container
docker rm temp_$CONTAINER_NAME

echo "[+] Workspace exported to: $HOST_WS"

# -----------------------------------------------------------------------------
# STEP 3: Run real container (NO workspace mount!)
# -----------------------------------------------------------------------------
if [[ $1 = "--nvidia" ]] || [[ $1 = "-n" ]]
then
    echo "[+] Starting container with NVIDIA support..."
    docker run --gpus all -it --rm \
        --net=host \
        --ipc=host \
        --privileged \
        -e DISPLAY \
        -e QT_X11_NO_MITSHM=1 \
        -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
        -v /dev:/dev \
        --name $CONTAINER_NAME \
        $IMAGE_NAME
else
    echo "[+] Starting container..."
    docker run -it --rm \
        --net=host \
        --ipc=host \
        --privileged \
        -e DISPLAY \
        -e QT_X11_NO_MITSHM=1 \
        -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
        -v /dev:/dev \
        --name $CONTAINER_NAME \
        $IMAGE_NAME
fi