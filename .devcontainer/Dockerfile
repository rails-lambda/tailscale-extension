FROM public.ecr.aws/lambda/provided
RUN yum update -y
RUN yum groupinstall -y 'Development Tools' && \
    yum install -y which binutils pkgconfig elfutils patchutils yum-utils
ENTRYPOINT []
RUN mkdir -p /workspaces/live-development
WORKDIR /workspaces/live-development
