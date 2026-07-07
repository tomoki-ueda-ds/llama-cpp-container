# llama-cpp-container
A reproducible HPC container for local LLM-assisted scientific computing using **llama.cpp**, designed for **Slurm-managed NVIDIA DGX H100** environments.

This project provides a container image that combines:

- **llama.cpp (`llama-server`)**
- **GGUF models**
- **Python 3.12**
- **uv**
- **aider**
- Scientific Python libraries for molecular dynamics analysis

The container is built with Docker, published to GitHub Container Registry (GHCR), and executed on HPC systems using Apptainer.

---

# Features

- Official `llama.cpp` CUDA container as the base image
- Optimized for NVIDIA H100
- OpenAI-compatible API via `llama-server`
- GGUF models stored outside the container
- Python environment managed with `uv`
- Preinstalled scientific libraries
    - NumPy
    - SciPy
    - Pandas
    - Matplotlib
    - MDAnalysis
    - MDTraj
- Preinstalled `aider`
- Designed for Slurm interactive and batch jobs
- Container image distributed through GHCR

---

# Repository Structure

```text
llama-cpp-container/
│
├── Dockerfile
├── pyproject.toml
├── uv.lock
├── .dockerignore
├── README.md
│
├── config/
│   └── llama-server.conf
│
├── scripts/
│   ├── start-server.sh
│   ├── run-interactive.sh
│   ├── run-slurm.sh
│   ├── download-model.sh
│   └── healthcheck.sh
│
├── docs/
│   ├── INSTALL.md
│   ├── HPC.md
│   ├── MODEL.md
│   └── AIDER.md
│
└── .github/
    └── workflows/
        ├── build.yml
        └── release.yml
```

---

# Requirements

## Local Development

- Docker Engine
- Git
- GitHub account
- GitHub Container Registry (GHCR)

## HPC Environment

- NVIDIA H100 GPU
- Slurm
- Apptainer
- CUDA-compatible NVIDIA driver

---

# Build

Clone the repository.

```bash
git clone https://github.com/<YOUR_ACCOUNT>/llama-cpp-container.git
cd llama-cpp-container
```

Build the image.

```bash
docker build -t llama-cpp-container .
```

---

# Publish to GHCR

After authentication,

```bash
docker tag llama-cpp-container ghcr.io/<YOUR_ACCOUNT>/llama-cpp-container:latest

docker push ghcr.io/<YOUR_ACCOUNT>/llama-cpp-container:latest
```

GitHub Actions can also publish automatically.

---

# Convert to Apptainer

On the HPC system,

```bash
apptainer pull \
    llama-cpp-container.sif \
    docker://ghcr.io/<YOUR_ACCOUNT>/llama-cpp-container:latest
```

---

# Model Directory

GGUF models are intentionally stored outside the container.

Recommended location:

```text
$HOME/models/
```

Example:

```text
$HOME/models/
└── qwen2.5-coder-32b-instruct-q5_k_m.gguf
```

---

# Starting llama-server

Example:

```bash
llama-server \
    -m /models/qwen2.5-coder-32b-instruct-q5_k_m.gguf \
    --host 0.0.0.0 \
    --port 8000 \
    --ctx-size 32768 \
    --flash-attn \
    -ngl 99
```

The server exposes an OpenAI-compatible API.

---

# Using aider

Set the OpenAI-compatible endpoint.

```bash
export OPENAI_API_BASE=http://localhost:8000/v1
export OPENAI_API_KEY=dummy
```

Launch aider.

```bash
aider
```

---

# Typical Workflow

1. Obtain an interactive Slurm session.
2. Start the container with Apptainer.
3. Launch `llama-server`.
4. Connect `aider`.
5. Develop Python or Bash scripts interactively.
6. Execute the generated scripts on the HPC system.

---

# Intended Use

This project is intended for:

- Molecular dynamics trajectory analysis
- Scientific Python development
- Bash scripting
- Code generation
- Code review
- Data analysis
- Interactive research support

---

# License

This repository is released under the MIT License.

Please refer to the licenses of each bundled dependency, including:

- llama.cpp
- aider
- MDAnalysis
- MDTraj