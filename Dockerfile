# Drama-3-Japanese (small-IQ3_XXS) speech.cpp CUDA image
# speech.cpp v0.11.2 + drama3-speechcpp-fast.patch (fetched from the GGUF pack repo, sha256-checked)
# Build runs on GitHub Actions -> GHCR. The image contains no secrets;
# the model is downloaded from Hugging Face at container start (see entrypoint.sh).

FROM nvidia/cuda:12.8.0-devel-ubuntu24.04 AS build
RUN apt-get update && apt-get install -y --no-install-recommends \
      git cmake build-essential ca-certificates curl \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /src
RUN git clone --recursive --depth 1 --branch v0.11.2 https://github.com/nyosegawa/speech.cpp .
RUN curl -L --fail -o /tmp/fast.patch \
      "https://huggingface.co/StudioYebisu-ship-it/Drama-3-Japanese-speech-cpp-gguf/resolve/main/drama3-speechcpp-fast.patch" \
    && echo "1d9c7c25928f1cc9000dd7bb5ff258652911d3cf1537a5847605281ab761e65f  /tmp/fast.patch" | sha256sum -c - \
    && git apply /tmp/fast.patch
RUN cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DGGML_CUDA=ON -DGGML_CUDA_GRAPHS=ON \
    && cmake --build build --target speech speech-cli -j"$(nproc)"

FROM nvidia/cuda:12.8.0-runtime-ubuntu24.04
RUN apt-get update && apt-get install -y --no-install-recommends \
      curl ca-certificates \
    && rm -rf /var/lib/apt/lists/*
COPY --from=build /src/build /opt/speech/build
COPY entrypoint.sh /opt/speech/entrypoint.sh
RUN chmod +x /opt/speech/entrypoint.sh
ENV SPEECH_DRAMA3_MAX_PAUSE_FRAMES=18 \
    MODEL_DIR=/models \
    DEVICE=CUDA0 \
    PORT=8080
EXPOSE 8080
ENTRYPOINT ["/opt/speech/entrypoint.sh"]
