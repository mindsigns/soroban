FROM elixir:onbuild
RUN apt-get update && \
    apt-get install -y libssl1.0.0 postgresql-client locales inotify-tools && \
    apt-get autoclean

RUN curl -sL https://deb.nodesource.com/setup_6.x | bash - && \
apt-get install -y nodejs

ADD . /app
RUN mix local.hex --force
WORKDIR /app

ENV MIX_ENV prod
RUN mix deps.get, compile

RUN npm install

EXPOSE 4000
#CMD ["/bin/bash"]
CMD ["mix", "ecto.migrate,", "phoenix.server"]
