ARG CUDA_IMAGE=nvidia/cuda:12.4.1-runtime-ubuntu22.04
FROM ${CUDA_IMAGE}

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PYTHONIOENCODING=utf-8 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    HF_HOME=/workspace/.cache/huggingface \
    TORCH_HOME=/workspace/.cache/torch \
    PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True \
    COMFY_PORT=8188 \
    COMFY_LISTEN=0.0.0.0 \
    COMFY_CORS_ORIGIN=*

ARG COMFYUI_COMMIT=a2840e75520b7dc40958866b3c4da1345d5cfa9c
ARG TORCH_INDEX_URL=https://download.pytorch.org/whl/cu124

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    ffmpeg \
    git \
    git-lfs \
    libgl1 \
    libglib2.0-0 \
    python3.11 \
    python3-pip \
    python3-venv \
    && ln -sf /usr/bin/python3.11 /usr/bin/python3 \
    && rm -rf /var/lib/apt/lists/*

RUN git lfs install --system \
    && python3 -m pip install --upgrade pip setuptools wheel

RUN python3 -m pip install \
    torch torchvision torchaudio \
    --index-url ${TORCH_INDEX_URL}

RUN python3 -m pip install xformers --index-url ${TORCH_INDEX_URL} || true
RUN python3 -m pip install sageattention || true

RUN git clone https://github.com/comfyanonymous/ComfyUI.git /opt/ComfyUI \
    && cd /opt/ComfyUI \
    && git checkout "${COMFYUI_COMMIT}" \
    && python3 -m pip install -r requirements.txt

COPY install_nodes.sh /opt/install_nodes.sh
RUN chmod +x /opt/install_nodes.sh && /opt/install_nodes.sh

COPY styles.csv /opt/ComfyUI/styles.csv
COPY styles.csv /opt/fedda/styles.csv
COPY WAN_22_XXX.json /opt/fedda/workflows/WAN_22_XXX.json
COPY WAN_22_XXX_img2vid.json /opt/fedda/workflows/WAN_22_XXX_img2vid.json
COPY runpod_start.sh /usr/local/bin/runpod_start.sh

RUN chmod +x /usr/local/bin/runpod_start.sh \
    && mkdir -p /workspace

WORKDIR /opt/ComfyUI

EXPOSE 8188

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=5 \
    CMD bash -lc 'curl -fsS "http://127.0.0.1:${COMFY_PORT:-8188}/system_stats" >/dev/null || exit 1'

ENTRYPOINT ["/usr/local/bin/runpod_start.sh"]
