
# Tailscale Lambda Extension for Containers

Inspired by Corey Quinn's [tailscale-layer](https://github.com/QuinnyPig/tailscale-layer) project. This project aims to do the same thing but usable for those working with any Lambda Container runtime language. Our extension has been modified from Corey's upstream work. I have removed verbose logging and event lifecycle hooks. This has reduced startup overhead, duplicate tailscale up calls, and more configuration options.

## Installation

We have pre-build container packages which include the Tailscale Lambda Extension within a basic Docker scratch image containing everything needed to copy to your `/opt` directory. For example:

```dockerfile
FROM public.ecr.aws/lambda/ruby:3.2
RUN yum install -y curl
COPY --from=ghcr.io/rails-lambda/tailscale-extension-amzn:1 /opt /opt
```

⚠️ Make sure `curl` is installed since the Tailscale Extension script will need it.

### Environment Variables

You will need to generate an [ephemeral key](https://login.tailscale.com/admin/settings/authkeys) within your Tailscale account. Note, this will expire and need updating depending on the time period you select. List of the environment variables include:

- `TS_KEY` - Required. Your ephemeral key.
- `TS_HOSTNAME` - Optional. The value of `--hostname` parameter. Default `lambda`.

### OSs & Architectures

We publish multi-platform images for both `linux/amd64` and `linux/arm64/v8` and we also have Amazon Linux 2 and Debian/Ubuntu variants.

- ghcr.io/rails-lambda/tailscale-extension-amzn
- ghcr.io/rails-lambda/tailscale-extension-debian

## Example Usage

Once your Lambda function starts, you will have a [SOCKS5](https://en.wikipedia.org/wiki/SOCKS) proxy which can communicate with your Tailscale tailnet at `http://localhost:1055`. Here is an example of how to leverage that with Ruby's [socksify](https://github.com/astro/socksify-ruby) gem.

```ruby
Net::HTTP.socks_proxy('localhost', 1055).start(...) do |http|
  # your http code here...
end
```

Again, this extension is not coupled to any runtime language. So how you use the SOCKS5 proxy is up to you. Enjoy!
