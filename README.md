# orgo-deploy

Your agent builds an app; you get a link. `orgo-deploy` serves any app running on an [Orgo](https://orgo.ai) computer at its own `https://<name>.orgo.dev` URL, and the `deploy-to-orgo` skill teaches a [Hermes](https://github.com/NousResearch/hermes-agent) agent to do it whenever it builds something.

```
$ orgo-deploy up ./habits
→ preparing /root/apps/habits
→ starting (static) on port 21001
Deployed habits
  Link:  https://habits.orgo.dev/?key=…
         (private: the key in the link is the password; anyone with the link can open it)
```

## Install

On the Orgo computer, as root. The `system/hermes-agent` template is a good home.

```bash
curl -fsSL https://raw.githubusercontent.com/nickvasilescu/orgo-deploy/main/install.sh | bash
orgo-deploy setup     # paste an Orgo API key (orgo.ai → Settings → API keys); stays on this computer
```

This puts `orgo-deploy` in `/usr/local/bin`, and the skill in `~/.hermes/skills/devops/deploy-to-orgo/` when Hermes is installed. `setup` also works out which Orgo computer it's on.

Then ask your agent to build something and give you a link.

## What `up` does

1. **Detects how to run the app:**
   - Node: `npm install`, `npm run build`, `npm start`.
   - Python: a venv plus `requirements.txt`, then Streamlit, FastAPI/uvicorn, or `app.py`.
   - Static sites: `index.html` in the root, `dist/`, `build/`, `out/` or `public/`.
   - Anything else: `--cmd "..."`.
2. **Runs it under supervisord** on a free port, passed in as `$PORT`. It restarts on crash and comes back after a reboot.
3. **Attaches an orgo.dev URL** through Orgo's public-URL API:
   - If the name is taken (names are shared across all Orgo accounts), it adds a suffix: `crm` → `crm-7f3a`.
   - At the account's 10-URL limit, it recycles the oldest app it deployed on this computer and says so. It never touches URLs it didn't create.
4. **Puts a key gate in front (default).** Opening the link sets a 30-day cookie, and everyone else gets a login page.
   - The gate checks every request, including WebSocket upgrades. That matters because Orgo's edge reuses connections across visitors.
   - `--public` turns the gate off.
5. **Checks the URL answers through Orgo's edge** before printing the link.

Redeploying with the same name keeps the URL and the key.

## Commands

| Command | Does |
|---|---|
| `orgo-deploy up <dir> [--name N] [--cmd "…"] [--port P] [--public\|--private] [--json]` | Deploy or redeploy |
| `orgo-deploy list [--json]` | Apps, status and links |
| `orgo-deploy logs <name> [-n 100]` | App output |
| `orgo-deploy restart <name>` | Restart the app and its gate |
| `orgo-deploy rm <name>` | Stop the app and free its URL |
| `orgo-deploy setup` / `whoami` | Save the API key, or show the computer and URL usage |

## Limits, plainly

- **Apps live only while the computer runs.** This is for using what your agent builds, not production hosting.
- **10 free orgo.dev names per Orgo account.**
- **The API key on the computer can manage that workspace's computers.**
  - Use a workspace-scoped key: `orgo api-keys create --workspace <id>`.
  - Delete it when you're done.
- **The app must listen on `$PORT`.** Or tell orgo-deploy its fixed port with `--port`. Don't use port 8080, which Orgo reserves.
- **Orgo doesn't tell a computer its own ID**, so `setup` finds itself by writing a one-time nonce and reading it back through the API. Set `ORGO_COMPUTER_ID` in `/etc/orgo-deploy/env` to skip that.

Files:

- Settings: `/etc/orgo-deploy/env` (mode 600).
- State: `/var/lib/orgo-deploy/apps.json`.
- Logs: `/var/log/orgo-deploy/`.

## License

MIT
