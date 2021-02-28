FROM hexpm/elixir:1.11.3-erlang-23.2.6-ubuntu-focal-20210119 as builder

RUN apt-get update && \
  apt-get install bash -y

# Create appuser
RUN useradd -ms /bin/bash appuser

# Get the source code
WORKDIR /elixir-analyzer
COPY . .

# Builds an escript bin/elixir_analyzer
RUN ./bin/build.sh

FROM hexpm/elixir:1.11.3-erlang-23.2.6-ubuntu-focal-20210119
COPY --from=builder /etc/passwd /etc/passwd

COPY --from=builder /elixir-analyzer/bin /opt/analyzer/bin
RUN apt-get update && \
  apt-get install bash -y

USER appuser
WORKDIR /opt/analyzer
ENTRYPOINT ["/opt/analyzer/bin/run.sh"]
