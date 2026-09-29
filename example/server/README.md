# Flutter Stripe Connect Example Server

This is a local Bun server for creating Stripe Account Sessions for one connected
test account. It listens on `127.0.0.1` and does not authenticate users.

## Setup

1. Install dependencies:
```bash
bun install
```

2. Set environment variables:
```bash
export STRIPE_SECRET_KEY=sk_test_your_secret_key
export CONNECTED_ACCOUNT_ID=acct_your_test_account_id
```

3. Run the server:
```bash
bun run start
```

The server will run at http://localhost:3000. See [the example app setup](../README.md)
for the Flutter command and `ACCOUNT_SESSION_URL` options.

Do not expose this server to the internet. For a deployed backend, authenticate
each user, resolve their account ID server side, and limit Account Session
components and features to their role.

## Endpoints

- `POST /account-session` - Creates a Stripe Account Session and returns the client secret
- `GET /health` - Health check
