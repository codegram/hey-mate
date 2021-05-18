# HeyMate 🧉

## Installation

#### Slack bot

In order to receive the Slack events, the bot need to be subscribed to the following bot events:

- `message.channels`
- `reaction_added`
- `reaction_removed`
- `app_home_opened`

## Development environment

### Setup dev server

In order to start get your dev server ready, follow the following steps:

- Install dependencies with `mix deps.get`
- Create `dev.exs` file using `dev.exs.example` as a template
- Create and migrate your database with `mix ecto.setup`
- Install Node.js dependencies with `npm install` inside the `assets` directory

Finally, start the dev server with `mix phx.server`

### Connect with a dev Slack bot

In order to try out your changes in Slack, we'll do the following:

- Expose your localhost dev server on your public IP with `ngrok`
- Create/set up a Slack test bot to send traffic to your localhost dev server.

#### Expose the dev server

If you haven't yet, download and install [ngrok](https://ngrok.com/)

In your teminal, run `ngrok http 4000` to expose your `localhost:4000` on a public address.
Now you can reach your local HeyMate at the returned `http://<something>.ngrok.io` address.

#### Create (or reuse) a test HeyMate Slack app

Browse the [Slack apps directory](https://api.slack.com/apps) and check if you can reuse someone else's dev HeyMate.
If that's the case, you can simply change the events URL in order to receive Slack events directly to your ngrok address.
You can do that from the app's 'Event subscription' page (e.g. https://api.slack.com/apps/A01A0E8M72A/event-subscriptions)

In alternative, you can create a new app. Mind that you'll need to make sure you're assigning the right permissions to the app.

#### Add the app's authentication token to your local server

Now you need to add the Slack app's authentication token to your local server in order to be able to send messages to the slack users.
Get the oauth token from the app installation page (e.g. https://api.slack.com/apps/A01A0E8M72A/install-on-team) and put it in your `dev.exs` file as follows:

```
config :hey_mate,
  slack_api_key: "valid-token"
```

Restart the dev server and you're all set up to send 🧉s from your local server! :tada:
