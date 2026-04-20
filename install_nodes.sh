#!/bin/bash
set -euo pipefail

COMFY_DIR="/opt/ComfyUI"
CUSTOM_NODES_DIR="${COMFY_DIR}/custom_nodes"

mkdir -p "${CUSTOM_NODES_DIR}"

clone_and_pin() {
  local repo_url="$1"
  local dir_name="$2"
  local commit_sha="${3:-}"

  if [ -d "${CUSTOM_NODES_DIR}/${dir_name}/.git" ]; then
    echo "[fedda] ${dir_name} already present"
    return 0
  fi

  echo "[fedda] cloning ${dir_name}"
  git clone --depth 1 "${repo_url}" "${CUSTOM_NODES_DIR}/${dir_name}"

  if [ -n "${commit_sha}" ]; then
    cd "${CUSTOM_NODES_DIR}/${dir_name}"
    git fetch --depth 1 origin "${commit_sha}" || git fetch origin "${commit_sha}"
    git checkout "${commit_sha}"
  fi
}

install_requirements_if_present() {
  local dir_name="$1"
  local req_file="${CUSTOM_NODES_DIR}/${dir_name}/requirements.txt"
  if [ -f "${req_file}" ]; then
    echo "[fedda] installing requirements for ${dir_name}"
    python3 -m pip install -r "${req_file}" || true
  fi
}

# Required by WAN_22_XXX.json
clone_and_pin "https://github.com/kijai/ComfyUI-KJNodes.git" "ComfyUI-KJNodes" "38cccdee6a484a702e4ac1a8b9a3cee0c4ed83f4"
clone_and_pin "https://github.com/rgthree/rgthree-comfy.git" "rgthree-comfy" "683836c46e898668936c433502504cc0627482c5"
clone_and_pin "https://github.com/yolain/ComfyUI-Easy-Use.git" "ComfyUI-Easy-Use" "ec4ca6717f539a8b8c48fa88645045846ca47669"
clone_and_pin "https://github.com/SLAPaper/ComfyUI-Image-Selector.git" "ComfyUI-Image-Selector" "058846b177626a226590d355a342ae8f364591ac"
clone_and_pin "https://github.com/chflame163/ComfyUI_LayerStyle.git" "ComfyUI_LayerStyle" "d94bef1ee5ed3656f5ff1bb2830a4ffd94f40935"
clone_and_pin "https://github.com/Fannovel16/ComfyUI-Frame-Interpolation.git" "ComfyUI-Frame-Interpolation" "26545cc2dd95bc3d27f056016300673bdeee78f5"
clone_and_pin "https://github.com/bash-j/mikey_nodes.git" "mikey_nodes" "a5aa9cf637c4aa83fb369230e1cd728f4f56a8de"
clone_and_pin "https://github.com/pythongosssss/ComfyUI-Custom-Scripts.git" "ComfyUI-Custom-Scripts" "609f3afaa74b2f88ef9ce8d939626065e3247469"
clone_and_pin "https://github.com/cubiq/ComfyUI_essentials.git" "ComfyUI_essentials" "9d9f4bedfc9f0321c19faf71855e228c93bd0dc9"
clone_and_pin "https://github.com/giriss/comfy-image-saver.git" "comfy-image-saver" "65e6903eff274a50f8b5cd768f0f96baf37baea1"
clone_and_pin "https://github.com/WASasquatch/was-node-suite-comfyui.git" "was-node-suite-comfyui" "ea935d1044ae5a26efa54ebeb18fe9020af49a45"
clone_and_pin "https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git" "ComfyUI-VideoHelperSuite" "2984ec4c4b93292421888f38db74a5e8802a8ff8"
clone_and_pin "https://github.com/comfyuistudio/ComfyUI-Studio-nodes.git" "ComfyUI-Studio-nodes" "bf2033a57c9add688b7bbcb97def54423bd8ca99"
clone_and_pin "https://github.com/theUpsider/ComfyUI-Styles_CSV_Loader.git" "ComfyUI-Styles_CSV_Loader"
clone_and_pin "https://github.com/orssorbit/ComfyUI-wanBlockswap.git" "ComfyUI-wanBlockswap"

for dir_name in \
  ComfyUI-KJNodes \
  rgthree-comfy \
  ComfyUI-Easy-Use \
  ComfyUI-Image-Selector \
  ComfyUI_LayerStyle \
  ComfyUI-Frame-Interpolation \
  mikey_nodes \
  ComfyUI-Custom-Scripts \
  ComfyUI_essentials \
  comfy-image-saver \
  was-node-suite-comfyui \
  ComfyUI-VideoHelperSuite \
  ComfyUI-Studio-nodes \
  ComfyUI-Styles_CSV_Loader \
  ComfyUI-wanBlockswap
do
  install_requirements_if_present "${dir_name}"
done
