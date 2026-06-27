# =============================================================================
# docker-cmdcode2api — Multi-stage Docker build for cmdcode2api
# =============================================================================
# Stage 1: Build cmdcode2api from source
FROM golang:alpine AS builder

RUN apk add --no-cache git ca-certificates

ARG CMDCODE2API_REPO=https://github.com/synthetic-coworkers/cmdcode2api
ARG CMDCODE2API_REF=master

WORKDIR /src
RUN git clone --depth 1 --branch ${CMDCODE2API_REF} ${CMDCODE2API_REPO} . \
 && go mod download \
 && CGO_ENABLED=0 go build -ldflags="-s -w" -o /cmdcode2api ./cmd/cmdcode2api

# Stage 2: Minimal runtime
FROM alpine:3.21

RUN apk add --no-cache ca-certificates

COPY --from=builder /cmdcode2api /cmdcode2api
COPY entrypoint.sh /entrypoint.sh

WORKDIR /data
VOLUME /data
EXPOSE 11434

ENTRYPOINT ["/entrypoint.sh"]
CMD ["server"]
