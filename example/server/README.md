# Flutter Stripe Connect Example Server

This is a simple Bun server for creating Stripe Account Sessions.

## Setup

1. Install dependencies:
```bash
bun install
```

2. Set environment variables:
```bash
export STRIPE_SECRET_KEY=sk_test_your_secret_key
export CONNECTED_ACCOUNT_ID=acct_your_connected_account_id
```

3. Run the server:
```bash
bun run start
```

The server will run at http://localhost:3000

## Endpoints

- `POST /account-session` - Creates a Stripe Account Session and returns the client secret
- `GET /health` - Health check
