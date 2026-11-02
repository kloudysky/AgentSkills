---
name: file-upload
description: Upload a file and return a shareable URL. Use when embedding a screenshot or video in a PR or issue comment, handing an artifact to another machine, or sharing a file with the user.
---

# File Upload

`$UPLOAD_ENDPOINT` is a Cloudflare Worker in front of a private R2 bucket. It takes a file body on `PUT /upload` and returns the URL that serves it.

Keys carry a random segment, and reads are unauthenticated. Treat every upload as readable by anyone holding the link, and keep secrets, credentials, and customer data out of them.

When `$UPLOAD_ENDPOINT` or `$UPLOAD_TOKEN` is unset, work through [`SETUP.md`](SETUP.md) before uploading.

## Prefix

The prefix sets the file's lifetime. Pick it from where the URL lands:

- `pr` never expires. Use it for URLs that outlive the session: PR comments, issue comments, docs.
- `tmp` is deleted 7 days after upload by a bucket lifecycle rule. Use it for handoffs to another machine and one-off links to the user.

The failure this split prevents is a dead image in a six-month-old PR thread, so when the destination is unclear, use `pr`.

## Upload

```bash
FILE=<path>; PREFIX=pr   # or tmp
URL=$(curl -fsS -T "$FILE" \
  -H "Authorization: Bearer $UPLOAD_TOKEN" \
  -H "Content-Type: $(file -b --mime-type "$FILE")" \
  "$UPLOAD_ENDPOINT/upload?prefix=$PREFIX&name=$(basename "$FILE")")
echo "$URL"
```

The `Content-Type` header decides whether a browser renders the file or downloads it, and it is the only thing the Worker cannot infer, so send it on every upload.

`curl -fsS` exits nonzero when the write fails. Confirm the read path too with `curl -sI "$URL" | head -1` before handing the URL to anyone.

Worker request bodies cap at 100MB. Larger files need a different transport.

## Sharing

Images embed inline in GitHub markdown:

```md
![what it shows](https://...)
```

GitHub plays video inline only for media it hosts itself, so post an uploaded video as a plain link alongside a sentence describing what it shows. Upload an animated GIF when a short clip has to render inline.

For another machine or agent, hand over the URL. The receiver fetches it with `curl -fsSL <url> -o <path>`, no token needed.
