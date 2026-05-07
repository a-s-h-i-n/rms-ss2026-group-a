#!/bin/bash

IMAGE_NAME=ss2026_ur5_humble

echo "Building Docker image..."

docker build -t $IMAGE_NAME .
