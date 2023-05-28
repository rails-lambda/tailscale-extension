
# Live Lambda Development | Tailscale Proxy


## Installation

TODO: Call out need for `curl` to be installed.

```dockerfile
FROM public.ecr.aws/lambda/provided
COPY --from=ghcr.io/rails-lambda/live-development /opt /opt
COPY bootstrap ${LAMBDA_RUNTIME_DIR}
COPY function.sh ${LAMBDA_TASK_ROOT}
CMD ["function.handler"]
```

[Lambda Provided](https://gallery.ecr.aws/lambda/provided)

Tutorial – Publishing a custom runtime
https://docs.aws.amazon.com/en_us/lambda/latest/dg/runtimes-walkthrough.html

## Usage


### Local Services

When running local development services, it is important that you use the `0.0.0.0` address to bind to all local interfaces vs the default of `127.0.0.1`. Doing so will ensure that [Tailscale Services](https://tailscale.com/kb/1100/services/) are updated and available. For Rails development server, use something like this:

```shell
rails s -b 0.0.0.0
```

### Using a Dev Container? 

[Dev Container](https://containers.dev/) is the amazing technology specification that great products like [Codespaces](https://github.com/features/codespaces) and [VS Code Remote Development](https://code.visualstudio.com/docs/remote/remote-overview) is built on. Since Tailscale automatically creates services on all local devices, you will need to ensure your Dev Container is forwarding the right ports. 

If your Dev Container is a single image (vs compose), then you can do this  in the `devcotainer.json` file:

```json
{
  "forwardPorts": [3000],
}
```

However, our Rails Lambda Dev Container leverages a `dockerComposeFile`, so you would also have to open that compose file and add this to your `devcontainer.json` matching `service` within the compose file. For example:

```yaml
services:
  app:
    ports:
      - 3000:3000
```

Here are a few helpful GitHub Issues I found on this topic.

- [Add support for devices in devcontainer-feature.json #153](https://github.com/devcontainers/spec/issues/153)
- [Port forwarding issue in Containers #1009](https://github.com/microsoft/vscode-remote-release/issues/1009)
- [Tailscale not detecting Docker Port Forwarding to Host #5813](https://github.com/tailscale/tailscale/issues/5813)

## Development

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/rails-lambda/live-development)
