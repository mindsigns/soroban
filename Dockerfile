FROM elixir:1.4.2
ENV MIX_ENV=prod
RUN apt-get update && \
    apt-get install -y libssl1.0.0 postgresql-client locales && \
    apt-get autoclean
RUN mkdir -p /app
ARG VERSION=0.0.1
WORKDIR /app

RUN mix local.hex --force
RUN mix local.rebar --force

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV PORT 4000
#CMD ["mix", "phoenix.server"]
#CMD ["mix", "do", "ecto.migrate", "phoenix.server"]
#CMD ["/bin/bash"]
