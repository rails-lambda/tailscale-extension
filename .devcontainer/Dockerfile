FROM public.ecr.aws/lambda/ruby:3.2
RUN yum update -y

# Install things to help install things.
RUN yum groupinstall -y 'Development Tools' && \
    yum install -y which binutils pkgconfig elfutils patchutils yum-utils

# Local devcontainer compatibility.
ENTRYPOINT []
RUN mkdir -p /workspaces/live-development
