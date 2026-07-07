# HPC Usage Guide

This document describes how to use the `llama-cpp-container` on a Slurm-managed HPC cluster with Apptainer.

The examples assume the following environment:

* Slurm scheduler
* NVIDIA DGX H100
* Apptainer
* GGUF models stored outside the container
* `llama-server` as the inference engine

---

# Assumed Directory Layout

```text
$HOME/
├── models/
│   └── Qwen2.5-Coder-32B-Instruct-Q5_K_M.gguf
│
├── containers/
│   └── llama-cpp-container.sif
│
└── workspace/
    └── md-project/
```
Please rewrite it to use the appropriate directory structure as needed

---

# Obtain an Interactive GPU Session

Example:

```bash
srun \
    --partition=gpu \
    --gres=gpu:1 \
    --cpus-per-task=16 \
    --mem=64G \
    --time=08:00:00 \
    --pty bash
```

After the allocation is complete, you will be placed on a compute node.

---

# Start the Container

Mount the GGUF model directory into the container.

```bash
apptainer exec \
    --nv \
    --bind $HOME/models:/models \
    $HOME/containers/llama-cpp-container.sif \
    bash
```

---

# Verify the Environment

Check the installed software.

```bash
llama-server --version

python3 --version

aider --version
```

---

# Start llama-server

Launch the server using the provided script.

```bash
./scripts/start-server.sh \
    /models/Qwen2.5-Coder-32B-Instruct-Q5_K_M.gguf
```

By default, the server listens on:

```text
http://0.0.0.0:8000
```

---

# Verify the Server

Open another shell inside the same allocation and run:

```bash
./scripts/healthcheck.sh
```

A successful check confirms that:

* `llama-server` is running
* the `/health` endpoint responds
* the OpenAI-compatible API is available

---

# Connect aider

Configure the environment.

```bash
export OPENAI_API_BASE=http://localhost:8000/v1
export OPENAI_API_KEY=dummy
```

Start `aider`.

```bash
aider
```

---

# Run as a Batch Job

A typical Slurm submission script:

```bash
#!/bin/bash
#SBATCH --job-name=llama-server
#SBATCH --partition=gpu
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=08:00:00

apptainer exec \
    --nv \
    --bind $HOME/models:/models \
    $HOME/containers/llama-cpp-container.sif \
    ./scripts/run-slurm.sh \
    /models/Qwen2.5-Coder-32B-Instruct-Q5_K_M.gguf
```

Submit the job.

```bash
sbatch job.sh
```

---

# Accessing the API from a Login Node

If direct access to the compute node is restricted, create an SSH tunnel from the login node.

Example:

```bash
ssh -L 8000:<compute-node>:8000 <login-node>
```

After the tunnel is established, the API is available locally at:

```text
http://localhost:8000/v1
```

---

# Stopping the Server

If `llama-server` is running in the foreground:

```bash
Ctrl+C
```

For a Slurm batch job:

```bash
scancel <job_id>
```

---

# Notes

* Store GGUF models outside the container.
* Reuse the same model directory across container updates.
* Run only one `llama-server` instance per allocated GPU unless resource sharing is intentionally configured.
* The container is intended for single-user interactive development and scientific scripting within a Slurm allocation.
