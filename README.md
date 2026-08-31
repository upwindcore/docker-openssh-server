
# OpenSSH Server in Docker

[OpenSSH](https://www.openssh.com/) is the premier connectivity tool for remote login with the SSH protocol. This container allows you to deploy a customizable Linux environment with SSH access.

This project is based on [Linuxeserver.io's openssh-server](https://github.com/linuxserver/docker-openssh-server) image. The base image for this version is Ubuntu.

## Setup

To set up the container, you can use docker-compose or the docker cli. Unless a parameter is flagged as 'optional', it is mandatory, and a value must be provided.

> [!TIP]
> * You can volume map your own text file to `/etc/motd` to override the message displayed upon connection.
> *  You can optionally set the `hostname` docker argument to change the hostname of the container.

### [docker-compose](https://docs.linuxserver.io/general/docker-compose) (recommended)

```yaml
---
services:
  openssh-server:
    image: ghcr.io/upwindcore/openssh-server:latest
    container_name: openssh-server
    hostname: openssh-server #optional
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Etc/UTC
      - PUBLIC_KEY=yourpublickey #optional
      - PUBLIC_KEY_FILE=/path/to/file #optional
      - PUBLIC_KEY_DIR=/path/to/directory/containing/_only_/pubkeys #optional
      - PUBLIC_KEY_URL=https://github.com/username.keys #optional
      - SUDO_ACCESS=false #optional
      - PASSWORD_ACCESS=false #optional
      - TCP_FORWARDING=false #optional
      - USER_PASSWORD=password #optional
      - USER_PASSWORD_FILE=/path/to/file #optional
      - USER_NAME=linuxserver.io #optional
      - LOG_STDOUT= #optional
    volumes:
      - /path/to/openssh-server/config:/config
    ports:
      - 2222:2222
    restart: unless-stopped
```

### [docker-cli](https://docs.docker.com/engine/reference/commandline/cli/)

```bash
docker run -d \
  --name=openssh-server \
  --hostname=openssh-server `#optional` \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Etc/UTC \
  -e PUBLIC_KEY=yourpublickey `#optional` \
  -e PUBLIC_KEY_FILE=/path/to/file `#optional` \
  -e PUBLIC_KEY_DIR=/path/to/directory/containing/_only_/pubkeys `#optional` \
  -e PUBLIC_KEY_URL=https://github.com/username.keys `#optional` \
  -e SUDO_ACCESS=false `#optional` \
  -e PASSWORD_ACCESS=false `#optional` \
  -e TCP_FORWARDING=false `#optional` \
  -e USER_PASSWORD=password `#optional` \
  -e USER_PASSWORD_FILE=/path/to/file `#optional` \
  -e USER_NAME=linuxserver.io `#optional` \
  -e LOG_STDOUT= `#optional` \
  -p 2222:2222 \
  -v /path/to/openssh-server/config:/config \
  --restart unless-stopped \
  ghcr.io/upwindcore/openssh-server:latest
```

## Config

If `PUBLIC_KEY` or `PUBLIC_KEY_FILE`, or `PUBLIC_KEY_DIR` variables are set, the specified keys will automatically be added to `authorized_keys`. If not, the keys can  be manually added to `/config/.ssh/authorized_keys` and the container should be restarted. Removing `PUBLIC_KEY` or `PUBLIC_KEY_FILE` variables from Docker run environment variables will not remove the keys from `authorized_keys`. `PUBLIC_KEY_FILE` and `PUBLIC_KEY_DIR` can be used with Docker secrets.

You can also set and allow password-based access via the `PASSWORD_ACCESS` and `USER_PASSWORD` variables. Setting `SUDO_ACCESS` to `true` by itself will allow passwordless sudo. `USER_PASSWORD` and `USER_PASSWORD_FILE` allow setting an optional sudo password.

Add any volume mappings you like for the users to have access to.

> [!NOTE]
> Additional and more in-depth configuration details can be found on Linuxserver.io's [openssh-server](https://docs.linuxserver.io/images/docker-openssh-server) documentation.

### Customization

To install packages or services for users to access, use the Linuxserver.io container customization methods described [in this blog article](https://blog.linuxserver.io/2019/09/14/customizing-our-containers/). 

You can also use their mods to further customize your environment. You can check out [this page](https://mods.linuxserver.io/) for a list of mods.

### Parameters

Containers are configured using parameters passed at runtime (such as those above). These parameters are separated by a colon and indicate `<external>:<internal>` respectively. For example, `-p 8080:80` would expose port `80` from inside the container to be accessible from the host's IP on port `8080` outside the container.

| Parameter | Function |
| :----: | --- |
| `--hostname=` | Optionally the hostname can be defined. |
| `-p 2222:2222` | ssh port |
| `-e PUID=1000` | for UserID - see below for explanation |
| `-e PGID=1000` | for GroupID - see below for explanation |
| `-e TZ=Etc/UTC` | specify a timezone to use, see this [list][tz]. |
| `-e PUBLIC_KEY=yourpublickey` | Optional ssh public key, which will automatically be added to authorized_keys. |
| `-e PUBLIC_KEY_FILE=/path/to/file` | Optionally specify a file containing the public key (works with docker secrets). |
| `-e PUBLIC_KEY_DIR=/path/to/directory/containing/_only_/pubkeys` | Optionally specify a directory containing the public keys (works with docker secrets). |
| `-e PUBLIC_KEY_URL=https://github.com/username.keys` | Optionally specify a URL containing the public key. |
| `-e SUDO_ACCESS=false` | Set to `true` to allow `user`, the ssh user, sudo access. Without `USER_PASSWORD` set, this will allow passwordless sudo access. |
| `-e PASSWORD_ACCESS=false` | Set to `true` to allow user/password ssh access. You will want to set `USER_PASSWORD` or `USER_PASSWORD_FILE` as well. |
| `-e TCP_FORWARDING=false` | Optionally set to `true` to allow TCP forwarding. Useful for IDEs. |
| `-e USER_PASSWORD=password` | Optionally set a sudo password for `linuxserver.io`, the ssh user. If this or `USER_PASSWORD_FILE` are not set but `SUDO_ACCESS` is set to true, the user will have passwordless sudo access. |
| `-e USER_PASSWORD_FILE=/path/to/file` | Optionally specify a file that contains the password. This setting supersedes the `USER_PASSWORD` option (works with docker secrets). |
| `-e USER_NAME=linuxserver.io` | Optionally specify a user name (Default:`linuxserver.io`) |
| `-e LOG_STDOUT=` | Set to `true` to log to stdout instead of file. |
| `-v /config` | Contains all relevant configuration files. |

## User and Group Identifiers

When using volumes (`-v` flags), permissions issues can arise between the host OS and the container. You can avoid this issue by setting the user `PUID` and group `PGID`. Ensure any volume directories on the host are owned by the same user you specify, and any permissions issues will vanish like magic.

In this instance `PUID=1000` and `PGID=1000`, to find yours use `id your_user` as below:

```bash
id your_user
```

Example output:

```text
uid=1000(your_user) gid=1000(your_user) groups=1000(your_user)
```

## Key Generation

This container has a helper script to generate an ssh private/public key. In order to generate a key please run:

```
docker run --rm -it --entrypoint /keygen.sh ghcr.io/upwindcore/openssh-server:latest
```

Then simply follow the prompts. **The keys generated by this script are only displayed on your console output, so make sure to save them somewhere after generation.**

## Usage

Connect to the server via `ssh -i /path/to/private/key -p PORT USER_NAME@SERVERIP` or `ssh -p PORT USER_NAME@SERVERIP`, depending on your configuration.
The users only have access to the folders mapped and the processes running inside this container.
