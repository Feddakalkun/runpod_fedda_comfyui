# fedda_comfyui_runpod

Minimal RunPod-oppsett for en stabil ComfyUI-start med `WAN_22_XXX.json` ferdig lagt inn som vanlig workflow.

Publisert image er ment å bli:

- `ghcr.io/feddakalkun/runpod_fedda_comfyui:latest`

## Mål

- så rask og stabil oppstart som mulig
- bare ComfyUI, ingen ekstra backend eller FEDDA-UI
- kun custom nodes som `WAN_22_XXX.json` faktisk bruker
- workflowen kopieres automatisk til `user/default/workflows`
- modeller, input, output og brukerdata ligger i `/workspace` så liten storage kan brukes smart

## Innhold

- `Dockerfile` bygger et rent ComfyUI-image for RunPod
- `runpod_start.sh` symlinker `/workspace` inn i ComfyUI og starter serveren
- `install_nodes.sh` kloner node-repoene workflowen trenger
- `WAN_22_XXX.json` blir lagt inn ved oppstart
- `styles.csv` gir en minimal `No Style`-fil for `Load Styles CSV`-noden

## RunPod-template

Bruk repo-roten som build context og `Dockerfile` i repo-roten.

Hvis GitHub Actions-builden har kjørt ferdig, kan du i stedet bruke container-imaget direkte:

- `ghcr.io/feddakalkun/runpod_fedda_comfyui:latest`

Anbefalte template-verdier:

- Expose HTTP Port: `8188`
- Volume mount: `/workspace`
- Container start command: tom

Valgfrie env vars:

- `COMFY_PORT=8188`
- `COMFY_LISTEN=0.0.0.0`
- `FORCE_WORKFLOW_SYNC=1` hvis du vil overskrive workflow-filen ved hver boot
- `COMFY_EXTRA_ARGS=--disable-cuda-malloc` hvis vi ser at akkurat GPU-en trenger det

## Mapper i `/workspace`

Ved oppstart opprettes og kobles disse inn:

- `/workspace/models/*`
- `/workspace/input`
- `/workspace/output`
- `/workspace/user/default/workflows`

Det betyr at workflowen din ender her inne i podden:

- `/workspace/user/default/workflows/WAN_22_XXX.json`

## Workflow-avhengigheter

Denne workflowen bruker blant annet:

- Wan 2.2 core loaders i ComfyUI
- `ComfyUI-KJNodes`
- `rgthree-comfy`
- `ComfyUI-Easy-Use`
- `ComfyUI-Image-Selector`
- `ComfyUI_LayerStyle`
- `ComfyUI-Frame-Interpolation`
- `mikey_nodes`
- `ComfyUI-Custom-Scripts`
- `ComfyUI_essentials`
- `comfy-image-saver`
- `was-node-suite-comfyui`
- `ComfyUI-VideoHelperSuite`
- `ComfyUI-Studio-nodes`
- `ComfyUI-Styles_CSV_Loader`
- `ComfyUI-wanBlockswap`

## Modellfiler workflowen peker på

Workflowen refererer til minst disse basefilene:

- `diffusion_models/wan2.2_t2v_low_noise_14B_fp8_scaled.safetensors`
- `diffusion_models/wan2.2_t2v_high_noise_14B_fp8_scaled.safetensors`
- `diffusion_models/wan2.2_i2v_low_noise_14B_fp8_scaled.safetensors`
- `diffusion_models/wan2.2_i2v_high_noise_14B_fp8_scaled.safetensors`
- `clip/nsfw_wan_umt5-xxl_fp8_scaled.safetensors`
- `vae/wan_2.1_vae.safetensors`
- `clip_vision/clip_vision_h.safetensors`

Den har også en `HuggingFaceDownloader`-node som peker på flere LoRA-er og basefiler. For minimal storage bør vi i neste steg stramme inn den listen til bare de LoRA-ene du faktisk vil bruke aktivt.
