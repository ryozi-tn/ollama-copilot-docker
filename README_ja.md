Ollama Copilot on Docker
------------

`Ollama-Copilot`をDockerコンテナで動かします

Original repository:
https://github.com/bernardo-bruning/ollama-copilot

## 動作確認環境

- Windows 11 + WSL2 + Ubuntu 24.04
- GPU: Nvidia (GeForce 4070 Ti)

## 手順

### 1. GPU 対応

see: https://hub.docker.com/r/ollama/ollama

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

※CPUでは時間がかかりタイムアウトするのでお勧めしません

### 2. Serve と モデルのダウンロード

```sh
# Ollama APIサーバの起動と、Ollama-Copilotプロキシサーバの起動
docker compose up -d

# モデルのダウンロード
docker compose exec ollama ollama pull codellama:code
```

### 3. Configure IDE for Ollama-Copilot

Ollama-CopilotのIDEの設定を行ってください。

https://github.com/bernardo-bruning/ollama-copilot?tab=readme-ov-file#configure-ide

- ローカルで動作させている場合はlocalhostのままで構いません
- リモートで動作させている場合はlocalhostではなく該当のIPに変更してください

### 5. 動作確認



## アンインストール

完全に削除するには以下のようにしてください。

```
docker compose down
rm -rf ollama
```


## その他

### Build

```sh
docker build --tag docker.io/ryozitn/ollama-copilot .
```

### Copy Binary

ollama-copilotバイナリが欲しい場合は以下のようにします。

``` sh
CONTAINER_ID=$(docker create docker.io/ryozitn/ollama-copilot)

docker cp ${CONTAINER_ID}:/app/ollama-copilot ./ollama-copilot-bin

docker rm $CONTAINER_ID

# 実行
chmod +x ./ollama-copilot-bin
./ollama-copilot-bin --model=codellama:code
```

### Podman on WSL

Podmanで動作させる場合。

```sh
# CDI設定を生成
sudo nvidia-ctk cdi generate --output=/etc/cdi/nvidia.yaml

# 確認
sudo nvidia-ctk cdi list

# INFO[0000] Found 1 CDI devices                          
# nvidia.com/gpu=all
```

この場合、`nvidia.com/gpu=all` を `compose.yml`へ指定。

```yaml
services:
  ollama:
    # ...
    devices:
      - nvidia.com/gpu=all
```

`docker compose`を`podman-compose`に置き換えて実行する。（`podman compose`ではない）

```
# Ollama APIサーバの起動と、Ollama-Copilotプロキシサーバの起動
podman-compose up -d

# モデルのダウンロード
podman-compose exec ollama ollama pull codellama:code
```

もし`podman compose` で実行したい場合は`containers.conf`を用意するなどする。

```
# 参考: https://github.com/containers/common/blob/main/docs/containers.conf.5.md#engine-table
sudo mkdir -p /etc/containers/containers.conf.d/
sudo tee /etc/containers/containers.conf.d/engine.conf << "__EOF__"
[engine]
compose_providers=["/usr/bin/podman-compose"]
__EOF__
```
