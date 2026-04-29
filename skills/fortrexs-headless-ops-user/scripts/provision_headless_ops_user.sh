#!/usr/bin/env bash
set -euo pipefail

USER_NAME="${USER_NAME:-cdx}"
SOURCE_USER="${SOURCE_USER:-ubuntu}"
USER_HOME="/home/${USER_NAME}"
SOURCE_AUTH_KEYS="/home/${SOURCE_USER}/.ssh/authorized_keys"
SUDOERS_FILE="/etc/sudoers.d/${USER_NAME}"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"

if ! id "${USER_NAME}" >/dev/null 2>&1; then
    adduser --disabled-password --gecos "" "${USER_NAME}"
fi

install -d -m 0700 -o "${USER_NAME}" -g "${USER_NAME}" "${USER_HOME}/.ssh"

if [[ -f "${SOURCE_AUTH_KEYS}" ]]; then
    cp -a "${SOURCE_AUTH_KEYS}" "${USER_HOME}/.ssh/authorized_keys"
    chown "${USER_NAME}:${USER_NAME}" "${USER_HOME}/.ssh/authorized_keys"
    chmod 0600 "${USER_HOME}/.ssh/authorized_keys"
fi

install -d -m 0755 -o "${USER_NAME}" -g "${USER_NAME}" \
    "${USER_HOME}/bin" \
    "${USER_HOME}/work" \
    "${USER_HOME}/runbooks" \
    "${USER_HOME}/snapshots"

touch "${USER_HOME}/.hushlogin"
chown "${USER_NAME}:${USER_NAME}" "${USER_HOME}/.hushlogin"
chmod 0644 "${USER_HOME}/.hushlogin"

if [[ -f "${SUDOERS_FILE}" ]]; then
    cp -a "${SUDOERS_FILE}" "${SUDOERS_FILE}.bak-${TIMESTAMP}"
fi

printf '%s ALL=(ALL) NOPASSWD: ALL\n' "${USER_NAME}" > "${SUDOERS_FILE}"
chmod 0440 "${SUDOERS_FILE}"
visudo -cf "${SUDOERS_FILE}"

getent passwd "${USER_NAME}"
printf '\n---\n'
sudo -l -U "${USER_NAME}"
