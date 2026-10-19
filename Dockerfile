FROM --platform=$BUILDPLATFORM golang:1.24-alpine AS builder

ARG TARGETOS
ARG TARGETARCH
ARG VERSION=dev
ARG REPO_URL=https://github.com/TTT-ux-max/opencode2api.git
ARG REPO_REF=main

RUN apk add --no-cache git

WORKDIR /src

# 自动从 GitHub 拉取源码
RUN git clone --depth 1 --branch "${REPO_REF}" "${REPO_URL}" .

RUN go mod download

RUN CGO_ENABLED=0 \
    GOOS="${TARGETOS:-linux}" \
    GOARCH="${TARGETARCH:-amd64}" \
    go build \
      -trimpath \
      -ldflags="-s -w -X main.version=${VERSION}" \
      -o /out/opencode2api ./cmd/opencode2api

FROM alpine:3.22

RUN apk add --no-cache ca-certificates su-exec tzdata \
    && addgroup -S opencode2api \
    && adduser -S -G opencode2api -h /var/lib/opencode2api opencode2api \
    && mkdir -p /app /var/lib/opencode2api \
    && chown -R opencode2api:opencode2api /app /var/lib/opencode2api

COPY --from=builder /out/opencode2api /usr/local/bin/opencode2api
COPY --from=builder --chmod=0755 /src/docker-entrypoint.sh /usr/local/bin/docker-entrypoint
COPY --from=builder --chown=opencode2api:opencode2api /src/config.example.json /app/config.example.json
COPY --from=builder /src/LICENSE /usr/share/licenses/opencode2api/LICENSE
LABEL org.opencontainers.image.licenses="GPL-3.0-or-later"

ENV CONFIG_PATH=/var/lib/opencode2api/config.json \
    CONFIG_SEED_PATH= \
    LISTEN_ADDRESS= \
    WEBUI_LISTEN_ADDRESS= \
    STATE_DIR=/var/lib/opencode2api

WORKDIR /app

EXPOSE 8080 8081

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD wget -q -O /dev/null http://127.0.0.1:8080/healthz || exit 1

ENTRYPOINT ["/usr/local/bin/docker-entrypoint"]
