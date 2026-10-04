# syntax=docker/dockerfile:1.27
# https://hub.docker.com/r/linuxserver/code-server/tags
FROM linuxserver/code-server:4.140.0

RUN apt-get update && \
    apt-get install -y curl wget nano && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# uv + Python, installed somewhere the 'abc' user can read
ENV UV_INSTALL_DIR="/usr/local/bin" \
    UV_LINK_MODE="copy" \
    UV_PYTHON_INSTALL_DIR="/opt/uv-python" \
    PYTHON_VERSION=3.14
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
RUN uv python install $PYTHON_VERSION

RUN uv venv /.venv && chmod -R 755 /.venv /opt/uv-python
ENV PATH="/.venv/bin:$PATH"

RUN --mount=type=cache,target=/root/.cache/uv \
    uv pip install --python /.venv/bin/python tqdm

# Defaults template (outside /config, which is a volume)
RUN mkdir -p /etc/code-server-defaults/User /etc/code-server-defaults/extensions
COPY <<'EOF' /etc/code-server-defaults/User/settings.json
{
  "workbench.colorTheme": "Default Dark Modern",
  "python.defaultInterpreterPath": "/.venv/bin/python",
  "python.terminal.activateEnvInSelectedTerminal": true
}
EOF

RUN /app/code-server/bin/code-server \
      --extensions-dir /etc/code-server-defaults/extensions \
      --install-extension ms-python.python \
      --install-extension detachhead.basedpyright \
      --install-extension DavidAnson.vscode-markdownlint

# Init script: LSIO paths are /config/data and /config/extensions
COPY --chmod=755 <<'EOF' /custom-cont-init.d/seed-vscode.sh
#!/usr/bin/with-contenv bash
echo "==== [Custom Init] Seeding settings and extensions ===="

mkdir -p /config/data/User /config/extensions

if [ ! -f /config/data/User/settings.json ]; then
  cp /etc/code-server-defaults/User/settings.json /config/data/User/settings.json
fi

# -n: don't overwrite extensions the user already has/updated
cp -rn /etc/code-server-defaults/extensions/. /config/extensions/

chown -R abc:abc /config/data /config/extensions
EOF

# Install the OpenCode CLI binary
RUN ARCH=$(uname -m | sed 's/x86_64/x64/; s/aarch64/arm64/') && \
    curl -fsSL "https://github.com/anomalyco/opencode/releases/latest/download/opencode-linux-${ARCH}.tar.gz" \
      | tar -xz -C /usr/local/bin opencode && \
    chmod 755 /usr/local/bin/opencode && \
    opencode --version

