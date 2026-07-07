# GGUF Model Guide

This document describes how to obtain, store, and use GGUF models with `llama-cpp-container`.

The container is intentionally designed **not** to include any LLM model. Models are stored on the host system and mounted into the container at runtime.

---

# Model Storage

Recommended directory:

```text
$HOME/models/
```

Example:

```text
$HOME/models/
├── Qwen2.5-Coder-32B-Instruct-Q5_K_M.gguf
├── Qwen2.5-Coder-14B-Instruct-Q5_K_M.gguf
└── DeepSeek-Coder-V2-Lite-Q5_K_M.gguf
```

Keeping models outside the container allows you to:

* reuse models across container updates
* avoid rebuilding the container when adding new models
* share the same model directory between multiple container versions

---

# Downloading a Model

The repository provides a helper script.

Example:

```bash
./scripts/download-model.sh \
    bartowski/Qwen2.5-Coder-32B-Instruct-GGUF \
    Qwen2.5-Coder-32B-Instruct-Q5_K_M.gguf
```

By default, the model is downloaded into:

```text
$HOME/models
```

A different destination may be specified as the third argument.

---

# Mounting the Model Directory

When starting the container, bind the model directory.

Example:

```bash
apptainer exec \
    --nv \
    --bind $HOME/models:/models \
    llama-cpp-container.sif \
    bash
```

Inside the container, the model becomes available as:

```text
/models/Qwen2.5-Coder-32B-Instruct-Q5_K_M.gguf
```

---

# Starting llama-server

Launch the server with the desired model.

```bash
./scripts/start-server.sh \
    /models/Qwen2.5-Coder-32B-Instruct-Q5_K_M.gguf
```

The remaining server parameters are loaded automatically from:

```text
config/llama-server.conf
```

---

# Recommended Models

## Qwen2.5-Coder-32B-Instruct

Recommended for:

* Python development
* Bash scripting
* Scientific computing
* Molecular dynamics analysis
* Large codebases

Typical quantization:

```text
Q5_K_M
```

---

## Qwen2.5-Coder-14B-Instruct

Recommended for:

* Faster startup
* Lower GPU memory usage
* Interactive coding
* General-purpose development

Typical quantization:

```text
Q5_K_M
```

---

## DeepSeek-Coder-V2-Lite

Recommended for:

* Lightweight experimentation
* Rapid iteration
* Small scripting tasks

Typical quantization:

```text
Q5_K_M
```

---

# Selecting a Quantization

Common choices:

| Quantization | Characteristics                                                     |
| ------------ | ------------------------------------------------------------------- |
| Q4_K_M       | Lowest memory usage, fastest loading                                |
| Q5_K_M       | Recommended balance of quality and memory                           |
| Q6_K         | Higher quality with increased memory usage                          |
| Q8_0         | Highest quality among common quantizations, larger memory footprint |

For an H100 (80 GB), `Q5_K_M` is generally a good default for code-oriented models.

---

# Verifying the Model

Confirm that the model file exists.

```bash
ls -lh /models
```

Then verify that `llama-server` can load it.

```bash
./scripts/start-server.sh \
    /models/Qwen2.5-Coder-32B-Instruct-Q5_K_M.gguf
```

In another shell, run:

```bash
./scripts/healthcheck.sh
```

A successful health check indicates that the model has been loaded and the OpenAI-compatible API is ready to accept requests.

---

# Updating Models

To replace a model:

1. Download the new GGUF file into the model directory.
2. Stop the running `llama-server`.
3. Restart `llama-server` with the new model path.

No container rebuild is required.

---

# Best Practices

* Keep all GGUF models outside the container.
* Maintain a single shared model directory.
* Use descriptive filenames that include the model name and quantization.
* Validate newly downloaded models before using them in production workflows.
* Retain previous model versions if reproducibility is important for research projects.
