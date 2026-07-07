# Aider Integration Guide

This document describes how to use **aider** with `llama.cpp` through the OpenAI-compatible API provided by `llama-server`.

The intended workflow is interactive software development for scientific computing, including:

* Python scripting
* Bash scripting
* Molecular dynamics analysis
* Data processing
* Code review
* Refactoring

---

# Architecture

```text
                     +---------------------+
                     |     GGUF Model      |
                     +----------+----------+
                                |
                                |
                     +----------v----------+
                     |    llama-server     |
                     |  OpenAI-Compatible  |
                     |        API          |
                     +----------+----------+
                                |
                    http://localhost:8000/v1
                                |
                     +----------v----------+
                     |       aider         |
                     +----------+----------+
                                |
                     +----------v----------+
                     |   Your Source Code  |
                     +---------------------+
```

---

# Start llama-server

Before launching `aider`, start the LLM server.

Example:

```bash
./scripts/start-server.sh \
    /models/Qwen4-Coder-32B-Instruct-Q5_K_M.gguf
```

Wait until the server finishes loading the model.

---

# Verify the Server

Confirm that the API is available.

```bash
./scripts/healthcheck.sh
```

A successful health check indicates that the OpenAI-compatible API is ready.

---

# Configure aider

Set the API endpoint.

```bash
export OPENAI_API_BASE=http://localhost:8000/v1
export OPENAI_API_KEY=dummy
```

The API key is required only because the OpenAI client expects one. It is **not** used for authentication by the local server.

---

# Launch aider

Move to your project directory.

Example:

```bash
cd ~/workspace/md-project
```

Start `aider`.

```bash
aider
```

---

# Typical Workflow

A typical development session consists of:

1. Obtain a Slurm allocation.
2. Start the Apptainer container.
3. Launch `llama-server`.
4. Verify the server with `healthcheck.sh`.
5. Configure the OpenAI-compatible environment variables.
6. Start `aider`.
7. Develop and refine code interactively.

---

# Example Tasks

Typical prompts include:

* Write an MDAnalysis script to calculate RMSD from a GROMACS trajectory.
* Create a Python script to calculate the radius of gyration.
* Generate a Bash script for batch trajectory analysis.
* Refactor an existing analysis script.
* Explain an error message from a Slurm job.
* Improve the performance of a NumPy-based analysis script.
* Add logging and command-line argument support to a Python program.

---

# Working with Existing Projects

Open `aider` from the root of your project.

Example:

```text
md-project/
├── analysis.py
├── trajectory.xtc
├── topology.tpr
├── run.sh
└── README.md
```

Launch:

```bash
cd md-project

aider
```

`aider` will work directly with the project files.

---

# Recommended Usage

For large scientific projects:

* Keep source code under Git version control.
* Commit frequently.
* Review changes proposed by `aider` before accepting them.
* Test generated scripts on representative datasets.
* Use descriptive prompts that include the scientific objective.

---

# Troubleshooting

## Connection Error

Check that `llama-server` is running.

```bash
./scripts/healthcheck.sh
```

Verify the environment variables.

```bash
echo $OPENAI_API_BASE
echo $OPENAI_API_KEY
```

---

## Model Not Found

Confirm that the model directory is mounted.

```bash
ls /models
```

Restart the server if necessary.

---

## Slow Responses

Possible causes include:

* Large context size
* Large GGUF model
* Simultaneous GPU workloads
* Insufficient CPU resources allocated by Slurm

Monitor resource usage and adjust the Slurm allocation if required.

---

# Best Practices

* Run one `llama-server` instance per allocated GPU.
* Keep the model directory outside the container.
* Use `Q5_K_M` quantized models as the default starting point.
* Keep prompts focused and provide sufficient code context.
* Review and validate all generated code before using it in production or research workflows.
