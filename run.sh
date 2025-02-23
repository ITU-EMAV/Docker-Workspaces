#! /bin/bash

CONTAINER_NAME="simulation-enviorment"
IMAGE_NAME="simulation-enviorment-image"
DOCKERFILE="docker/Dockerfile"


if [ "$(docker ps -a --quiet --filter status=running --filter name=$CONTAINER_NAME)" ]; then
    echo "Attaching to running container: $CONTAINER_NAME"
    docker exec -i -t  $CONTAINER_NAME /bin/bash 
    exit 0
fi


echo "Building ${DOCKERFILE} as image: ${IMAGE_NAME} with base: ${BASE_IMAGE_NAME}"


docker build -f $DOCKERFILE \
    -t $IMAGE_NAME \
    .



# DOCKER_ARGS+=("--network host")
DOCKER_ARGS+=("--name $CONTAINER_NAME")
DOCKER_ARGS+=("-p 6080:80")
DOCKER_ARGS+=("--security-opt seccomp=unconfined")
DOCKER_ARGS+=("--shm-size=512m")




docker run -it --rm \
    ${DOCKER_ARGS[@]} \
    $IMAGE_NAME 