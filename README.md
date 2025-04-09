# Docker Forcepoint

This project provides a Dockerized setup for accessing CMCC Forcepoint VPN services on a fully supported Ubuntu 20.04 OS. It provides a simple and reproducible way to access CMCC VPN from any Linux OS.

## Features

- **CMCC Forcepoint VPN Client**: Runs the CMCC Forcepoint VPN client in a containerized environment.
- **Firefox Browser**: Includes a pre-configured Firefox browser for browsing via the VPN.
- **Audio Support**: Ensures the container has access to audio devices.
- **X11 Display Support**: Allows the container to access the host's X11 display for GUI applications.
- **Customizable Environment**: Supports configuration through environment variables.

## Prerequisites

- Docker and Docker Compose installed on your system.
- Access to the required VPN credentials and OTP.

## Getting Started

1. Clone the repository:

    ```bash
    git clone https://github.com/your-username/docker-forcepoint.git
    cd docker-forcepoint
    ```

2. Update the user.env file with your VPN credentials:

    ```env
        VPN_USERNAME=<your-CMCC-username>
        VPN_PASSWORD=<your-CMCC-password>
    ```

3. Build the Docker image:

    ```bash
    docker compose build -t forcepoint-cmcc .
    ```

4. Run the container:

    ```bash
    VPN_OTP=<your-CMCC-OTPcode> docker compose run --name forcepoint-cmcc-container forcepoint-cmcc
    ```

## Configuration

- **Environment Variables**:
  - `VPN_IPADDR`: The IP address of the VPN server.
  - `VPN_USERNAME`: Your VPN username.
  - `VPN_PASSWORD`: Your VPN password.
  - `VPN_OTP`: One-time password for VPN authentication.
  - `DISPLAY`: Host's X11 display variable.
  - `VPN_DNS`: DNS server for the VPN.

## Files Overview

- **`Dockerfile`**: Defines the Docker image, including the installation of the Forcepoint VPN client and Firefox browser.
- **`docker-compose.yml`**: Configures the Docker Compose service for the VPN client.
- **`add_user_to_audio_group.sh`**: Ensures the user has access to audio devices.
- **`setup_access_to_host_display.sh`**: Configures X11 display access for GUI applications.
- **`docker-ubuntu-x_startup.sh`**: Startup script for initializing the container environment.
- **`docker-forcepoint.sh`**: Main entry point for starting the VPN client and Firefox.
- **`config`**: SSH configuration for connecting to remote hosts.
- **`user.env`**: Stores user-specific environment variables for the VPN client.

## Troubleshooting

- Ensure that your host system has the required permissions to share devices like `/dev/snd` and `/tmp/.X11-unix` with the container.
- The container runs in privileged mode to allow access to network and audio devices.

## License

This project is licensed under the GNU GPLv3.

## Acknowledgments

Original scripts and Firefox docker configuration by Robert Cernansky.
