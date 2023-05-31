FROM public.ecr.aws/lambda/provided as builder
RUN yum update -y && \
    yum install -y curl sudo yum-utils
RUN sudo yum-config-manager --add-repo https://pkgs.tailscale.com/stable/amazon-linux/2/tailscale.repo && \
    sudo yum install -y tailscale

RUN mkdir -p /opt/bin /opt/extensions
COPY ./src/tailscale.sh /opt/extensions/tailscale.sh
RUN sudo cp /usr/bin/tailscale /opt/bin/tailscale
RUN sudo cp /usr/sbin/tailscaled /opt/bin/tailscaled

FROM scratch
LABEL org.opencontainers.image.source "https://github.com/rails-lambda/tailscale-extension"
LABEL org.opencontainers.image.description "Tailscale Lambda Extension for Containers"
COPY --from=builder /opt /opt
