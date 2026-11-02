# Setup

Deploy once per account, then export two variables on each machine that uploads.

## Deploy

`wrangler` is needed here only, not on the machines that upload.

Export `CLOUDFLARE_ACCOUNT_ID` first when the login has more than one account. Wrangler otherwise prompts for a choice, and falls back to declining in a non-interactive shell.

1. Create the R2 bucket: `npx wrangler r2 bucket create uploads`
2. Expire the scratch prefix: `npx wrangler r2 bucket lifecycle add uploads temp-uploads "tmp/" --expire-days 7`
   Leave the bucket's public access disabled; the Worker is its only reader.
3. Deploy and set the token:

```bash
cd worker
npx wrangler deploy
TOKEN=$(head -c 32 /dev/urandom | base64)
echo "$TOKEN"
printf %s "$TOKEN" | npx wrangler secret put UPLOAD_TOKEN
```

Keep the echoed token; `wrangler secret` will not show it again.

`deploy` prints the `workers.dev` URL to use as `UPLOAD_ENDPOINT`. For a shorter one, add a custom domain under **Workers -> file-upload -> Settings -> Domains & Routes**. Attaching it there rather than as a route in `wrangler.jsonc` keeps the hostname out of this repo.

## Machine

`~/.zshenv`, not `~/.zshrc`:

```bash
export UPLOAD_ENDPOINT=https://file-upload.<your-subdomain>.workers.dev
export UPLOAD_TOKEN=<token>
```

`~/.zshrc` is sourced only for interactive shells, so vars put there are invisible to `zsh -c`, `ssh host cmd`, cron, and agent harnesses that shell out non-interactively. `~/.zshenv` is read by every zsh.

Rotating `UPLOAD_TOKEN` and redeploying revokes every machine at once, which is the point of routing through the Worker rather than handing out R2 credentials.

## Verify

```bash
echo hello > /tmp/setup-check.txt
URL=$(curl -fsS -T /tmp/setup-check.txt \
  -H "Authorization: Bearer $UPLOAD_TOKEN" \
  -H "Content-Type: text/plain" \
  "$UPLOAD_ENDPOINT/upload?prefix=tmp&name=setup-check.txt")
curl -fsS "$URL"
```

Printing `hello` means the token, the Worker, the bucket binding, and the custom domain all line up.
