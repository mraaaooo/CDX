---
name: fortrexs-skill-rollout
description: Use when creating or updating a Fortrexs internal Codex skill and you need to roll it out cleanly by saving the repo copy, installing the local .codex copy, adding or updating the wiki IT Skills description, and committing or pushing the right repos without mixing unrelated changes.
---

# Fortrexs Skill Rollout

## Overview

This skill handles the housekeeping around a new or updated Fortrexs skill.

Use it when a skill already exists or is being created and the remaining work
is the rollout:
- save the repo copy
- install the local Codex copy
- describe the skill in the wiki
- commit and push the right repositories

This skill is about rollout discipline, not the domain logic of the skill
itself.

## Workflow

### 1. Treat the repo copy as the source of truth

Create or update the skill in a versioned repo first.

For the current Fortrexs workflow, the two relevant destinations are usually:
- the working Fortrexs repo:
  - `C:\CDX\2026-04-18-fortrexs-sms\skills\<skill-name>\`
- the shared skill repo mirror:
  - `C:\CDX\CDX\skills\<skill-name>\`

Do not start by writing only into `%USERPROFILE%\.codex\skills`. The local
install is the deploy copy, not the authoritative source.

### 2. Keep the skill small and explicit

A rollout skill should preserve the actual skill folder structure:
- `SKILL.md`
- optional `references/`
- optional `scripts/`
- optional `assets/`

Do not add extra README-like clutter unless the skill truly needs it.

### 3. Install the local Codex copy after the repo copy exists

Mirror the skill into:

- `%USERPROFILE%\.codex\skills\<skill-name>\`

Copy the exact repo version rather than hand-editing the local install
separately. That keeps the local install and repo copy aligned.

### 4. Register the skill in the wiki

For Fortrexs internal docs, the current wiki page is:

- `docs/wiki-it-skills.txt`

Add a short section that explains:
- what the skill is for
- when to use it
- where the repo copy lives
- where the local install lives, if helpful

If the IT index page does not already link to the skills page, add:

- `[[it:skills|IT Skills]]`

to:

- `docs/wiki-it-start.txt`

### 5. Keep commits scoped

Before committing, inspect git status and stage only the files that belong to
the skill rollout:
- the skill folder
- wiki updates that describe the skill

Do not accidentally sweep unrelated repo drift into the same commit.

### 6. Mirror to the shared skill repo when requested

If the user asked to keep the skill in the separate `CDX` repo too:
- ensure the local checkout exists
- copy the same skill folder there
- commit it separately
- push it separately

Treat this as a mirror operation, not a second independent implementation.

### 7. Report any operational wrinkles honestly

Common examples:
- permission issues writing into `%USERPROFILE%\.codex\skills`
- the target repo is empty
- the working repo remote is not the one the user named
- pushes succeed for one repo but not another

Surface those clearly so the next person does not have to rediscover them.

## Guardrails

- Repo copy first, local install second.
- Keep the local install byte-for-byte aligned with the repo copy when possible.
- Update the wiki skills page when a new reusable skill is introduced.
- Commit only the files that belong to the skill rollout.
- If there are two repos involved, commit them separately and name that clearly.

## Read This Reference

For the current Fortrexs environment, also read:

- [references/live-rollout-paths.md](references/live-rollout-paths.md)
