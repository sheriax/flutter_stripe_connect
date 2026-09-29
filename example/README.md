# Flutter Stripe Connect example

This example uses a local Bun server to create Stripe Account Sessions for one
connected **test** account. The account ID and secret key stay on the server.

1. In `server/`, run `bun install` and set `STRIPE_SECRET_KEY` and
   `CONNECTED_ACCOUNT_ID` as described in [server/README.md](server/README.md).
2. Run `bun run start` from `server/`.
3. From this directory, run the Flutter app with your test publishable key:

   ```sh
   flutter run -d chrome --dart-define=STRIPE_PUBLISHABLE_KEY=pk_test_your_publishable_key
   ```

The app requests a fresh Account Session from
`http://localhost:3000/account-session` whenever Stripe needs one. For an Android
emulator, add `--dart-define=ACCOUNT_SESSION_URL=http://10.0.2.2:3000/account-session`.
For a physical device, use a reachable HTTPS server and set
`ACCOUNT_SESSION_URL` to its endpoint.

This server is for local testing only. A deployed backend must authenticate the
user, determine their connected account on the server, and enable only the
components and features allowed for their role.
