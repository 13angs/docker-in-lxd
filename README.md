# Docker in LXD

- run the script to start creating a new container instance

```bash
# make the script executable
chmod +x run.sh

# run the script
./run.sh
```

- when finished, exec into the container

```bash
lxc exec <instance_name> bash 
```

- execute this command to install docker

```bash
curl -fsSL https://get.docker.com |bash
```

- test the docker

```bash
docker run hello-world
```