import { Router } from 'express';
import Stripe from 'stripe';

export function setupPaymentRoutes() {
  const router = Router();
  
  // Initialize Stripe with secret key from env
  const stripe = new Stripe(process.env.STRIPE_SECRET_KEY || '', {
    apiVersion: '2023-08-16' as any,
  });

  // Checkout page
  router.get('/checkout', (req, res) => {
    res.send(`
      <html>
        <head>
          <title>ProxyClaude - API Access</title>
          <script src="https://js.stripe.com/v3/"></script>
          <style>
            body { font-family: system-ui; max-width: 800px; margin: 0 auto; padding: 20px; }
            .btn { background: #5469d4; color: white; padding: 12px 20px; border: none; 
                   border-radius: 4px; cursor: pointer; }
          </style>
        </head>
        <body>
          <h1>ProxyClaude API Access</h1>
          <p>Get access to the ProxyClaude API for 30€</p>
          <form id="payment-form">
            <input type="email" id="email" placeholder="Your email" required />
            <button class="btn" id="checkout-button">Purchase API Access</button>
          </form>
          <script>
            document.getElementById('payment-form').addEventListener('submit', async (e) => {
              e.preventDefault();
              const email = document.getElementById('email').value;
              
              // Create checkout session
              const response = await fetch('/payment/create-checkout-session', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ email })
              });
              
              const { url } = await response.json();
              window.location = url;
            });
          </script>
        </body>
      </html>
    `);
  });

  // Create Stripe checkout session
  router.post('/create-checkout-session', async (req, res) => {
    const { email } = req.body;
    
    try {
      const session = await stripe.checkout.sessions.create({
        customer_email: email,
        line_items: [
          {
            price_data: {
              currency: 'eur',
              product_data: {
                name: 'ProxyClaude API Access',
                description: 'Full access to the ProxyClaude API'
              },
              unit_amount: 3000, // 30€ in cents
            },
            quantity: 1,
          },
        ],
        mode: 'payment',
        success_url: `${req.protocol}://${req.get('host')}/payment/success?session_id={CHECKOUT_SESSION_ID}`,
        cancel_url: `${req.protocol}://${req.get('host')}/payment/cancel`,
      });

      res.json({ url: session.url });
    } catch (error) {
      console.error('Stripe error:', error);
      res.status(500).json({ error: 'Failed to create checkout session' });
    }
  });

  // Stripe webhook
  router.post('/webhook', async (req, res) => {
    const sig = req.headers['stripe-signature'] as string;
    const endpointSecret = process.env.STRIPE_WEBHOOK_SECRET || '';
    
    try {
      const event = stripe.webhooks.constructEvent(req.body, sig, endpointSecret);
      
      if (event.type === 'checkout.session.completed') {
        const session = event.data.object as Stripe.Checkout.Session;
        
        // Generate API key for the customer
        const email = session.customer_email;
        // TODO: Generate and store API key, then send email
        console.log(`Payment received from ${email}, generate API key`);
      }
      
      res.json({ received: true });
    } catch (error) {
      console.error('Webhook error:', error);
      res.status(400).send(`Webhook Error: ${error.message}`);
    }
  });

  return router;
}