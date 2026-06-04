# GitHub Deployment Guide

## Purpose

This guide describes how to publish and deploy the AI Agent Control Panel Web App from GitHub.

This application is a Node.js server app. It is not a static site, so GitHub Pages is not a suitable deployment target. Deploy it to a server or platform that can run Node.js, keep long-lived processes running, and store Oracle and OCI credentials securely.

## Deployment Model

Recommended deployment flow:

1. Push the `webapp` folder to a private GitHub repository.
2. Store secrets in GitHub Actions secrets or directly on the deployment host.
3. Deploy to a Linux VM, OCI Compute instance, container host, or another Node-capable platform.
4. Run the app behind a reverse proxy such as Nginx, Apache, OCI Load Balancer, or an application gateway.
5. Keep `.env`, `.auth`, wallets, private keys, and OCI config files out of Git.

## Repository Setup

From the repository root, commit the application source but exclude generated and secret files.

Recommended `.gitignore` entries:

```gitignore
webapp/node_modules/
webapp/.env
webapp/.env.*
webapp/.auth
webapp/public/Reports/

# Oracle wallet and OCI credentials
**/Wallet_*/
**/*.sso
**/*.p12
**/*.pem
**/.oci/

# Local machine files
.DS_Store
```

If report templates or sample reports must be versioned, commit them under a separate sample directory rather than `webapp/public/Reports`.

## Required Runtime Environment

At minimum, the deployed app needs:

```bash
NODE_ENV=production
HOST=127.0.0.1
PORT=3000

DB_USER=your_database_user
DB_PASSWORD=your_database_password
DB_CONNECT_STRING=your_database_connect_string
TNS_ADMIN=/path/to/wallet_or_network_config
DB_WALLET_PASSWORD=your_wallet_password_if_required

SELECT_AI_PROFILE=acme_select_ai_hub_nl2sql
AI_AGENT_TEAM=acme_ai_team
MEMORY_TABLE=your_memory_table
```

For LLM rendering and OCI workflows:

```bash
LLM_POST_PROCESS=true
LLM_ENDPOINT=https://inference.generativeai.us-chicago-1.oci.oraclecloud.com
LLM_MODEL_ID=xai.grok-4-1-fast-reasoning
OCI_COMPARTMENT_ID=<oci-compartment-ocid>
OCI_AUTH_TYPE=config_file
OCI_CONFIG_FILE=/.oci/config
OCI_PROFILE=DEFAULT

OCI_STORAGE_LOCATION=<object-storage-location>
OCI_CREDENTIAL_NAME=your_db_oci_credential
RAG_PROFILE_NAME=acme_select_ai_rag_kb_profile
RAG_VECTOR_INDEX_NAME=acme_hub_vector_index_kb
```

For MCP testing:

```bash
MCP_ENDPOINT=https://your-mcp-endpoint.example.com
MCP_AUTH_TOKEN=optional_static_token
MCP_AUTH_ENDPOINT=optional_auth_endpoint
```

## GitHub Secrets

Create GitHub Actions secrets for sensitive values if the workflow writes `.env` during deployment.

Common secrets:

- `DB_USER`
- `DB_PASSWORD`
- `DB_CONNECT_STRING`
- `DB_WALLET_PASSWORD`
- `OCI_COMPARTMENT_ID`
- `OCI_CONFIG_CONTENT`
- `OCI_PRIVATE_KEY`
- `OCI_STORAGE_LOCATION`
- `OCI_CREDENTIAL_NAME`
- `MCP_ENDPOINT`
- `MCP_AUTH_TOKEN`

Wallet files and OCI private keys are easier to manage directly on the deployment host. If you store them in GitHub secrets, store them as base64-encoded content and decode them during deployment.
 
## Manual Deployment From GitHub

Use this when you want to deploy without GitHub Actions.

```bash
sudo -u acmeapp git clone https://github.com/YOUR_ORG/YOUR_REPO.git /opt/acme-ai-agent-webapp
cd /opt/acme-ai-agent-webapp/webapp
npm ci --omit=dev
```

Create `/opt/acme-ai-agent-webapp/webapp/.env` with the required runtime variables, then start the service:

```bash
sudo systemctl restart acme-ai-webapp
sudo systemctl status acme-ai-webapp
```

After later code updates:

