# Deploy Laravel Backend to Vercel

## Quick Deployment Steps

### 1. Install Vercel CLI (if needed)
```bash
npm i -g vercel
```

### 2. Login to Vercel
```bash
vercel login
```

### 3. Deploy from this directory
```bash
cd laravel-backend
vercel
```

Follow the prompts:
- Set up and deploy? **Y**
- Which scope? Select your account
- Link to existing project? **N**
- Project name? **task-connect-backend** (or your choice)
- In which directory is your code? **./**
- Want to override settings? **N**

### 4. Set Environment Variables

After deployment, go to your Vercel dashboard and add these environment variables:

#### Required Variables:
```
APP_NAME="Task Connect"
APP_KEY=base64:YOUR_APP_KEY_HERE
APP_DEBUG=false
APP_URL=https://your-project.vercel.app

DB_CONNECTION=mysql
DB_HOST=your_database_host
DB_PORT=3306
DB_DATABASE=your_database_name
DB_USERNAME=your_database_user
DB_PASSWORD=your_database_password

MAIL_MAILER=smtp
MAIL_HOST=your_mail_host
MAIL_PORT=587
MAIL_USERNAME=your_mail_username
MAIL_PASSWORD=your_mail_password
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS=noreply@taskconnect.com
MAIL_FROM_NAME="${APP_NAME}"

PAYPAL_MODE=sandbox
PAYPAL_SANDBOX_CLIENT_ID=your_paypal_client_id
PAYPAL_SANDBOX_SECRET=your_paypal_secret
PAYPAL_CURRENCY=USD
```

### 5. Deploy to Production
```bash
vercel --prod
```

## Important Notes

⚠️ **Vercel Limitations for Laravel:**
- Vercel is serverless - each request is isolated
- No persistent file storage (use S3 or similar for uploads)
- No background jobs/queues
- No WebSockets support
- Database connections need to be configured for serverless

### Recommended Alternative: Railway

For full Laravel features, consider using Railway instead:
1. Go to https://railway.app
2. Sign in with GitHub
3. Click "New Project" → "Deploy from GitHub repo"
4. Select your repository
5. Set root directory to `laravel-backend`
6. Add a MySQL database from Railway
7. Set environment variables

Railway provides:
✅ Persistent storage
✅ Background jobs
✅ WebSockets
✅ Better Laravel compatibility
✅ Easy database setup

## Using Vercel CLI Commands

```bash
# Deploy to preview
vercel

# Deploy to production
vercel --prod

# View logs
vercel logs

# List deployments
vercel ls

# Remove deployment
vercel rm [deployment-url]
```

## Troubleshooting

If you get APP_KEY error:
1. Generate key locally: `php artisan key:generate --show`
2. Add it to Vercel environment variables as `APP_KEY`

If database connection fails:
- Ensure your database accepts connections from Vercel IPs
- Use connection pooling
- Consider using PlanetScale or Railway database
