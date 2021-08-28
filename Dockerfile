FROM bitwalker/alpine-elixir-phoenix:1.11.3
WORKDIR /code


# Set exposed ports
EXPOSE 5000
ARG databaseUrl=
ARG secretKeyBase=
ARG slackBotApiToken=
ARG slackClientId=
ARG slackClientSecret=
ARG host=

ENV PORT=5000
ENV MIX_ENV=prod
ENV DATABASE_URL=$databaseUrl
ENV SECRET_KEY_BASE=$secretKeyBase
ENV SLACK_BOT_API_TOKEN=$slackBotApiToken
ENV SLACK_CLIENT_ID=$slackClientId
ENV SLACK_CLIENT_SECRET=$slackClientSecret
ENV HOST=$host

# Cache elixir deps
ADD mix.exs mix.lock /tmp/
RUN cd /tmp && mix do deps.get, deps.compile

# Same with npm deps
ADD assets/package.json /code/assets/
RUN cp -r /tmp/deps /code && cp -r /tmp/_build /code && \
  cd /code/assets && npm install

RUN addgroup default && adduser default default

# Add the whole project
ADD --chown=default:default . .

# Copy dependencies lock
RUN cp /tmp/mix.exs /code && cp /tmp/mix.lock /code

# Run frontend build, compile, and digest assets
RUN cd /code/assets/ && npm run deploy && \
  cd /code && mix do compile, phx.digest

RUN mix release

RUN chown -R default:default /code

USER default

ENTRYPOINT [ "_build/prod/rel/hey_mate/bin/hey_mate" ]

CMD ["start"]