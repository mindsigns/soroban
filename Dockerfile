FROM elixir
RUN apt-get update && \
    apt-get install -y libssl1.0.0 postgresql-client locales inotify-tools && \
    apt-get autoclean

RUN curl -sL https://deb.nodesource.com/setup_6.x | bash - && \
apt-get install -y nodejs

ADD . /app
RUN mix local.hex --force
RUN mix local.rebar --force
WORKDIR /app

ENV MIX_ENV prod
RUN mix do deps.get, compile

RUN npm install

EXPOSE 4000
#CMD ["mix", "phoenix.server"]
#CMD ["/bin/bash"]
CMD ["mix", "do", "ecto.migrate", "phoenix.server"]
