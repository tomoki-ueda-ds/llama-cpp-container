# llama-cpp-container

Container image for running **llama.cpp** on NVIDIA GPUs in HPC environments using **Apptainer/Singularity** and **Slurm**.

This project provides:

* CUDA-enabled `llama.cpp`
* Python environment managed by `uv`
* `aider` for AI-assisted development
* Ready-to-use startup scripts
* GitHub Actions for automatic container builds

---

# Features

* Ubuntu 24.04 + CUDA 12.8
* `llama.cpp` built from a fixed Git commit
* GPU support enabled (`GGML_CUDA=ON`)
* Python environment managed with `uv`
* `aider` pre-installed
* Designed for Apptainer/Singularity
* Designed for Slurm-based HPC systems

---

# Repository Layout

```
.
├── config/
│   ├── llama-server.conf
│   └── model.conf
│
├── scripts/
│   ├── run-server.sh
│   ├── run-aider.sh
│   ├── run-slurm.sh
│   ├── run-interactive.sh
│   └── start-server.sh
│
├── Dockerfile
├── pyproject.toml
├── uv.lock
└── README.md
```

---

# Build

Build locally.

```bash
docker build -t llama-cpp-container .
```

GitHub Actions automatically builds and publishes

```
ghcr.io/<user>/llama-cpp-container:latest
```

after every push to the main branch.

---

# Download as Apptainer Image

```bash
apptainer pull \
    llama-cpp-container_latest.sif \
    docker://ghcr.io/<user>/llama-cpp-container:latest
```

---

# Model Directory

Models are **not included** in the container.

Example:

```
$HOME/models/
└── Qwen3.6-35B-A3B/
    └── Qwen3.6-35B-A3B-Q8_0.gguf
```

When starting the container, bind the directory:

```bash
apptainer shell \
    --nv \
    --bind $HOME/models:/models \
    llama-cpp-container_latest.sif
```

Inside the container the model becomes available as

```
/models/Qwen3.6-35B-A3B/Qwen3.6-35B-A3B-Q8_0.gguf
```

---

# Configuration

## llama-server.conf

`config/llama-server.conf` stores common runtime options.

Example:

```
--ctx-size 32768
-ngl 999
--flash-attn auto
--batch-size 2048
--ubatch-size 512
--threads -1
```

The model path is **not** specified here.

---

## model.conf

`config/model.conf` stores the default model path.

Example:

```
MODEL=/models/Qwen3.6-35B-A3B/Qwen3.6-35B-A3B-Q8_0.gguf
```

---

# Scripts

## run-server.sh

Starts `llama-server` using the model specified in `model.conf`.

```
run-server.sh
        │
        ▼
start-server.sh
        │
        ▼
llama-server
```

This is the script users should normally execute.

---

## start-server.sh

Low-level launcher.

Reads `llama-server.conf` and starts `llama-server`.

Normally called from other scripts.

---

## run-aider.sh

Starts `aider` configured to use the local `llama-server`.

Environment variables are configured automatically.

---

## run-slurm.sh

Convenience wrapper intended for execution inside Slurm jobs.

Prints job information before starting the server.

---

## run-interactive.sh

Displays environment information.

Checks:

* Python
* llama-server
* aider
* mounted model directory

before opening an interactive shell.

---

# Typical Workflow

## 1. Obtain GPU allocation

```bash
srun ...
```

---

## 2. Start the container

```bash
apptainer shell \
    --nv \
    --bind $HOME/models:/models \
    llama-cpp-container_latest.sif
```

---

## 3. Move to the workspace

```bash
cd /workspace
```

---

## 4. Start llama-server

```bash
./scripts/run-server.sh
```

---

## 5. Open another terminal on the same compute node

```bash
apptainer shell \
    --nv \
    --bind $HOME/models:/models \
    llama-cpp-container_latest.sif

cd /workspace

./scripts/run-aider.sh
```

---

# Manual Start

The server can also be started directly.

```bash
llama-server \
    -m /models/Qwen3.6-35B-A3B/Qwen3.6-35B-A3B-Q8_0.gguf \
    --ctx-size 32768 \
    -ngl 999 \
    --flash-attn auto
```

---

# Requirements

* NVIDIA GPU
* CUDA driver compatible with CUDA 12.8
* Apptainer/Singularity
* Slurm (optional)

---

# License

Please refer to the licenses of the individual projects:

* llama.cpp
* aider
* uv
