# Installation Guide

This document describes how to build, publish, and use the `llama-cpp-container` project.

---

# Prerequisites

## Local Environment

Required software:

* Docker Engine
* Git
* GitHub account
* GitHub Container Registry (GHCR) access

Recommended:

* GitHub Codespaces
* Visual Studio Code

---

# Clone the Repository

```bash
git clone https://github.com/tomoki-ueda-ds/llama-cpp-container.git

cd llama-cpp-container
```

---

# Generate the Dependency Lock File

If `uv.lock` does not exist, generate it with:

```bash
uv lock
```

Normally, `uv.lock` is committed to the repository and does not need to be regenerated.

---

# Build the Docker Image

```bash
docker build -t llama-cpp-container .
```

After a successful build, verify the image:

```bash
docker images
```

Expected output:

```text
llama-cpp-container    latest
```

---

# Run the Container

Example:

```bash
docker run --rm -it \
    llama-cpp-container \
    bash
```

To mount local models:

```bash
docker run --rm -it \
    -v $HOME/models:/models \
    llama-cpp-container \
    bash
```

---

# Publish to GitHub Container Registry

Login:

```bash
docker login ghcr.io
```

Tag the image:

```bash
docker tag llama-cpp-container \
    ghcr.io/tomoki-ueda-ds/llama-cpp-container:latest
```

Push:

```bash
docker push \
    ghcr.io/tomoki-ueda-ds/llama-cpp-container:latest
```

---

# Convert to an Apptainer Image

On the HPC system:

```bash
apptainer pull \
    llama-cpp-container.sif \
    docker://ghcr.io/tomoki-ueda-ds/llama-cpp-container:latest
```

---

# Verify the Container

Check the installed software:

```bash
llama-server --version

python3 --version

aider --version
```

If all commands execute successfully, the container is ready for use.

---

# Next Steps

After installation, continue with:

* `docs/HPC.md` for Slurm and Apptainer usage.
* `docs/MODEL.md` for downloading and managing GGUF models.
* `docs/AIDER.md` for configuring `aider` with `llama-server`.
