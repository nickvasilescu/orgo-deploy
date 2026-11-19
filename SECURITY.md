# Security

## Reporting a vulnerability

Please report security problems privately. Use the **Report a vulnerability** button on this repo's
[Security tab](https://github.com/nickvasilescu/orgo-deploy/security/advisories/new).

Please don't post vulnerabilities in YouTube comments, social media, or public issues. A public post gives
attackers a head start before a fix exists.

Include what you found, how to reproduce it, and what an attacker could do with it. Only the `main` branch is
supported. Responses are best effort; this is a personal open-source project.

## Using it safely

- Give the computer the narrowest Orgo key you can: a workspace-scoped key for a workspace that holds only
  the computers you deploy from (`orgo api-keys create --workspace <id>`). Never put your main account key
  on a computer an agent controls. Anyone who gets shell on that computer can read the key.
- Run `orgo-deploy setup --computer-id <id>` so the tool never has to look itself up across your computers.
- Keep the key gate on (the default). `--public` means anyone with the URL can use the app and whatever it
  can reach.
- The link with `?key=` is a password. Share it only with people who should have access, and redeploy under
  a new name to change it.
- Delete the key in Orgo when you stop using orgo-deploy.
- Never show API keys on screen, in recordings, in screenshots or in chat logs. If one was shown, revoke it.
