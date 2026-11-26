# drama3-speechcpp

Container image for running **Drama-3-Japanese** (small-IQ3_XXS GGUF) with
**speech.cpp v0.11.2 + drama3-speechcpp-fast.patch** on a CUDA GPU.

- The image is built by GitHub Actions and published to GHCR.
- At container start, `entrypoint.sh` downloads the model (~9.8 GB) from
  Hugging Face (sha256-verified) and launches `speech serve`
  (OpenAI-compatible `POST /v1/audio/speech`) on port 8080.
- No secrets or model weights are contained in the image.

Model: [Aratako/Drama-3-Japanese](https://huggingface.co/Aratako/Drama-3-Japanese)
GGUF pack: [StudioYebisu-ship-it/Drama-3-Japanese-speech-cpp-gguf](https://huggingface.co/StudioYebisu-ship-it/Drama-3-Japanese-speech-cpp-gguf)
Runtime: [nyosegawa/speech.cpp](https://github.com/nyosegawa/speech.cpp)

The model is licensed under the Fish Audio Community License 1.0
(non-commercial research and personal use only).
