# Live Wiki Paths

Current observed Fortrexs wiki host:

- hostname: `wiki.fortrexs.eu`
- SSH user: `ubuntu`
- direct SSH form:
  - `ssh -i C:\Users\mraaaooo\.ssh\mraaaooo.pem ubuntu@35.157.27.68`

Current DokuWiki site root on the host:

- `/srv/www/dokuwiki/sites/wiki.fortrexs.eu/public/`

Current page tree root:

- `/srv/www/dokuwiki/sites/wiki.fortrexs.eu/public/data/pages/`

Common page paths:

- `it:deltachat`
  - `/srv/www/dokuwiki/sites/wiki.fortrexs.eu/public/data/pages/it/deltachat.txt`
- `it:mail-upgrade`
  - `/srv/www/dokuwiki/sites/wiki.fortrexs.eu/public/data/pages/it/mail-upgrade.txt`
- `it:sogo`
  - `/srv/www/dokuwiki/sites/wiki.fortrexs.eu/public/data/pages/it/sogo.txt`
- `it:skills`
  - `/srv/www/dokuwiki/sites/wiki.fortrexs.eu/public/data/pages/it/skills.txt`
- `it:start`
  - `/srv/www/dokuwiki/sites/wiki.fortrexs.eu/public/data/pages/it/start.txt`

Discoverability note:

- after publishing a new human-facing page, check whether it should also be
  linked from `it:start` or another nearby index page
- otherwise the page can be live on disk but still appear "missing" in the UI

Practical publish pattern:

1. prepare text locally
2. `scp` snippet to `/tmp/`
3. `ssh` to the wiki host
4. back up the live page
5. append or patch narrowly
6. verify with `tail`

Example backup naming:

- `deltachat.txt.bak-20260426-chat-imap-compat`

When the path is uncertain:

- inspect `/srv/www/dokuwiki/sites/wiki.fortrexs.eu/public/data/pages/`
- or run a narrow `find` rooted there instead of searching the whole host
