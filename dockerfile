FROM ghcr.io/ggml-org/llama.cpp:server-cuda

LABEL org.opencontainers.image.title="llama-cpp-container"
LABEL org.opencontainers.image.description="HPC Local LLM Development Environment"
LABEL org.opencontainers.image.version="1.0.0"

ENV DEBIAN_FRONTEND=noninteractive
ENV UV_PROJECT_ENVIRONMENT=/opt/venv
ENV PATH="/opt/venv/bin:/root/.local/bin:${PATH}"

RUN apt-get update && \
    apt-get install -y \
        python3 \
        python3-pip \
        python3-venv \
        git \
        curl \
        vim \
        tmux \
        less \
        tree \
        jq \
        ripgrep \
        fd-find \
        unzip && \
    rm -rf /var/lib/apt/lists/*

RUN curl -LsSf https://astral.sh/uv/install.sh | sh

WORKDIR /opt/llm-dev

COPY pyproject.toml .
COPY uv.lock .

RUN uv sync --frozen

COPY scripts/ /workspace/scripts/
COPY config/ /workspace/config/

WORKDIR /workspace

CMD ["/bin/bash"]
