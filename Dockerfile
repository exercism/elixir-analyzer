FROM hexpm/elixir:1.15.0-erlang-26.0.1-debian-buster-20230612 as builder

RUN apt-get update && \
  apt-get install bash -y

# Create appuser
RUN useradd -ms /bin/bash appuser

# Get the source code
WORKDIR /elixir-analyzer
COPY . .

# Builds an escript bin/elixir_analyzer
RUN ./bin/build.sh

FROM hexpm/elixir:1.15.0-erlang-26.0.1-debian-buster-20230612
COPY --from=builder /etc/passwd /etc/passwd

COPY --from=builder /elixir-analyzer/bin /opt/analyzer/bin
RUN apt-get update && \
  apt-get install bash jq -y

USER appuser
WORKDIR /opt/analyzer
ENTRYPOINT ["/opt/analyzer/bin/run.sh"]
