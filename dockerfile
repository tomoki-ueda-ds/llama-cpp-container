FROM nvidia/cuda:12.8.1-devel-ubuntu24.04

ARG DEBIAN_FRONTEND=noninteractive
ARG LLAMA_CPP_REF=b9911

ENV UV_LINK_MODE=copy
ENV PATH="/root/.local/bin:${PATH}"

# ----------------------------------------------------------------------
# System packages
# ----------------------------------------------------------------------

RUN apt-get update && \
    apt-get install -y \
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
        tmux \
        vim && \
    rm -rf /var/lib/apt/lists/*

# ----------------------------------------------------------------------
# uv
# ----------------------------------------------------------------------

RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# ----------------------------------------------------------------------
# Python environment
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
    -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DGGML_CUDA=ON

RUN cmake --build build -j"$(nproc)"

RUN cmake --install build --prefix /usr/local

# ----------------------------------------------------------------------
# PATH
# ----------------------------------------------------------------------

ENV PATH="/usr/local/bin:${PATH}"
ENV LD_LIBRARY_PATH="/usr/local/lib:${LD_LIBRARY_PATH}"

# ----------------------------------------------------------------------
# Workspace
# ----------------------------------------------------------------------

WORKDIR /workspace

COPY scripts/ /workspace/scripts/
COPY config/ /workspace/config/

RUN chmod +x /workspace/scripts/*.sh

ENTRYPOINT []

CMD ["/bin/bash"]