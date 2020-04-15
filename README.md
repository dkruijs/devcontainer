# devcontainer
A personal DS/ML development container solution for a flexible, portable &amp; reproducible personal development environment that can be quickly deployed anywhere.

### Usage instructions

1. Build docker image 
```
docker build -t devcontainer . 
```
(will take a while)

2. Run the image as a container and bash into it: 
```
docker run -it -p 8889:8889 devcontainer /bin/bash
```

If you want to use X-server forwarding, add:
```
-e DISPLAY=host.docker.internal:0
```

And, if you want to mount a folder on the host as a shared volume into the container as you go into it (naturally, replace host location with your own version), add:
```
--mount src='C:\Users\Daan\Projects\Dev Container\devcontainer\volume_mount',target=/home/docker/docker-persisting-files,type=bind
```

All of the above combined gives us the following general startup command:
```
docker run -it -p 8889:8889 --mount src='C:\Users\Daan\Projects\Dev Container\devcontainer\volume_mount',target=/home/docker/docker-persisting-files,type=bind -e DISPLAY=host.docker.internal:0 devcontainer /bin/bash
```