import Stripe from 'stripe';

const secretKey = process.env.STRIPE_SECRET_KEY;
const connectedAccountId = process.env.CONNECTED_ACCOUNT_ID;

if (!secretKey?.startsWith('sk_test_') || !connectedAccountId) {
  throw new Error(
    'Set STRIPE_SECRET_KEY to a test secret key and CONNECTED_ACCOUNT_ID before starting the example server.',
  );
}

const stripe = new Stripe(secretKey);

const server = Bun.serve({
  hostname: '127.0.0.1',
  port: process.env.PORT || 3000,
  async fetch(request) {
    const url = new URL(request.url);

    // Handle CORS preflight
    if (request.method === 'OPTIONS') {
      return new Response(null, {
        headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type',
        },
      });
    }

    // Health check
    if (url.pathname === '/health') {
      return new Response(JSON.stringify({ status: 'ok' }), {
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
      });
    }

    // Create account session
    if (url.pathname === '/account-session' && request.method === 'POST') {
      try {
        const accountSession = await stripe.accountSessions.create({
          account: connectedAccountId,
          components: {
            account_onboarding: { enabled: true },
            account_management: { enabled: true },
            payments: {
              enabled: true,
              features: {
                refund_management: true,
                dispute_management: true,
                capture_payments: true,
              },
            },
            payouts: {
              enabled: true,
              features: {
                instant_payouts: true,
                standard_payouts: true,
              },
            },
            balances: {
              enabled: true,
              features: {
                instant_payouts: true,
                standard_payouts: true,
              },
            },
            notification_banner: { enabled: true },
            documents: { enabled: true },
            tax_settings: { enabled: true },
            tax_registrations: { enabled: true },
            payouts_list: { enabled: true },
            // financial_account: { enabled: true },
            disputes_list: { enabled: true },
          },
        });

        console.log('Created account session for:', connectedAccountId);

        return new Response(JSON.stringify({
          client_secret: accountSession.client_secret,
        }), {
          headers: {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
          },
        });
      } catch (error) {
        console.error('Error creating account session:', error);
        const errorMessage = error instanceof Error ? error.message : 'Unknown error';
        return new Response(JSON.stringify({
          error: errorMessage,
        }), {
          status: 500,
          headers: {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
          },
        });
      }
    }

    return new Response('Not found', { status: 404 });
  },
});

console.log(`🚀 Server running at http://localhost:${server.port}`);
console.log(`\nEndpoints:`);
console.log(`  POST /account-session - Create account session`);
console.log(`  GET  /health         - Health check`);
