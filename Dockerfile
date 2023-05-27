FROM public.ecr.aws/lambda/provided as builder
RUN yum update -y
RUN yum groupinstall -y 'Development Tools' && \
    yum install -y which binutils pkgconfig elfutils patchutils yum-utils
ENTRYPOINT []
RUN mkdir -p /workspaces/live-development
WORKDIR /workspaces/live-development

COPY . .
RUN ./bin/build

FROM scratch
LABEL org.opencontainers.image.source "https://github.com/rails-lambda/live-development"
LABEL org.opencontainers.image.description "Live Lambda Development | Tailscale Proxy"
COPY --from=builder /workspaces/live-development/opt /opt
