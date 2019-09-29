FROM elixir:1.8-alpine as builder

# Install SSL ca certificates
RUN apk update && apk add ca-certificates

# Create appuser
RUN adduser -D -g '' appuser

# Get the source code
WORKDIR /elixir-analyzer
COPY . .

# Builds an escript bin/elixir_analyzer
RUN bin/build.sh

FROM elixir:1-8-alpine
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /elixir-analyzer/bin /opt/analyzer/bin
USER appuser
WORKDIR /opt/analyzer
ENTRYPOINT ["/opt/analyzer/bin/analyze.sh"]
