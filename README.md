# docker-cmdcode2api

Docker container for [cmdcode2api](https://github.com/synthetic-coworkers/cmdcode2api) — an OpenAI-compatible gateway for [Command Code](https://commandcode.ai/).

## Prerequisites

- Docker (or Docker Compose)
- A **Command Code API key** — see [Getting your API key](#getting-your-api-key) below.

## Getting your API key

You cannot obtain the API key inside the container. Get it from the web dashboard:

1. Go to [https://commandcode.ai/studio/](https://commandcode.ai/studio/)
2. Sign in to your account
3. Navigate to **API Keys**
4. Click **Generate API Key**
5. Copy the generated key (starts with `sk-`)

## Quick start

```bash
docker run -d --name cmdcode2api \
  -p 11434:11434 \
  -e CC_API_KEY="sk-xxxx..." \
  -v cmdcode2api-data:/data \
  ghcr.io/masterisk-f/cmdcode2api
```

Or with Docker Compose:

```bash
# Create a .env file
echo "CC_API_KEY=sk-xxxx..." > .env

# Start
docker compose up -d
```

On first start, a random **local API key** is generated and printed to the log. Use
this as the Bearer token when calling the gateway:

```bash
docker logs cmdcode2api
```

## Usage

Once running, the gateway is available at `http://<host>:11434/v1`.

### List models

```bash
curl http://localhost:11434/v1/models \
  -H "Authorization: Bearer <local-api-key>"
```

### Chat completion

```bash
curl http://localhost:11434/v1/chat/completions \
  -H "Authorization: Bearer <local-api-key>" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "deepseek/deepseek-v4-pro",
    "messages": [
      {"role": "user", "content": "Hello!"}
    ],
    "stream": false
  }'
```

### Streaming

```bash
curl http://localhost:11434/v1/chat/completions \
  -H "Authorization: Bearer <local-api-key>" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "deepseek/deepseek-v4-pro",
    "messages": [
      {"role": "user", "content": "Write a short haiku."}
    ],
    "stream": true
  }'
```

### Health check

```bash
curl http://localhost:11434/health
```

## Environment variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `CC_API_KEY` | **Yes** | — | Your Command Code API key (from [studio](https://commandcode.ai/studio/)) |
| `API_KEY` | No | auto-generated | Local API key used as Bearer token by clients |
| `CC_BASE_URL` | No | `https://api.commandcode.ai` | Command Code API base URL |
| `HOST` | No | `0.0.0.0` | HTTP listen address |
| `PORT` | No | `11434` | HTTP listen port |
| `EXCLUDE_MODELS` | No | `gpt-,claude-,gemini-` | Comma-separated model ID prefixes to exclude |

## Volumes

| Path | Purpose |
|------|---------|
| `/data` | Runtime data directory (`config.yaml`, `usage.json`) |

Mount a named volume or bind mount to persist data across restarts:

```bash
docker run ... -v cmdcode2api-data:/data ...
```

## Model exclusion

By default models prefixed with `gpt-`, `claude-`, and `gemini-` are hidden
and rejected. To make all models available:

```bash
docker run ... -e EXCLUDE_MODELS="" ...
```

## Build locally

```bash
docker build -t cmdcode2api .
```

## License

MIT

---

*This is a community Docker packaging. cmdcode2api is the original work of
[synthetic-coworkers](https://github.com/synthetic-coworkers/cmdcode2api).*
