# Ollama Copilot on Docker

Run `Ollama-Copilot` in a Docker container.

Original repository:  
https://github.com/bernardo-bruning/ollama-copilot

## Tested Environment

- Windows 11 + WSL2 + Ubuntu 24.04
- GPU: Nvidia (GeForce 4070 Ti)

## Instructions

### 1. GPU Support

Refer to: https://hub.docker.com/r/ollama/ollama

```sh
# Ubuntu
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey \
    | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list \
    | sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' \
    | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

sudo apt-get update

sudo apt-get install -y nvidia-container-toolkit
```

**Note**: Running on a CPU may take a long time and could result in a timeout, so using a GPU is recommended.

### 2. Start the Server and Download the Model

```sh
# Start Ollama API server and Ollama-Copilot proxy server
docker compose up -d

# Download the model
docker compose exec ollama ollama pull codellama:code
```

### 3. Configure IDE for Ollama-Copilot

Configure your IDE for Ollama-Copilot following the instructions in the original repository:

https://github.com/bernardo-bruning/ollama-copilot?tab=readme-ov-file#configure-ide

- For local setups, you can keep the `localhost` settings.
- For remote setups, replace `localhost` with the appropriate IP address.

It should be ready to use now.

## Uninstallation

To completely remove the setup, run:

```sh
docker compose down
rm -rf ollama
```

## Additional Information

### Build

To build the Docker image:

```sh
docker build --tag docker.io/ryozitn/ollama-copilot .
```

### Copy Binary

To extract the `ollama-copilot` binary:

```sh
CONTAINER_ID=$(docker create docker.io/ryozitn/ollama-copilot)
docker cp ${CONTAINER_ID}:/app/ollama-copilot ./ollama-copilot-bin
docker rm $CONTAINER_ID

# Make the binary executable and run it
chmod +x ./ollama-copilot-bin
./ollama-copilot-bin --model=codellama:code
```

### Running on Podman with WSL

For running with Podman:

```sh
# Generate CDI configuration
sudo nvidia-ctk cdi generate --output=/etc/cdi/nvidia.yaml

# Verify the configuration
sudo nvidia-ctk cdi list

# INFO[0000] Found 1 CDI devices                          
# nvidia.com/gpu=all
```

In this case, specify `nvidia.com/gpu=all` in `compose.yml`.

```yaml
services:
  ollama:
    # ...
    devices:
      - nvidia.com/gpu=all
```

Replace `docker compose` with `podman-compose` (not `podman compose`).

```sh
# Start Ollama API server and Ollama-Copilot proxy server
podman-compose up -d

# Download the model
podman-compose exec ollama ollama pull codellama:code
```

If you prefer using `podman compose`, you may need to configure `containers.conf`:

```sh
# Reference: https://github.com/containers/common/blob/main/docs/containers.conf.5.md#engine-table
sudo mkdir -p /etc/containers/containers.conf.d/
sudo tee /etc/containers/containers.conf.d/engine.conf << "__EOF__"
[engine]
compose_providers=["/usr/bin/podman-compose"]
__EOF__
```