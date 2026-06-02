#!/bin/bash

xhost +local:docker || true

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

IMAGE_NAME=ss2026_ur5_humble
CONTAINER_NAME=ss2026_ur5_container

HOST_WS="$ROOT_DIR/ur5_ws"

mkdir -p "$HOST_WS"

# -----------------------------------------------------------------------------
# STEP 1: (OPTIONAL) One-time export from old container
# -----------------------------------------------------------------------------
# Only keep this if you REALLY need to extract from image
# Otherwise you can delete this whole section after first setup

echo "[+] Creating temporary container..."
docker create --name temp_$CONTAINER_NAME $IMAGE_NAME

echo "[+] Copying workspace from container → host..."
docker cp temp_$CONTAINER_NAME:/root/ur5_ws/. "$HOST_WS"

docker rm temp_$CONTAINER_NAME

echo "[+] Workspace ready at: $HOST_WS"

# -----------------------------------------------------------------------------
# STEP 2: Run container WITH workspace mount (IMPORTANT FIX)
# -----------------------------------------------------------------------------
RUN_CMD="docker run -it --rm \
    --net=host \
    --ipc=host \
    --privileged \
    -e DISPLAY \
    -e QT_X11_NO_MITSHM=1 \
    -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
    -v /dev:/dev \
    -v \"$HOST_WS:/root/ur5_ws\" \
    --name $CONTAINER_NAME \
    $IMAGE_NAME"

if [[ $1 == "--nvidia" || $1 == "-n" ]]; then
    echo "[+] Starting container with NVIDIA support..."
    RUN_CMD="docker run -it --rm \
        --gpus all \
        --net=host \
        --ipc=host \
        --privileged \
        -e DISPLAY \
        -e QT_X11_NO_MITSHM=1 \
        -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
        -v /dev:/dev \
        -v \"$HOST_WS:/root/ur5_ws\" \
        --name $CONTAINER_NAME \
        $IMAGE_NAME"
else
    echo "[+] Starting container..."
fi

eval $RUN_CMD
