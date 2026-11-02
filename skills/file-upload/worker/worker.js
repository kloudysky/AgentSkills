// Upload endpoint in front of a private R2 bucket.
//   PUT  /upload?prefix=pr&name=shot.png   (bearer auth)  -> stores the body, returns the public URL
//   GET  /<key>                            (public)       -> serves the object
const PREFIXES = new Set(["pr", "tmp"]);

const sanitize = (name) => name.replace(/[^a-zA-Z0-9._-]+/g, "-").slice(0, 100);

export default {
  async fetch(request, env) {
    const url = new URL(request.url);

    if (request.method === "PUT" && url.pathname === "/upload") {
      if (request.headers.get("authorization") !== `Bearer ${env.UPLOAD_TOKEN}`) {
        return new Response("unauthorized\n", { status: 401 });
      }

      const prefix = url.searchParams.get("prefix") ?? "pr";
      if (!PREFIXES.has(prefix)) {
        return new Response(`prefix must be one of: ${[...PREFIXES].join(", ")}\n`, { status: 400 });
      }

      const key = [
        prefix,
        crypto.randomUUID().slice(0, 8),
        sanitize(url.searchParams.get("name") ?? "file"),
      ].join("/");

      await env.BUCKET.put(key, request.body, {
        httpMetadata: {
          contentType: request.headers.get("content-type") ?? "application/octet-stream",
        },
      });

      return new Response(`${url.origin}/${key}\n`, {
        status: 201,
        headers: { "content-type": "text/plain" },
      });
    }

    if (request.method === "GET" || request.method === "HEAD") {
      const key = decodeURIComponent(url.pathname.slice(1));
      const object = request.method === "HEAD" ? await env.BUCKET.head(key) : await env.BUCKET.get(key);
      if (!object) return new Response("not found\n", { status: 404 });

      const headers = new Headers();
      object.writeHttpMetadata(headers);
      headers.set("etag", object.httpEtag);
      // Keys are random, so an object never changes. Cap tmp/ at a day so the
      // edge stops serving it soon after the lifecycle rule deletes it.
      headers.set("cache-control", key.startsWith("tmp/") ? "public, max-age=86400" : "public, max-age=31536000, immutable");

      return new Response(request.method === "HEAD" ? null : object.body, { headers });
    }

    return new Response("method not allowed\n", { status: 405 });
  },
};
