# Live Rollout Paths

These notes describe the currently observed Fortrexs skill rollout layout on
this workstation.

## Working Fortrexs repo

- `C:\CDX\2026-04-18-fortrexs-sms`

Current skill location inside that repo:

- `skills\`

Current wiki files relevant to skill registration:

- `docs/wiki-it-start.txt`
- `docs/wiki-it-skills.txt`

## Shared skill repo mirror

- `C:\CDX\CDX`

Current mirrored skill location:

- `skills\`

This repo may be sparse or freshly initialized. That is acceptable as long as
the mirrored skill is committed cleanly.

## Local Codex install path

- `C:\Users\mraaaooo\.codex\skills`

This is the local installed copy used by Codex.

## Practical rollout order

1. update the skill in the working repo
2. update the wiki description
3. mirror the same skill folder into the shared skill repo if requested
4. copy the same folder into the local Codex install
5. commit the working repo
6. commit the shared skill repo
7. push both repos if requested
