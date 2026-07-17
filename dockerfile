FROM nvidia/cuda:12.8.1-devel-ubuntu24.04

ARG DEBIAN_FRONTEND=noninteractive
ARG LLAMA_CPP_REF=b9911

ENV PATH="/root/.local/bin:${PATH}"
ENV UV_LINK_MODE=copy
ENV UV_PROJECT_ENVIRONMENT=/opt/venv

# ----------------------------------------------------------------------
# System packages
# ----------------------------------------------------------------------

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        git \
        curl \
        ca-certificates \
        build-essential \
        cmake \
        ninja-build \
        pkg-config \
        libcurl4-openssl-dev \
        python3 \
        python3-pip \
        python3-venv \
        vim \
        tmux && \
    rm -rf /var/lib/apt/lists/*

# ----------------------------------------------------------------------
# Install uv
# ----------------------------------------------------------------------

RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# ----------------------------------------------------------------------
# Python environment (aider, MDAnalysis, etc.)
# ----------------------------------------------------------------------

WORKDIR /opt/llm-dev

COPY pyproject.toml .
COPY uv.lock .

RUN uv sync --frozen

# ----------------------------------------------------------------------
# Build llama.cpp
# ----------------------------------------------------------------------

WORKDIR /opt

RUN git clone https://github.com/ggml-org/llama.cpp.git

WORKDIR /opt/llama.cpp

RUN git checkout ${LLAMA_CPP_REF}

RUN cmake -B build \
    -DGGML_NATIVE=OFF \
    -DGGML_CUDA=ON \
    -DGGML_BACKEND_DL=ON \
    -DGGML_CPU_ALL_VARIANTS=ON \
    -DLLAMA_BUILD_TESTS=OFF \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_EXE_LINKER_FLAGS="-Wl,--allow-shlib-undefined"

RUN cmake --build build -j"$(nproc)"

# ----------------------------------------------------------------------
# Install llama.cpp runtime
# ----------------------------------------------------------------------

RUN mkdir -p /app/bin /app/lib

RUN find build -name "*.so*" -exec cp -P {} /app/lib \;

RUN cp build/bin/* /app/bin/

# ----------------------------------------------------------------------
# Open WebUI (separate virtual environment)
# ----------------------------------------------------------------------

RUN python3 -m venv /opt/open-webui && \
    /opt/open-webui/bin/python -m pip install --upgrade pip && \
    /opt/open-webui/bin/python -m pip install --no-cache-dir open-webui

# ----------------------------------------------------------------------
# Runtime environment
# ----------------------------------------------------------------------

ENV PATH="/opt/open-webui/bin:/opt/venv/bin:/app/bin:/root/.local/bin:${PATH}"
ENV LD_LIBRARY_PATH="/app/lib:${LD_LIBRARY_PATH}"

# ----------------------------------------------------------------------
# Workspace
# ----------------------------------------------------------------------

WORKDIR /workspace

COPY config/ /workspace/config/
COPY scripts/ /workspace/scripts/

RUN chmod +x /workspace/scripts/*.sh

ENTRYPOINT []

CMD ["/bin/bash"]