FROM elixir:1.10-alpine as builder

# Install SSL ca certificates
RUN apk update && \
  apk add ca-certificates && \
  apk add curl && \
  apk add bash

# Create appuser
RUN adduser -D -g '' appuser

# Get exercism's tooling_webserver
RUN curl -L -o /usr/local/bin/tooling_webserver \
  https://github.com/exercism/tooling-webserver/releases/download/latest/tooling_webserver && \
  chmod +x /usr/local/bin/tooling_webserver

# Get the source code
WORKDIR /elixir-analyzer
COPY . .

# Builds an escript bin/elixir_analyzer
RUN ./bin/build.sh

FROM elixir:1.10-alpine
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /usr/local/bin/tooling_webserver /usr/local/bin/tooling_webserver
COPY --from=builder /elixir-analyzer/bin /opt/analyzer/bin
RUN apk update && \
  apk add bash
USER appuser
WORKDIR /opt/analyzer
ENTRYPOINT ["/opt/analyzer/bin/run.sh"]
