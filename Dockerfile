FROM ghcr.io/rails-lambda/live-development-builder:${TARGETARCH} as builder
COPY bin/build /usr/local/bin/build-live-development
RUN build-live-development

FROM scratch
LABEL org.opencontainers.image.source "https://github.com/rails-lambda/live-development"
LABEL org.opencontainers.image.description "Live Lambda Development | Tailscale Proxy"
COPY --from=builder /workspaces/live-development/opt /opt
