#!/bin/bash
set -euo pipefail

COMFY_DIR="/opt/ComfyUI"
WORKSPACE_DIR="${WORKSPACE_DIR:-/workspace}"
MODELS_DIR="${WORKSPACE_DIR}/models"
INPUT_DIR="${WORKSPACE_DIR}/input"
OUTPUT_DIR="${WORKSPACE_DIR}/output"
USER_DIR="${WORKSPACE_DIR}/user"
WORKFLOW_SRC_DIR="/opt/fedda/workflows"
WORKFLOW_DST_DIR="${USER_DIR}/default/workflows"

link_path() {
  local source_path="$1"
  local target_path="$2"

  rm -rf "${target_path}"
  ln -sfn "${source_path}" "${target_path}"
}

mkdir -p \
  "${MODELS_DIR}/checkpoints" \
  "${MODELS_DIR}/clip" \
  "${MODELS_DIR}/clip_vision" \
  "${MODELS_DIR}/controlnet" \
  "${MODELS_DIR}/diffusion_models" \
  "${MODELS_DIR}/embeddings" \
  "${MODELS_DIR}/loras" \
  "${MODELS_DIR}/style_models" \
  "${MODELS_DIR}/text_encoders" \
  "${MODELS_DIR}/unet" \
  "${MODELS_DIR}/upscale_models" \
  "${MODELS_DIR}/vae" \
  "${MODELS_DIR}/vae_approx" \
  "${INPUT_DIR}" \
  "${OUTPUT_DIR}" \
  "${WORKFLOW_DST_DIR}" \
  "${WORKSPACE_DIR}/.cache/huggingface" \
  "${WORKSPACE_DIR}/.cache/torch"

if [ -d "${COMFY_DIR}/user" ] && [ ! -L "${COMFY_DIR}/user" ]; then
  mkdir -p "${USER_DIR}"
  cp -an "${COMFY_DIR}/user/." "${USER_DIR}/" || true
fi

for subdir in checkpoints clip clip_vision controlnet diffusion_models embeddings loras style_models text_encoders unet upscale_models vae vae_approx; do
  link_path "${MODELS_DIR}/${subdir}" "${COMFY_DIR}/models/${subdir}"
done

link_path "${INPUT_DIR}" "${COMFY_DIR}/input"
link_path "${OUTPUT_DIR}" "${COMFY_DIR}/output"
link_path "${USER_DIR}" "${COMFY_DIR}/user"

if [ ! -f "${COMFY_DIR}/styles.csv" ]; then
  cp /opt/fedda/styles.csv "${COMFY_DIR}/styles.csv" 2>/dev/null || true
fi

for workflow_file in "${WORKFLOW_SRC_DIR}"/*.json; do
  workflow_name="$(basename "${workflow_file}")"
  if [ "${FORCE_WORKFLOW_SYNC:-0}" = "1" ] || [ ! -f "${WORKFLOW_DST_DIR}/${workflow_name}" ]; then
    cp "${workflow_file}" "${WORKFLOW_DST_DIR}/${workflow_name}"
  fi
done

echo "[fedda] workflow directory: ${WORKFLOW_DST_DIR}"
echo "[fedda] starting ComfyUI on ${COMFY_LISTEN:-0.0.0.0}:${COMFY_PORT:-8188}"

cd "${COMFY_DIR}"
args=(
  --listen "${COMFY_LISTEN:-0.0.0.0}"
  --port "${COMFY_PORT:-8188}"
  --enable-cors-header "${COMFY_CORS_ORIGIN:-*}"
  --preview-method auto
  --disable-auto-launch
)

if [ -n "${COMFY_EXTRA_ARGS:-}" ]; then
  # shellcheck disable=SC2206
  extra_args=( ${COMFY_EXTRA_ARGS} )
  args+=("${extra_args[@]}")
fi

exec python3 -u main.py "${args[@]}"
