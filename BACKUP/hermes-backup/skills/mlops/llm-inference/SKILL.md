---
name: llm-inference
description: "Run LLMs locally (llama.cpp / GGUF for CPU/edge) or at production scale (vLLM for GPU serving). Model discovery on HF Hub, quantization, OpenAI-compatible API. Umbrella covering all self-hosted LLM inference."
version: 1.0.0
author: Hermes Agent
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [llm-inference, llama.cpp, vllm, gguf, quantization, serving, huggingface]
    related_skills: [huggingface-hub, evaluating-llms-harness]
---

# LLM Inference: Local & Production Serving

This umbrella covers two major LLM inference engines. Both serve the same class of task — running LLM models on your own hardware — but target different profiles:

| Dimension | llama.cpp | vLLM |
|-----------|-----------|------|
| **Hardware** | CPU, Apple Silicon, modest GPUs | NVIDIA GPU, AMD ROCm, Intel |
| **Deployment** | Single-user, edge, desktop | Multi-user, production API |
| **Model format** | GGUF (quantized) | HF Transformers (AWQ/GPTQ/FP8) |
| **Throughput** | Low (1-20 tok/s) | High (100-10000+ tok/s) |
| **Best for** | Local dev, offline, privacy-critical | Production APIs, batch inference |

**Common concerns** (covered in both subsections):
- Hugging Face Hub model discovery
- Quantization tradeoffs
- OpenAI-compatible API patterns
- GPU memory management

---

## Section A: llama.cpp — Local GGUF Inference

### Quick Start

```bash
# Install
brew install llama.cpp     # macOS/Linux
git clone https://github.com/ggml-org/llama.cpp && cd llama.cpp && cmake -B build && cmake --build build --config Release

# Run directly from HF Hub
llama-server -hf bartowski/Llama-3.2-3B-Instruct-GGUF:Q8_0

# OpenAI-compatible check
curl http://localhost:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"messages":[{"role":"user","content":"Hello"}],"max_tokens":256}'
```

### Hugging Face Model Discovery (for GGUF)

Prefer URL workflows. Search: `https://huggingface.co/models?apps=llama.cpp&sort=trending`

For a specific repo: `https://huggingface.co/<repo>?local-app=llama.cpp` — shows the exact `llama-server` command and recommended quant.

Query the tree API for available GGUFs: `https://huggingface.co/api/models/<repo>/tree/main?recursive=true`

### Choosing a Quant

| Budget | Recommended | Quality |
|--------|-------------|---------|
| Generous RAM | Q5_K_M or Q6_K | Near lossless |
| Typical | Q4_K_M | Good balance |
| Tight | Q3_K_M or IQ4_NL | Acceptable |
| Extremely tight | Q2_K or IQ2_XXS | Degraded |

Prefer the exact quant that HF marks as compatible for the user's hardware.

### Python Bindings

```python
from llama_cpp import Llama
llm = Llama(model_path="./model-q4_k_m.gguf", n_ctx=4096, n_gpu_layers=35)
print(llm("What is ML?", max_tokens=256)["choices"][0]["text"])
```

### Key References

| File | Contents |
|------|----------|
| `references/llamacpp-hub-discovery.md` | URL-only HF workflows, GGUF extraction |
| `references/llamacpp-advanced-usage.md` | Speculative decoding, LoRA, multi-GPU, grammar |
| `references/llamacpp-quantization.md` | Quant quality tradeoffs, model size, imatrix |
| `references/llamacpp-server.md` | Direct-from-Hub server, Docker, NGINX, monitoring |
| `references/llamacpp-optimization.md` | CPU threading, BLAS, GPU offload, bench |
| `references/llamacpp-troubleshooting.md` | Install/convert/quantize/inference issues |

---

## Section B: vLLM — Production GPU Serving

### Quick Start

```bash
pip install vllm

# Offline inference
python -c "
from vllm import LLM, SamplingParams
llm = LLM(model='meta-llama/Llama-3-8B-Instruct')
print(llm.generate(['Explain quantum computing'], SamplingParams(temperature=0.7, max_tokens=256))[0].outputs[0].text)
"

# API server
vllm serve meta-llama/Llama-3-8B-Instruct

# Query
python -c "
from openai import OpenAI
c = OpenAI(base_url='http://localhost:8000/v1', api_key='EMPTY')
print(c.chat.completions.create(model='meta-llama/Llama-3-8B-Instruct', messages=[{'role':'user','content':'Hello!'}]).choices[0].message.content)
"
```

### Production Configuration

```bash
# 7B-13B on single GPU
vllm serve MODEL --gpu-memory-utilization 0.9 --max-model-len 8192

# 70B with tensor parallelism
vllm serve MODEL --tensor-parallel-size 4 --quantization awq

# With prefix caching and metrics
vllm serve MODEL --enable-prefix-caching --enable-metrics --metrics-port 9090
```

### Quantization Methods

| Method | Best for | VRAM savings |
|--------|----------|-------------|
| AWQ | 70B models, minimal loss | ~50% |
| GPTQ | Wide model support | ~50% |
| FP8 | H100 GPUs, fastest | ~50% |

### Key References

| File | Contents |
|------|----------|
| `references/vllm-quantization.md` | AWQ/GPTQ/FP8 setup, model prep, accuracy |
| `references/vllm-server-deployment.md` | Docker, Kubernetes, load balancing |
| `references/vllm-optimization.md` | PagedAttention tuning, continuous batching |
| `references/vllm-troubleshooting.md` | Error messages, debugging, performance diag |

---

## When to Use Each

**Use llama.cpp when:**
- Running on CPU, Apple Silicon, or modest GPU (≤8GB VRAM)
- Single-user: desktop, laptop, edge device
- Privacy-sensitive: all inference local, no cloud
- Quick prototyping and experimentation

**Use vLLM when:**
- Deploying production LLM APIs (100+ req/sec)
- Multi-user applications (chatbots, assistants)
- Serving OpenAI-compatible endpoints to many consumers
- Batch inference on large datasets

**Use neither — use API instead when:**
- You don't have compatible hardware
- Throughput needs exceed local hardware
- Model too large for available VRAM even with quantization