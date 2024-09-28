FROM docker.io/golang:1.22.5-bookworm AS base
WORKDIR /app
RUN --mount=type=cache,target=/go/pkg/mod/,sharing=locked \
    --mount=type=bind,source=./ollama-copilot/go.sum,target=go.sum \
    --mount=type=bind,source=./ollama-copilot/go.mod,target=go.mod \
    go mod download -x

FROM base AS builder
RUN --mount=type=cache,target=/go/pkg/mod/ \
    --mount=type=bind,source=./ollama-copilot,target=. \
    CGO_ENABLED=0 go build -ldflags="-s -w" -trimpath -o /ollama-copilot

FROM gcr.io/distroless/base
WORKDIR /app
COPY --from=builder /ollama-copilot /app/ollama-copilot

EXPOSE 11435 11437

ENTRYPOINT [ "/app/ollama-copilot" ]