# ACME AI Agent Web App

This is a small Node web app for running the ACME Oracle AI Agent team and direct Select AI profile from a browser.

## Setup

1. Copy `.env.example` to `.env`.
2. Fill in `DB_USER`, `DB_PASSWORD`, and `DB_CONNECT_STRING`.
3. If your Autonomous Database connection uses a wallet, set `TNS_ADMIN` to the wallet directory.
4. If Node reports `NJS-505` or `bad decrypt`, set `DB_WALLET_PASSWORD` to the password used when the wallet was downloaded.
5. Install and start:

```bash
npm install
npm start
```

Open `http://localhost:3000`.

## Runtime Modes

- **AI Agent** runs `SELECT AI AGENT '<prompt>'` after setting `AI_AGENT_TEAM`.
- **Select AI** runs `SELECT AI '<prompt>'` after setting `SELECT_AI_PROFILE`.

The UI shows the raw database response and renders detected HTML inside a sandboxed iframe.

## Other Markdown Files

Please read @Feature_LIST.md for a list of features and how to enable them.

@GITHUB_DEPLOYMENT.md has instructions for deploying this app.

## Application Demo video

[![ACME AI Agent Web App Demo](https://img.youtube.com/vi/Lh2gtrdyr28/0.jpg)](https://www.youtube.com/watch?v=Lh2gtrdyr28)

## LLM Models for Post-Processing Database Results

After Select AI or AI Agent returns a database result, the app can send that result to OCI Generative AI for HTML rendering.

Please use the MODEL which is available in your OCI tenancy and in your selected region. The example above uses `xai.grok-4-1-fast-reasoning`, which is available in us-chicago-1 as of June 2024. Check the [OCI Generative AI documentation](https://docs.oracle.com/en-us/iaas/generative-ai/available-regions.html) for currently available models and regions.

Required `.env` settings:

```bash
LLM_POST_PROCESS=true
LLM_ENDPOINT=https://inference.generativeai.us-chicago-1.oci.oraclecloud.com
LLM_MODEL_ID=xai.grok-4-1-fast-reasoning
OCI_COMPARTMENT_ID=<oci-compartment-ocid>
OCI_AUTH_TYPE=config_file
OCI_CONFIG_FILE=~/.oci/config
OCI_PROFILE=DEFAULT
```

By default the app uses `~/.oci/config`. Set `OCI_CONFIG_FILE` if your OCI config is somewhere else.

## Default Password
The default database password is `welcome1`. Please change this in production environments.
username is `admin` and `user` by default. and 'user' can be added with admin privileges.
