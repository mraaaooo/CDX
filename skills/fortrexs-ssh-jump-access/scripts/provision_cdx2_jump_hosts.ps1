param(
    [string]$SshConfig = 'C:\Users\mraaaooo\.codex\tmp\ssh\config',
    [string]$PublicKeyPath = 'C:\Users\mraaaooo\.ssh\cdx2_fortrexs_jump_ed25519.pub',
    [string]$RestrictedSource = '10.10.0.191',
    [string]$TargetsJsonPath,
    [string]$Alias,
    [string]$PublicHost,
    [string]$BootstrapUser,
    [string]$BootstrapKey
)

$ErrorActionPreference = 'Stop'

$publicKey = (Get-Content -LiteralPath $PublicKeyPath -Raw).Trim()
$restrictedKey = 'from="' + $RestrictedSource + '" ' + $publicKey

$defaultTargets = @(
    @{
        Alias         = 'ec2-18-198-238-170-cdx2'
        PublicHost    = 'ec2-18-198-238-170.eu-central-1.compute.amazonaws.com'
        BootstrapUser = 'ubuntu'
        BootstrapKey  = 'C:\Users\mraaaooo\.ssh\mraaaooo.pem'
    },
    @{
        Alias         = 'ec2-35-157-27-68-cdx2'
        PublicHost    = 'ec2-35-157-27-68.eu-central-1.compute.amazonaws.com'
        BootstrapUser = 'ubuntu'
        BootstrapKey  = 'C:\Users\mraaaooo\.ssh\mraaaooo.pem'
    },
    @{
        Alias         = 'ec2-3-70-118-186-cdx2'
        PublicHost    = 'ec2-3-70-118-186.eu-central-1.compute.amazonaws.com'
        BootstrapUser = 'admin'
        BootstrapKey  = 'C:\Users\mraaaooo\.ssh\freeswitch.pem'
    },
    @{
        Alias         = 'ec2-52-57-213-13-cdx2'
        PublicHost    = 'ec2-52-57-213-13.eu-central-1.compute.amazonaws.com'
        BootstrapUser = 'ubuntu'
        BootstrapKey  = 'C:\Users\mraaaooo\.ssh\mraaaooo.pem'
    },
    @{
        Alias         = 'ec2-18-193-42-129-cdx2'
        PublicHost    = 'ec2-18-193-42-129.eu-central-1.compute.amazonaws.com'
        BootstrapUser = 'admin'
        BootstrapKey  = 'C:\Users\mraaaooo\.ssh\mraaaooo.pem'
    }
)

if ($TargetsJsonPath) {
    $targets = @(Get-Content -LiteralPath $TargetsJsonPath -Raw | ConvertFrom-Json)
} elseif ($PublicHost) {
    if (-not $Alias) {
        throw 'Alias is required when provisioning a custom single host.'
    }
    if (-not $BootstrapUser) {
        throw 'BootstrapUser is required when provisioning a custom single host.'
    }
    if (-not $BootstrapKey) {
        throw 'BootstrapKey is required when provisioning a custom single host.'
    }
    $targets = @(
        @{
            Alias         = $Alias
            PublicHost    = $PublicHost
            BootstrapUser = $BootstrapUser
            BootstrapKey  = $BootstrapKey
        }
    )
} else {
    $targets = $defaultTargets
}

$remoteTemplate = @'
set -euo pipefail
trap 'echo REMOTE_ERROR_LINE=${LINENO}' ERR

user_name='cdx2'
user_home="/home/${user_name}"
sudoers_file="/etc/sudoers.d/${user_name}"
authorized_line='__AUTHORIZED_LINE__'

if ! id "${user_name}" >/dev/null 2>&1; then
    adduser --disabled-password --gecos "" --shell /bin/bash "${user_name}"
else
    usermod -s /bin/bash "${user_name}" || true
fi

install -d -m 0700 -o "${user_name}" -g "${user_name}" "${user_home}/.ssh"
install -d -m 0755 -o "${user_name}" -g "${user_name}" \
    "${user_home}/bin" \
    "${user_home}/work" \
    "${user_home}/runbooks" \
    "${user_home}/snapshots"

printf '%s\n' "${authorized_line}" > "${user_home}/.ssh/authorized_keys"
chown "${user_name}:${user_name}" "${user_home}/.ssh/authorized_keys"
chmod 0600 "${user_home}/.ssh/authorized_keys"

touch "${user_home}/.hushlogin"
chown "${user_name}:${user_name}" "${user_home}/.hushlogin"
chmod 0644 "${user_home}/.hushlogin"

printf '%s ALL=(ALL) NOPASSWD: ALL\n' "${user_name}" > "${sudoers_file}"
chmod 0440 "${sudoers_file}"
visudo -cf "${sudoers_file}" >/dev/null

private_ip="$(ip -4 -o addr show scope global | tr -s ' ' | cut -d' ' -f4 | cut -d/ -f1 | grep -E '^(10\.|172\.(1[6-9]|2[0-9]|3[0-1])\.|192\.168\.)' | head -n 1)"
fqdn="$(hostname -f 2>/dev/null || hostname)"

printf 'ALIAS=%s\n' '__ALIAS__'
printf 'PUBLIC_HOST=%s\n' '__PUBLIC_HOST__'
printf 'BOOTSTRAP_USER=%s\n' '__BOOTSTRAP_USER__'
printf 'FQDN=%s\n' "${fqdn}"
printf 'PRIVATE_IP=%s\n' "${private_ip}"
printf 'VERIFY_LOGIN=%s\n' "$(su -s /bin/bash -c 'whoami' cdx2)"
printf 'VERIFY_SUDO=%s\n' "$(sudo -n -l -U cdx2 >/dev/null 2>&1 && echo ok || echo failed)"
'@

$results = @()

foreach ($target in $targets) {
    Write-Host "=== $($target.PublicHost) ==="
    $remoteScript = $remoteTemplate.
        Replace('__AUTHORIZED_LINE__', $restrictedKey).
        Replace('__ALIAS__', $target.Alias).
        Replace('__PUBLIC_HOST__', $target.PublicHost).
        Replace('__BOOTSTRAP_USER__', $target.BootstrapUser)

    $output = $remoteScript | & ssh `
        -F $sshConfig `
        -o BatchMode=yes `
        -o StrictHostKeyChecking=no `
        -o ConnectTimeout=12 `
        -i $target.BootstrapKey `
        "$($target.BootstrapUser)@$($target.PublicHost)" `
        "sudo bash -s --" 2>&1

    if ($LASTEXITCODE -ne 0) {
        Write-Host $output
        throw "Remote provisioning failed on $($target.PublicHost) with exit code $LASTEXITCODE"
    }

    $obj = [ordered]@{}
    foreach ($line in $output) {
        if ($line -match '^[A-Z_]+=') {
            $parts = $line -split '=', 2
            $obj[$parts[0]] = $parts[1]
        }
    }

    if (-not $obj['PRIVATE_IP']) {
        Write-Host $output
        throw "Did not receive PRIVATE_IP from $($target.PublicHost)"
    }

    $results += [pscustomobject]$obj
}

$results | ConvertTo-Json -Depth 3
