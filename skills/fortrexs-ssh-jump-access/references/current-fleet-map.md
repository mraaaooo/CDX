# Current Fleet Map

Date: 2026-04-29

## Ready aliases

- `files-cdx2` / `nextcloud-cdx2`
  - bootstrap host: `ec2-18-198-238-170.eu-central-1.compute.amazonaws.com`
  - private target: `10.10.0.253`
  - communication name: `files.fortrexs.eu`

- `wiki-cdx2`
  - bootstrap host: `ec2-35-157-27-68.eu-central-1.compute.amazonaws.com`
  - private target: `10.10.0.197`
  - communication name: `wiki.fortrexs.eu`

- `fs-cdx2` / `freeswitch-cdx2`
  - bootstrap host: `ec2-3-70-118-186.eu-central-1.compute.amazonaws.com`
  - private target: `10.10.0.190`
  - communication name: `fs.fortrexs.eu`

- `dotochki-cdx2`
  - bootstrap host: `ec2-52-57-213-13.eu-central-1.compute.amazonaws.com`
  - private target: `10.10.0.158`
  - communication name: `dotochki`
  - observed live web names:
    - `dotochki.ru`
    - `www.dotochki.ru`
    - `dotochki.org`
    - `www.dotochki.org`
    - `dotochki.com`
    - `www.dotochki.com`
    - `api.dotochki.com`

- `chat-cdx2` / `shared-cdx2`
  - bootstrap host: `ec2-18-193-42-129.eu-central-1.compute.amazonaws.com`
  - private target: `10.10.0.12`
  - communication name: `chat/shared-services host`
  - documented shared-services role includes:
    - `chat.fortrexs.eu`
    - `wiki.fortrexs.eu`
    - `ldap.fortrexs.eu`
    - `redmine.fortrexs.eu`

- `fs-debian12-25gb-cdx2` / `95-163-212-246-cdx2`
  - bootstrap host: `95.163.212.246`
  - public target: `95.163.212.246`
  - observed host name: `fs-debian12-25gb`
  - communication name: `fs-debian12-25gb`
  - source restriction variant:
    - `from="3.126.131.133"`
  - bootstrap path:
    - `debian` with `freeswitch.pem`

## Still pending bootstrap

- `ec2-35-158-235-232.eu-central-1.compute.amazonaws.com`
  - current best communication name:
    - `mraaaooo` / Banggood execution host
  - status:
    - no working bootstrap login confirmed yet
