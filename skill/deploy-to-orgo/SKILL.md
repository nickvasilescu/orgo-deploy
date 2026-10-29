---
name: deploy-to-orgo
description: Put apps you build at a live https link on orgo.dev.
version: 0.1.0
author: Nick Vasilescu (nickvasilescu), Hermes Agent
license: MIT
platforms: [linux]
metadata:
  hermes:
    tags: [deploy, hosting, web-app, orgo, public-url]
    related_skills: []
---

# Deploy to Orgo

You run on an Orgo cloud computer. `orgo-deploy` turns any app directory on this computer into a live
`https://<name>.orgo.dev` link: it installs and builds the app, runs it under supervisord (restarts on
crash, survives reboots), attaches a public URL, and checks the URL answers. By default the app is
private: the link carries a key, and anyone without it sees a login page.

## When to Use

- You built or changed anything with a UI or an HTTP API: a web app, dashboard, landing page, tool, API.
- The user asks to "deploy", "host", "put it online", "give me a link", or "let me try it".
- You fixed a deployed app: redeploy it so the link serves the new code.
- Don't use for: one-off scripts or CLIs with no HTTP server, or apps that must stay up when this
  computer is off (these links live only while this computer runs).

## Prerequisites

- `orgo-deploy` on PATH and an Orgo API key saved on this computer. Check with
  `terminal(command="orgo-deploy whoami")`. If it says there is no key, ask the user to run
  `orgo-deploy setup` in a terminal. Never ask them to paste the key into chat.

## Procedure

1. **Make it run on `$PORT`.** The app must listen on the port in the `PORT` environment variable,
   on `127.0.0.1` or `0.0.0.0`. Done when the start command reads `PORT` (for example
   `app.listen(process.env.PORT)`, `uvicorn ... --port $PORT`). Never use port 8080; Orgo reserves it.
2. **Deploy.** `terminal(command="orgo-deploy up <app-dir> --name <short-name> --json", timeout=600)`.
   It detects `npm start` (after `npm install` and `npm run build` if those exist), Python
   (`requirements.txt` with `app.py`/`main.py`; Streamlit and FastAPI are handled), and static sites
   (`index.html` in the root, `dist/`, `build/`, `out/` or `public/`). For anything else add
   `--cmd "<start command>"`. Done when it prints JSON with a `link`.
3. **Check it yourself.** Open the `link` with your browser tool, or `curl` it, and confirm the real
   page renders, not an error. Done when you've seen the app's own content.
4. **Hand over the link.** Give the user the full `link` value (including `?key=...`), one line on
   what it is, and that it's private unless deployed with `--public`.

Redeploying uses the same command and the same `--name`. The URL and key stay the same.

## Quick Reference

```
orgo-deploy up <dir> [--name N] [--cmd "..."] [--port P] [--public] [--json]
orgo-deploy list            # every app, status and link
orgo-deploy logs <name>     # app output (first stop when something's wrong)
orgo-deploy restart <name>
orgo-deploy rm <name>       # stop the app and free its URL
```

## Pitfalls

- **"didn't start listening on port N":** the app ignores `$PORT` or crashed. Read
  `orgo-deploy logs <name>`, fix the cause, redeploy. If the app insists on a fixed port, pass
  `--port <that port>`.
- **Dev servers:** deploy production builds (`npm run build` + `npm start`), not `vite`/`next dev`.
- **Name taken:** orgo.dev names are shared across all Orgo accounts; `orgo-deploy` adds a suffix
  (`crm` becomes `crm-7f3a`) and prints the real link. Always report the printed link.
- **10 URLs per account:** at the limit, `orgo-deploy` frees the oldest app it deployed on this computer
  and says so in its output. Tell the user which app was retired. `orgo-deploy rm` frees one on purpose.
- **`--public`** removes the key gate, so anyone with the URL can use the app. Only use it when the user
  asks, and never for an app that holds their data or credentials.
- The first request after a deploy can take a few seconds while the certificate is issued.

## Verification

`orgo-deploy up` exits non-zero unless the public URL answered through Orgo's edge. Then step 3: you
loaded the link and saw the app's real content.
