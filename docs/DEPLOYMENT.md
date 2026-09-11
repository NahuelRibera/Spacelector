# Deploying Spacelector

This describes one concrete way to run Spacelector publicly under your own domain. It hasn't
been deployed yet — this is what to do when you're ready, not a record of something already live.

## Why Render

The repository already ships a `render.yaml` and `bin/render-build.sh` from earlier work on this
project, so Render is the path of least resistance: it runs a normal Ruby web service (no need to
containerize anything), provisions a managed Postgres database, and gives you free managed TLS on
a custom domain. None of this requires Docker, even though a `Dockerfile` also exists in the repo
if you'd rather deploy to a container host instead (Fly.io, Railway, a VPS with `docker run`, etc.)
— the `Dockerfile` is a normal Rails 7.1 one and needs no changes to work with what's below.

This is a recommendation, not the only option. Any host that gives you a persistent Postgres
database, lets you set environment variables, and runs a normal Ruby process would work.

**On pricing:** verified against Render's docs on 2026-09-10 — Render's *free* Postgres plan
expires 30 days after creation and free web services spin down after 15 minutes of inactivity, so
neither is suitable for a demo you want reliably reachable. You'll want a paid "Starter"-tier web
service and database. Render doesn't publish exact dollar figures on the pages this was checked
against — check [render.com/pricing](https://render.com/pricing) for current numbers before you
commit to anything.

## 1. Storage: pick one

Production must not use local disk (`ACTIVE_STORAGE_SERVICE=local`) — Render's filesystem is
ephemeral, so every deploy or restart would silently delete every photo. The app already ships an
`amazon` Active Storage service (in `config/storage.yml`) that works with either of these two,
since it just talks the S3 API:

- **Cloudflare R2 (recommended).** S3-compatible, and as of 2026-09-10 its published pricing gives
  10 GB of storage and 1M/10M monthly Class A/B requests free, with **no egress fees** — the free
  tier has no time limit, unlike AWS's. Good fit for a demo that stays small.
- **A new AWS S3 bucket in your own account.** Also works out of the box. AWS's free tier is
  structured as a time-limited account credit rather than a fixed S3 allowance, so it's less
  predictable for a long-running side project — check
  [aws.amazon.com/s3/pricing](https://aws.amazon.com/s3/pricing) for the current terms.

Either way: **do not reuse the original project's bucket or AWS credentials.** Create your own
bucket under your own account.

### R2 setup
1. Cloudflare dashboard → R2 → Create bucket.
2. R2 → Manage API tokens → create a token scoped to that bucket (Object Read & Write).
3. Note the bucket name, the **Account ID** (used to build the S3 endpoint), and the access
   key ID / secret it gives you.
4. Your endpoint is `https://<account-id>.r2.cloudflarestorage.com`.

### AWS S3 setup
1. S3 console → Create bucket (pick any region).
2. IAM → create a user (or role) with a policy limited to `s3:GetObject`, `s3:PutObject`,
   `s3:DeleteObject` on that one bucket's ARN — not a broad `AmazonS3FullAccess` policy.
3. Generate an access key for that user.

## 2. Environment variables

Set these on the Render service (Dashboard → your service → Environment), or via `render.yaml`'s
`sync: false` entries which prompt for a value on first deploy without storing it in git:

| Variable | Required | Notes |
|---|---|---|
| `DATABASE_URL` | yes | Filled in automatically if you use `render.yaml`'s database binding |
| `SECRET_KEY_BASE` | yes | Generate with `bin/rails secret` locally, paste the output |
| `RAILS_ENV` | yes | `production` |
| `ACTIVE_STORAGE_SERVICE` | yes | `amazon` |
| `AWS_ACCESS_KEY_ID` | yes | From R2 or AWS, see above |
| `AWS_SECRET_ACCESS_KEY` | yes | From R2 or AWS |
| `AWS_REGION` | yes | Any AWS region string works for R2 (e.g. `auto`); a real region for AWS S3 |
| `S3_BUCKET_NAME` | yes | Your bucket's name |
| `S3_ENDPOINT` | only for R2 | `https://<account-id>.r2.cloudflarestorage.com` — leave unset for real AWS S3 |
| `GOOGLE_CLIENT_ID` / `GOOGLE_CLIENT_SECRET` | optional | Only if you want "Sign in with Google"; email/password sign-up works without it |
| `APP_HOST` | recommended | Your domain (e.g. `spacelector.example.com`), used to build links in emails |
| `SMTP_ADDRESS` / `SMTP_PORT` / `SMTP_USERNAME` / `SMTP_PASSWORD` | optional | Only needed for "forgot password" emails to actually send; without it, that flow no-ops instead of crashing |

None of these belong in git. `render.yaml` in this repo intentionally leaves them as `sync: false`
placeholders rather than real values.

### Google OAuth (optional)

If you want the Google sign-in button to work in production:
1. [Google Cloud Console](https://console.cloud.google.com/) → APIs & Services → Credentials →
   Create OAuth client ID (type: Web application).
2. Authorized redirect URI: `https://your-domain.example/users/auth/google_oauth2/callback`.
3. Put the client ID/secret it gives you into `GOOGLE_CLIENT_ID` / `GOOGLE_CLIENT_SECRET`.

## 3. Deploy

With a Render account connected to your fork:

1. Dashboard → New → Blueprint → point it at your repo. Render reads `render.yaml` and proposes
   the web service + database.
2. Fill in the `sync: false` environment variables it prompts for (see table above).
3. Deploy. `bin/render-build.sh` installs ImageMagick/libheif (for HEIC uploads) and precompiles
   assets; the service's start command runs `rails db:migrate` before booting the server, so
   migrations happen automatically on every deploy — no separate step needed.
4. Optionally load the bundled sample data once, from a Render Shell against the web service:
   `bin/rails db:seed` (safe to re-run; it refuses to do anything in `RAILS_ENV=production` unless
   you've decided you want the demo account there — see the README's note on sample data).

## 4. Custom domain + HTTPS

1. Buy the domain from any registrar.
2. Render Dashboard → your web service → Settings → Custom Domains → Add.
3. Render gives you a CNAME (or A/ALIAS for an apex domain) to add at your registrar/DNS provider.
4. Once DNS propagates, Render provisions and renews a free TLS certificate automatically — no
   separate certificate step.

## What's not covered here

- Backups: Render's paid Postgres plans include automated backups; confirm retention/frequency
  for the plan you pick before relying on it.
- Background jobs / Action Cable at scale: this app doesn't currently need a separate worker
  process or Redis, so none is configured.
- Monitoring/alerting: not set up. Render's dashboard gives basic logs and metrics out of the box.
