#!/bin/sh
# 起動時にモデル（small-IQ3_XXS, 約9.8GB）を Hugging Face から取得してから
# speech serve（OpenAI互換の音声API, POST /v1/audio/speech）を起動する。
set -eu

MODEL_NAME="Drama-35B-A3B-Japanese-v3-small-IQ3_XXS"
MODEL_FILE="${MODEL_DIR}/${MODEL_NAME}.gguf"
SIDECAR_FILE="${MODEL_DIR}/${MODEL_NAME}.gguf.json"
BASE_URL="https://huggingface.co/StudioYebisu-ship-it/Drama-3-Japanese-speech-cpp-gguf/resolve/main"
# 公式 SHA256SUMS（SMALL）より：small-IQ3_XXS 本体のチェックサム
EXPECTED_SHA256="98edad9311a64ea07524f54f24d6d6db77055a3fe7233f24d3bd4351626d9338"

mkdir -p "${MODEL_DIR}"

if [ ! -f "${MODEL_FILE}" ]; then
  echo "[entrypoint] downloading model..."
  curl -L --fail --retry 3 -o "${MODEL_FILE}.tmp" "${BASE_URL}/${MODEL_NAME}.gguf"
  echo "${EXPECTED_SHA256}  ${MODEL_FILE}.tmp" | sha256sum -c -
  mv "${MODEL_FILE}.tmp" "${MODEL_FILE}"
fi

if [ ! -f "${SIDECAR_FILE}" ]; then
  echo "[entrypoint] downloading sidecar..."
  curl -L --fail --retry 3 -o "${SIDECAR_FILE}" "${BASE_URL}/${MODEL_NAME}.gguf.json"
fi

echo "[entrypoint] starting speech serve on port ${PORT} (device ${DEVICE})"
# exec せず終了コードをログに残す。終了後はコンテナを生かしてログを読めるようにする。
set +e
/opt/speech/build/speech serve "${MODEL_FILE}" \
  --device "${DEVICE}" \
  --host 0.0.0.0 \
  --port "${PORT}"
code=$?
echo "[entrypoint] speech serve exited with code ${code}"
sleep infinity
