---
name: fortrexs-dokuwiki-publish
description: Publish or update Fortrexs internal DokuWiki pages on wiki.fortrexs.eu by preparing text locally, locating the live page file, backing it up, appending or patching the right section over SSH, and verifying the result. Use when the user asks to put notes onto the wiki, update an IT page such as it:deltachat or it:skills, or keep operational findings reusable in the live Fortrexs wiki.
---

# Fortrexs DokuWiki Publish

## Overview

Publish Fortrexs internal notes to the live DokuWiki in a repeatable way.
Keep the workflow narrow:

- prepare the text locally first
- back up the live wiki page before editing
- append or patch only the needed section
- verify the live tail after the write
- if a new page is created, check whether a navigation/index page must link to it

Read [references/live-wiki-paths.md](references/live-wiki-paths.md) before
touching the live host.

## Workflow

### 1. Prepare the text locally first

Prefer to draft or update the content in a local repo note before touching the
live wiki. Good sources are:

- a repo doc in `docs/`
- a local `wiki-it-*.txt` staging file
- a small temporary snippet file when only a short section is needed

Do not improvise a long remote edit directly inside the SSH command.

### 2. Resolve the page path from the wiki namespace

Map the DokuWiki page name to the file path under the live wiki tree:

- `it:deltachat` -> `.../data/pages/it/deltachat.txt`
- `it:skills` -> `.../data/pages/it/skills.txt`

If the exact path is unclear, locate it on the wiki host before writing.

### 3. Upload a snippet when the change is append-oriented

For a short new section:

- create a local snippet file
- upload it to `/tmp` on the wiki host
- append it only if the heading is not already present

This keeps quoting simple and makes the change idempotent.

### 4. Back up the live page before editing

Always create a same-directory backup first, using a dated suffix such as:

- `.bak-YYYYMMDD-topic`

Do this even for small appends.

### 5. Prefer narrow edits

Choose the least risky edit shape:

- append a new dated section when adding fresh findings
- patch a small existing section when correcting a known area

Do not overwrite the whole page unless the user explicitly wants that and the
page is dedicated to the same topic.

### 6. Verify immediately

After editing:

- read the page tail or the edited section
- confirm the new heading and body are present
- mention the backup path in the report

### 7. Check discoverability when a page is new

If you create or start using a page that is meant to be found by humans, do not
stop at publishing the page itself.

Check whether one of the index pages should also be updated, especially:

- `it:start`
- `it:skills`

Typical cases:

- a new operational page like `it:mail-upgrade` should usually be linked from
  `it:start`
- a new reusable skill page or skill note should usually be linked from
  `it:skills`

If the page exists but is not linked from the relevant index, users can easily
experience it as "missing" even though the file was published correctly.

## Guardrails

- Use the live DokuWiki file tree, not the public HTML view, for publication.
- Keep edits page-scoped and section-scoped.
- Back up first.
- When creating a new page, also decide whether `it:start` or another index page
  should link to it.
- If the host or page path is different than expected, stop guessing and
  rediscover it from the live server.
- Treat wiki publication as an operational write: report exactly what page was
  changed and how it was verified.
