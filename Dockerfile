FROM scratch
LABEL org.opencontainers.image.source "https://github.com/rails-lambda/live-development"
LABEL org.opencontainers.image.description "Live Lambda Development | Tailscale Proxy"
COPY ./opt /opt