```bash
cd /opt/acme-ai-agent-webapp
sudo -u acmeapp git pull
cd webapp
sudo -u acmeapp npm ci --omit=dev
sudo systemctl restart acme-ai-webapp
```

## .auth File
The `.auth` file is used to store application user credentials in Base64 format when using the built-in authentication mode. It should be kept secure and not committed to Git.

## GitHub Actions Deployment With A Self-Hosted Runner

Install a GitHub self-hosted runner on the deployment host and label it `acme-webapp`. The runner should have permission to update `/opt/acme-ai-agent-webapp` and restart the systemd service.

Create `.github/workflows/deploy-webapp.yml` in the repository:

```yaml
name: Deploy webapp

on:
  push:
    branches:
      - main
    paths:
      - "webapp/**"
      - ".github/workflows/deploy-webapp.yml"
  workflow_dispatch:

jobs:
  deploy:
    runs-on:
      - self-hosted
      - linux
      - acme-webapp

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Set up Node.js
        uses: actions/setup-node@v4
        with:
          node-version: "20"
          cache: "npm"
          cache-dependency-path: "webapp/package-lock.json"

      - name: Sync application files
        run: |
          mkdir -p /opt/acme-ai-agent-webapp
          rsync -a --delete \
            --exclude node_modules \
            --exclude .env \
            --exclude .auth \
            --exclude public/Reports \
            webapp/ /opt/acme-ai-agent-webapp/webapp/

      - name: Install production dependencies
        working-directory: /opt/acme-ai-agent-webapp/webapp
        run: npm ci --omit=dev

      - name: Write environment file
        run: |
          cat > /opt/acme-ai-agent-webapp/webapp/.env <<'EOF'
          NODE_ENV=production
          HOST=127.0.0.1
          PORT=3000
          DB_USER=${{ secrets.DB_USER }}
          DB_PASSWORD=${{ secrets.DB_PASSWORD }}
          DB_CONNECT_STRING=${{ secrets.DB_CONNECT_STRING }}
          DB_WALLET_PASSWORD=${{ secrets.DB_WALLET_PASSWORD }}
          SELECT_AI_PROFILE=acme_select_ai_hub_nl2sql
          AI_AGENT_TEAM=acme_ai_team
          LLM_POST_PROCESS=true
          OCI_COMPARTMENT_ID=${{ secrets.OCI_COMPARTMENT_ID }}
          OCI_STORAGE_LOCATION=${{ secrets.OCI_STORAGE_LOCATION }}
          OCI_CREDENTIAL_NAME=${{ secrets.OCI_CREDENTIAL_NAME }}
          MCP_ENDPOINT=${{ secrets.MCP_ENDPOINT }}
          MCP_AUTH_TOKEN=${{ secrets.MCP_AUTH_TOKEN }}
          EOF
          chmod 600 /opt/acme-ai-agent-webapp/webapp/.env

      - name: Restart service
        run: sudo systemctl restart acme-ai-webapp
```

Adjust paths, branches, environment variables, and labels to match the actual GitHub repository and server.

## Reverse Proxy

Terminate TLS at a reverse proxy and forward local traffic to the Node server.

Example Nginx location block:

```nginx
location / {
    proxy_pass http://127.0.0.1:3000;
    proxy_http_version 1.1;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}
```

Keep `HOST=127.0.0.1` when the app is only reachable through the reverse proxy. Use `HOST=0.0.0.0` only when the platform requires the Node process to bind to all interfaces.

## Post-Deployment Checks

Verify the app is listening:

```bash
curl -i http://127.0.0.1:3000/api/auth/me
```

Expected unauthenticated response:

```json
{"ok":true,"authenticated":false,"user":null}
```

Then open the public URL in a browser, sign in, and check:

- Prompt console loads configuration.
- `/api/health` succeeds after authentication.
- Oracle DB connection works.
- AI Agent and Select AI modes can run prompts.
- LLM rendering works if enabled.
- Reports folder can list and save files.
- RAG and Object Storage workflows work if configured.

## Operational Notes

- Rotate default application passwords after first deployment.
- Keep `.auth` persistent across deployments if local app users are managed in production.
- Back up `config/runtime-config.json`, `config/llm-instructions.json`, `config/links.json`, and `public/Reports` if users manage them through the UI.
- Do not commit Oracle wallets, OCI private keys, database passwords, or generated `.env` files.
- Review system logs with `journalctl -u acme-ai-webapp -f`.
