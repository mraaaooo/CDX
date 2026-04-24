# Live Mail Host Notes

These notes are specific to the currently observed Fortrexs production mail
host and should be treated as operational reference, not timeless doctrine.

## Host

- mail host: `mail.fortrexs.eu`
- LDAP base DN: `o=domains,dc=fortrex,dc=eu`
- iRedAdmin settings file: `/opt/www/iredadmin/settings.py`

## Supported write path

The reliable live admin bind is stored in:

- `/opt/www/iredadmin/settings.py`

Read these keys at runtime:

- `ldap_bind_dn`
- `ldap_bind_password`

Do not copy their values into repo files.

## Observed pitfall

The local peer-credential path:

```bash
sudo ldapmodify -Y EXTERNAL -H ldapi:///
```

can still fail on this host with:

```text
ldap_modify: Insufficient access (50)
```

So for production edits, expect to use the iRedAdmin LDAP admin bind instead.

## Reliable lookup fallback

When LDAP search filters are unexpectedly empty, this fallback has been useful:

```bash
sudo slapcat | sed -n '/^dn: mail=user@example.com,/,/^$/p'
```

It helped confirm live entries such as:

- `mail=mraaaooo@ruaxx.org,ou=Users,domainName=ruaxx.org,o=domains,dc=fortrex,dc=eu`
- `mail=sms_test@fortrexs.eu,ou=Users,domainName=fortrexs.eu,o=domains,dc=fortrex,dc=eu`

## Example verification command

```bash
ldapsearch -x -D '<bind-dn>' -w '<bind-password>' -H ldap://127.0.0.1:389 -LLL \
  -b 'o=domains,dc=fortrex,dc=eu' \
  '(|(mail=mraaaooo@ruaxx.org)(mail=sms_test@fortrexs.eu))' \
  dn mail fortrexsServiceAccess
```
