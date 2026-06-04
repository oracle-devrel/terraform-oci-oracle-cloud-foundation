"use strict";

const http = require("node:http");
const fs = require("node:fs");
const path = require("node:path");
const crypto = require("node:crypto");
const { spawn } = require("node:child_process");
const { URL } = require("node:url");

const envPath = path.join(__dirname, ".env");
const authPath = path.join(__dirname, ".auth");
const publicDir = path.join(__dirname, "public");
const reportsDir = path.join(publicDir, "Reports");
const configDir = path.join(__dirname, "config");
const runtimeConfigPath = path.join(configDir, "runtime-config.json");
const llmInstructionsConfigPath = path.join(configDir, "llm-instructions.json");
const linksConfigPath = path.join(configDir, "links.json");
loadDotEnv(envPath);
ensureAuthFile(authPath);

let oracledb;
try {
  oracledb = require("oracledb");
} catch (error) {
  console.error("Missing dependency: run `npm install` in AskOracle/DTC/webapp.");
  throw error;
}

if (process.env.ORACLE_CLIENT_LIB_DIR) {
  oracledb.initOracleClient({ libDir: process.env.ORACLE_CLIENT_LIB_DIR });
}

oracledb.outFormat = oracledb.OUT_FORMAT_OBJECT;
oracledb.fetchAsString = [oracledb.CLOB];

const port = Number(process.env.PORT || 3000);
const host = process.env.HOST || "127.0.0.1";
const sessionTimeoutMs = Number(process.env.SESSION_TIMEOUT_MINUTES || 30) * 60 * 1000;
const sessionTimeoutSeconds = Math.floor(sessionTimeoutMs / 1000);
const httpRequestTimeoutMs = Number(process.env.HTTP_REQUEST_TIMEOUT_MS || 30 * 60 * 1000);
const jsonBodyMaxBytes = Number(process.env.JSON_BODY_MAX_BYTES || 25 * 1024 * 1024);
let defaultProfile;
let defaultTeam;
let llmEndpoint;
let llmModelId;
let llmPostProcess;

let pool;
let genAiClient;
let objectStorageClient;
const sessions = new Map();
const askRequestStatuses = new Map();
const askRequestStatusTtlMs = Number(process.env.ASK_REQUEST_STATUS_TTL_MS || 10 * 60 * 1000);
let databaseRuntimeConfigReady = false;
let syncedGoogleSheetUrl = "";

const server = http.createServer(async (req, res) => {
  try {
    const url = new URL(req.url, `http://${req.headers.host}`);
    const currentUser = getCurrentUser(req);

    if (req.method === "GET" && url.pathname === "/api/auth/me") {
      return sendJson(res, 200, {
        ok: true,
        authenticated: Boolean(currentUser),
        user: currentUser ? publicUser(currentUser) : null
      });
    }

    if (req.method === "POST" && url.pathname === "/api/auth/login") {
      return handleLogin(req, res);
    }

    if (req.method === "POST" && url.pathname === "/api/auth/logout") {
      return handleLogout(req, res);
    }

    if (url.pathname.startsWith("/api/") && !currentUser) {
      return sendJson(res, 401, {
        ok: false,
        error: "Authentication required"
      });
    }

    if (req.method === "POST" && url.pathname === "/api/auth/change-password") {
      return handleChangePassword(req, res, currentUser);
    }

    if (req.method === "GET" && url.pathname === "/api/config") {
      return sendJson(res, 200, getPublicConfig(isAdmin(currentUser)));
    }

    if (req.method === "POST" && url.pathname === "/api/config") {
      if (!isAdmin(currentUser)) {
        return sendForbidden(res);
      }
      return handleSaveConfig(req, res);
    }

    if (req.method === "POST" && url.pathname === "/api/select-ai-profile-llm") {
      if (!isAdmin(currentUser)) {
        return sendForbidden(res);
      }
      return handleUpdateSelectAiProfileLlm(req, res);
    }

    if (req.method === "POST" && url.pathname === "/api/restart") {
      if (!isAdmin(currentUser)) {
        return sendForbidden(res);
      }
      return handleRestart(res);
    }

    if (req.method === "GET" && url.pathname === "/api/users") {
      if (!isAdmin(currentUser)) {
        return sendForbidden(res);
      }
      return handleUsers(res);
    }

    if (req.method === "POST" && url.pathname === "/api/users") {
      if (!isAdmin(currentUser)) {
        return sendForbidden(res);
      }
      return handleCreateUser(req, res);
    }

    if (req.method === "GET" && url.pathname === "/api/links") {
      if (!isAdmin(currentUser)) {
        return sendForbidden(res);
      }
      return handleLinks(res);
    }

    if (req.method === "POST" && url.pathname === "/api/links") {
      if (!isAdmin(currentUser)) {
        return sendForbidden(res);
      }
      return handleCreateLink(req, res);
    }

    if (req.method === "POST" && url.pathname === "/api/links/delete") {
      if (!isAdmin(currentUser)) {
        return sendForbidden(res);
      }
      return handleDeleteLink(req, res);
    }

    if (req.method === "GET" && url.pathname === "/api/health") {
      return handleHealth(res);
    }

    if (req.method === "POST" && url.pathname === "/api/mcp/test") {
      if (!isAdmin(currentUser)) {
        return sendForbidden(res);
      }
      return handleMcpTest(req, res);
    }

    if (req.method === "GET" && url.pathname === "/api/ai-agents") {
      if (!isAdmin(currentUser)) {
        return sendForbidden(res);
      }
      return handleAiAgents(res);
    }

    if (req.method === "GET" && url.pathname === "/api/ai-manager") {
      if (!isAdmin(currentUser)) {
        return sendForbidden(res);
      }
      return handleAiManager(res);
    }

    if (req.method === "POST" && url.pathname === "/api/ai-manager/delete") {
      if (!isAdmin(currentUser)) {
        return sendForbidden(res);
      }
      return handleDeleteAiManagerItem(req, res);
    }

    if (req.method === "POST" && url.pathname === "/api/ai-builder/create") {
      if (!isAdmin(currentUser)) {
        return sendForbidden(res);
      }
      return handleCreateAiBuilderItem(req, res);
    }

    if (req.method === "GET" && url.pathname === "/api/ai-topology") {
      if (!isAdmin(currentUser)) {
        return sendForbidden(res);
      }
      return handleAiTopology(res);
    }

    if (req.method === "POST" && url.pathname === "/api/latest-team-task-execution") {
      if (!isAdmin(currentUser)) {
        return sendForbidden(res);
      }
      return handleLatestTeamTaskExecution(req, res);
    }

    if (req.method === "GET" && url.pathname === "/api/select-ai-profiles") {
      if (!isAdmin(currentUser)) {
        return sendForbidden(res);
      }
      return handleSelectAiProfiles(res);
    }

    if (req.method === "GET" && url.pathname === "/api/user-prompts") {
      if (!isAdmin(currentUser)) {
        return sendForbidden(res);
      }
      return handleUserPrompts(url, res);
    }

    if (req.method === "GET" && url.pathname === "/api/memory-table") {
      if (!isAdmin(currentUser)) {
        return sendForbidden(res);
      }
      return handleMemoryTable(url, res);
    }

    if (req.method === "GET" && url.pathname === "/api/rag") {
      if (!isAdmin(currentUser)) {
        return sendForbidden(res);
      }
      return handleRag(res);
    }

    if (req.method === "GET" && url.pathname === "/api/reports") {
      if (!isAdmin(currentUser)) {
        return sendForbidden(res);
      }
      return handleReports(res);
    }

    if (req.method === "GET" && url.pathname === "/api/reports/file") {
      if (!isAdmin(currentUser)) {
        return sendForbidden(res);
      }
      return handleReportFile(url, res);
    }

    if (req.method === "POST" && url.pathname === "/api/reports/rename") {
      if (!isAdmin(currentUser)) {
        return sendForbidden(res);
      }
      return handleRenameReport(req, res);
    }

    if (req.method === "POST" && url.pathname === "/api/reports/delete") {
      if (!isAdmin(currentUser)) {
        return sendForbidden(res);
      }
      return handleDeleteReport(req, res);
    }

    if (req.method === "POST" && url.pathname === "/api/reports/folder") {
      if (!isAdmin(currentUser)) {
        return sendForbidden(res);
      }
      return handleCreateReportFolder(req, res);
    }

    if (req.method === "POST" && url.pathname === "/api/reports/folder/rename") {
      if (!isAdmin(currentUser)) {
        return sendForbidden(res);
      }
      return handleRenameReportFolder(req, res);
    }

    if (req.method === "POST" && url.pathname === "/api/reports/folder/delete") {
      if (!isAdmin(currentUser)) {
        return sendForbidden(res);
      }
      return handleDeleteReportFolder(req, res);
    }

    if (req.method === "POST" && url.pathname === "/api/reports/move") {
      if (!isAdmin(currentUser)) {
        return sendForbidden(res);
      }
      return handleMoveReport(req, res);
    }

    if (req.method === "POST" && url.pathname === "/api/reports/upload-rag") {
      if (!isAdmin(currentUser)) {
        return sendForbidden(res);
      }
      return handleUploadReportToRag(req, res);
    }

    if (req.method === "POST" && url.pathname === "/api/reports/save-html") {
      if (!isAdmin(currentUser)) {
        return sendForbidden(res);
      }
      return handleSaveHtmlReport(req, res);
    }

    if (req.method === "GET" && url.pathname === "/api/markdown-upload") {
      if (!isAdmin(currentUser)) {
        return sendForbidden(res);
      }
      return handleMarkdownUploadConfig(res);
    }

    if (req.method === "POST" && url.pathname === "/api/markdown-upload") {
      if (!isAdmin(currentUser)) {
        return sendForbidden(res);
      }
      return handleMarkdownUpload(req, res);
    }

    if (req.method === "GET" && url.pathname === "/api/llm-instructions") {
      return handleGetLlmInstructions(res);
    }

    if (req.method === "POST" && url.pathname === "/api/llm-instructions") {
      return handleSaveLlmInstructions(req, res);
    }

    if (req.method === "GET" && url.pathname === "/api/ask/status") {
      return handleAskStatus(url, res, currentUser);
    }

    if (req.method === "POST" && url.pathname === "/api/ask") {
      return handleAsk(req, res, currentUser);
    }

    if (req.method === "GET") {
      return serveStatic(url.pathname, res);
    }

    sendJson(res, 405, { error: "Method not allowed" });
  } catch (error) {
    console.error(error);
    sendJson(res, 500, { error: "Unexpected server error", detail: error.message });
  }
});

server.requestTimeout = httpRequestTimeoutMs;
server.timeout = httpRequestTimeoutMs;
server.keepAliveTimeout = Math.min(120000, Math.max(5000, httpRequestTimeoutMs - 5000));
server.headersTimeout = Math.min(120000, Math.max(60000, server.keepAliveTimeout + 5000));

server.listen(port, host, () => {
  console.log(`DTC AI Agent web app listening on http://${host}:${port}`);
});

async function handleLogin(req, res) {
  const body = await readJson(req);
  const username = String(body.username || "").trim();
  const password = String(body.password || "");
  const users = readAuthUsers();
  const user = users.find((candidate) => {
    return candidate.username === username && decodePassword(candidate.password) === password;
  });

  if (!user) {
    return sendJson(res, 401, {
      ok: false,
      error: "Invalid username or password"
    });
  }

  const sessionId = crypto.randomBytes(32).toString("hex");
  sessions.set(sessionId, {
    username: user.username,
    displayName: user.displayName,
    role: normalizeRole(user.role),
    createdAt: Date.now(),
    lastSeenAt: Date.now()
  });
  res.setHeader("Set-Cookie", sessionCookie(sessionId));
  sendJson(res, 200, {
    ok: true,
    user: publicUser(user)
  });
}

function handleLogout(req, res) {
  const sessionId = getSessionId(req);
  if (sessionId) {
    sessions.delete(sessionId);
  }
  res.setHeader("Set-Cookie", "dtc_session=; HttpOnly; SameSite=Lax; Path=/; Max-Age=0");
  sendJson(res, 200, {
    ok: true
  });
}

function handleUsers(res) {
  sendJson(res, 200, {
    ok: true,
    users: readAuthUsers().map(publicUser)
  });
}

async function handleChangePassword(req, res, currentUser) {
  const body = await readJson(req);
  const currentPassword = String(body.currentPassword || "");
  const newPassword = String(body.newPassword || "");
  const confirmPassword = String(body.confirmPassword || "");

  if (!currentPassword || !newPassword) {
    return sendJson(res, 400, {
      ok: false,
      error: "Current password and new password are required"
    });
  }
  if (newPassword !== confirmPassword) {
    return sendJson(res, 400, {
      ok: false,
      error: "New password and confirmation do not match"
    });
  }
  if (newPassword.length < 6) {
    return sendJson(res, 400, {
      ok: false,
      error: "New password must be at least 6 characters"
    });
  }

  const users = readAuthUsers();
  const user = users.find((candidate) => candidate.username === currentUser.username);
  if (!user || decodePassword(user.password) !== currentPassword) {
    return sendJson(res, 401, {
      ok: false,
      error: "Current password is incorrect"
    });
  }

  user.password = encodePassword(newPassword);
  await writeAuthUsers(users);

  sendJson(res, 200, {
    ok: true,
    user: publicUser(user)
  });
}

async function handleCreateUser(req, res) {
  const body = await readJson(req);
  let username;
  try {
    username = normalizeUsername(body.username);
  } catch (error) {
    return sendJson(res, 400, {
      ok: false,
      error: error.message
    });
  }
  const password = String(body.password || "");
  const displayName = String(body.displayName || "").trim();
  const role = normalizeRole(body.role);

  if (!username || !password || !displayName) {
    return sendJson(res, 400, {
      ok: false,
      error: "Username, password, and display name are required"
    });
  }

  const users = readAuthUsers();
  if (users.some((user) => user.username.toLowerCase() === username.toLowerCase())) {
    return sendJson(res, 409, {
      ok: false,
      error: `User ${username} already exists`
    });
  }

  const user = {
    username,
    displayName,
    password: encodePassword(password),
    role
  };
  users.push(user);
  await writeAuthUsers(users);

  sendJson(res, 200, {
    ok: true,
    user: publicUser(user),
    users: users.map(publicUser)
  });
}

async function handleLinks(res) {
  try {
    sendJson(res, 200, {
      ok: true,
      links: readLinks()
    });
  } catch (error) {
    sendJson(res, 500, {
      ok: false,
      error: "Could not load links",
      detail: error.message
    });
  }
}

async function handleCreateLink(req, res) {
  try {
    const body = await readJson(req);
    const link = normalizeLinkInput(body);
    const links = readLinks();
    links.push({
      id: crypto.randomUUID(),
      name: link.name,
      url: link.url,
      createdAt: new Date().toISOString()
    });
    await writeLinks(links);

    sendJson(res, 200, {
      ok: true,
      links,
      message: "Link added"
    });
  } catch (error) {
    sendJson(res, 400, {
      ok: false,
      error: error.message || "Could not add link"
    });
  }
}

async function handleDeleteLink(req, res) {
  try {
    const body = await readJson(req);
    const id = String(body.id || "").trim();
    if (!id) {
      return sendJson(res, 400, {
        ok: false,
        error: "Link id is required"
      });
    }

    const links = readLinks();
    const nextLinks = links.filter((link) => link.id !== id);
    if (nextLinks.length === links.length) {
      return sendJson(res, 404, {
        ok: false,
        error: "Link not found"
      });
    }

    await writeLinks(nextLinks);
    sendJson(res, 200, {
      ok: true,
      links: nextLinks,
      message: "Link deleted"
    });
  } catch (error) {
    sendJson(res, 400, {
      ok: false,
      error: error.message || "Could not delete link"
    });
  }
}

async function handleHealth(res) {
  try {
    const result = await executeWithReconnect(async (dbConnection) => {
      return dbConnection.execute("select user as username from dual");
    });
    sendJson(res, 200, {
      ok: true,
      username: result.rows[0].USERNAME,
      connectionName: getActiveDatabaseConnectionName(),
      profileName: defaultProfile,
      teamName: defaultTeam
    });
  } catch (error) {
    sendJson(res, 503, {
      ok: false,
      error: "Database connection failed",
      detail: error.message,
      config: getPublicConfig(false)
    });
  }
}

async function handleMcpTest(req, res) {
  const body = await readJson(req);
  const action = String(body.action || "natural_language").trim();
  const prompt = String(body.prompt || "").trim();
  const profileName = normalizeDbName(body.profileName) || defaultProfile;
  const toolName = String(body.toolName || "").trim();
  const rawArguments = String(body.argumentsJson || "{}").trim() || "{}";

  try {
    const startedAt = Date.now();
    let result;

    if (action === "natural_language") {
      if (!prompt) {
        return sendJson(res, 400, {
          ok: false,
          error: "Natural language query is required"
        });
      }

      result = await runMcpNaturalLanguageQuery({
        prompt,
        profileName
      });
    } else {
      let toolArguments;
      try {
        toolArguments = JSON.parse(rawArguments);
      } catch (error) {
        return sendJson(res, 400, {
          ok: false,
          error: `Tool arguments must be valid JSON: ${error.message}`
        });
      }

      if (action === "call_tool" && !toolName) {
        return sendJson(res, 400, {
          ok: false,
          error: "Tool name is required for tool calls"
        });
      }

      result = await runMcpTest({
        action,
        toolName,
        toolArguments
      });
    }

    sendJson(res, 200, {
      ok: true,
      elapsedMs: Date.now() - startedAt,
      ...result
    });
  } catch (error) {
    sendJson(res, 500, {
      ok: false,
      error: "MCP request failed",
      detail: error.message
    });
  }
}

async function handleAiAgents(res) {
  try {
    const metadata = await executeWithReconnect(async (dbConnection) => {
      const teams = await queryMetadataView(dbConnection, "USER_AI_AGENT_TEAMS", [
        "TEAM_NAME",
        "AGENT_TEAM_NAME",
        "STATUS",
        "DESCRIPTION",
        "CREATED",
        "CREATED_ON",
        "LAST_MODIFIED",
        "UPDATED_ON"
      ]);
      const agents = await queryMetadataView(dbConnection, "USER_AI_AGENTS", [
        "AGENT_NAME",
        "STATUS",
        "DESCRIPTION",
        "CREATED",
        "CREATED_ON",
        "LAST_MODIFIED",
        "UPDATED_ON"
      ]);

      return { teams, agents };
    });

    sendJson(res, 200, {
      ok: true,
      defaultTeam,
      ...metadata
    });
  } catch (error) {
    sendJson(res, 500, {
      ok: false,
      error: "Could not load AI agent metadata",
      detail: error.message
    });
  }
}

async function handleAiManager(res) {
  try {
    const manager = await executeWithReconnect(async (dbConnection) => {
      const tools = await queryMetadataView(dbConnection, "USER_AI_AGENT_TOOLS", [
        "TOOL_NAME",
        "STATUS",
        "DESCRIPTION",
        "CREATED",
        "CREATED_ON",
        "LAST_MODIFIED",
        "UPDATED_ON"
      ]);
      const tasks = await queryMetadataView(dbConnection, "USER_AI_AGENT_TASKS", [
        "TASK_NAME",
        "STATUS",
        "DESCRIPTION",
        "CREATED",
        "CREATED_ON",
        "LAST_MODIFIED",
        "UPDATED_ON"
      ]);
      const agents = await queryMetadataView(dbConnection, "USER_AI_AGENTS", [
        "AGENT_NAME",
        "STATUS",
        "DESCRIPTION",
        "CREATED",
        "CREATED_ON",
        "LAST_MODIFIED",
        "UPDATED_ON"
      ]);
      const teams = await queryMetadataView(dbConnection, "USER_AI_AGENT_TEAMS", [
        "TEAM_NAME",
        "AGENT_TEAM_NAME",
        "STATUS",
        "DESCRIPTION",
        "CREATED",
        "CREATED_ON",
        "LAST_MODIFIED",
        "UPDATED_ON"
      ]);
      const profiles = await queryFirstAvailableMetadataView(dbConnection, [
        "USER_CLOUD_AI_PROFILES",
        "USER_DBMS_CLOUD_AI_PROFILES"
      ], [
        "PROFILE_NAME",
        "STATUS",
        "DESCRIPTION",
        "CREATED",
        "CREATED_ON",
        "LAST_MODIFIED",
        "UPDATED_ON"
      ]);
      const ragProfiles = filterProfileMetadata(profiles, true);
      const selectProfiles = filterProfileMetadata(profiles, false);

      return { tools, tasks, agents, teams, selectProfiles, ragProfiles };
    });

    sendJson(res, 200, {
      ok: true,
      ...manager
    });
  } catch (error) {
    sendJson(res, 500, {
      ok: false,
      error: "Could not load AI manager metadata",
      detail: error.message
    });
  }
}

async function handleDeleteAiManagerItem(req, res) {
  const body = await readJson(req);
  const itemType = normalizeManagerItemType(body.itemType);
  const itemName = normalizeDbName(body.itemName);

  if (!itemType || !itemName) {
    return sendJson(res, 400, {
      ok: false,
      error: "Valid itemType and itemName are required"
    });
  }
  try {
    await executeWithReconnect(async (dbConnection) => {
      return dbConnection.execute(getManagerDropSql(itemType), { item_name: itemName });
    });

    sendJson(res, 200, {
      ok: true,
      itemType,
      itemName,
      status: `${itemName} is dropped/deleted of type ${itemType}.`
    });
  } catch (error) {
    sendJson(res, 500, {
      ok: false,
      error: `Could not delete ${itemType}`,
      detail: error.message
    });
  }
}

async function handleCreateAiBuilderItem(req, res) {
  const body = await readJson(req);
  const itemType = normalizeBuilderItemType(body.itemType);
  let itemName = "";
  try {
    itemName = normalizeDbName(body.name);
  } catch (error) {
    return sendJson(res, 400, {
      ok: false,
      error: error.message,
      detail: "Use a valid Oracle object name: start with a letter and use only letters, numbers, underscore (_), dollar sign ($), or hash (#). Hyphens are not valid."
    });
  }
  const description = String(body.description || "").trim();
  const attributes = String(body.attributes || "").trim();

  if (!itemType || !itemName || !attributes) {
    return sendJson(res, 400, {
      ok: false,
      error: "Item type, name, and attributes JSON are required"
    });
  }

  try {
    JSON.parse(attributes);
  } catch (error) {
    return sendJson(res, 400, {
      ok: false,
      error: `Attributes must be valid JSON: ${error.message}`
    });
  }

  try {
    await executeWithReconnect(async (dbConnection) => {
      await dbConnection.execute(getBuilderCreateSql(itemType), {
        item_name: itemName,
        attributes: { val: attributes, type: oracledb.CLOB, dir: oracledb.BIND_IN },
        description
      });
      await dbConnection.commit();
    });

    sendJson(res, 200, {
      ok: true,
      itemType,
      itemName,
      status: `${formatBuilderItemType(itemType)} "${itemName}" was added successfully.`
    });
  } catch (error) {
    sendJson(res, 500, {
      ok: false,
      error: `Could not create ${itemType}`,
      detail: error.message
    });
  }
}

function formatBuilderItemType(itemType) {
  return {
    Tool: "AI Tool",
    Task: "AI Task",
    Agent: "AI Agent",
    Team: "AI Team",
    SelectProfile: "Select AI Profile",
    RagProfile: "RAG Profile"
  }[itemType] || itemType;
}

async function handleAiTopology(res) {
  try {
    const topology = await executeWithReconnect(async (dbConnection) => {
      const teams = await queryMetadataView(dbConnection, "USER_AI_AGENT_TEAMS", [
        "TEAM_NAME",
        "AGENT_TEAM_NAME",
        "AGENT_NAME",
        "TASK_NAME",
        "ATTRIBUTES",
        "DESCRIPTION",
        "STATUS",
        "CREATED",
        "LAST_MODIFIED"
      ]);
      const teamAttributes = await queryFirstAvailableMetadataView(dbConnection, [
        "USER_AI_AGENT_TEAM_ATTRIBUTES",
        "USER_AI_AGENT_TEAMS_ATTRIBUTES"
      ], [
        "TEAM_NAME",
        "AGENT_TEAM_NAME",
        "ATTRIBUTE_NAME",
        "ATTRIBUTE_VALUE",
        "VALUE"
      ]);
      const agents = await queryMetadataView(dbConnection, "USER_AI_AGENTS", [
        "AGENT_NAME",
        "ATTRIBUTES",
        "DESCRIPTION",
        "STATUS",
        "CREATED",
        "LAST_MODIFIED"
      ]);
      const agentAttributes = await queryFirstAvailableMetadataView(dbConnection, [
        "USER_AI_AGENT_ATTRIBUTES",
        "USER_AI_AGENTS_ATTRIBUTES"
      ], [
        "AGENT_NAME",
        "ATTRIBUTE_NAME",
        "ATTRIBUTE_VALUE",
        "VALUE"
      ]);
      const tasks = await queryMetadataView(dbConnection, "USER_AI_AGENT_TASKS", [
        "TASK_NAME",
        "ATTRIBUTES",
        "DESCRIPTION",
        "STATUS",
        "CREATED",
        "LAST_MODIFIED"
      ]);
      const taskAttributes = await queryFirstAvailableMetadataView(dbConnection, [
        "USER_AI_AGENT_TASK_ATTRIBUTES",
        "USER_AI_AGENT_TASKS_ATTRIBUTES"
      ], [
        "TASK_NAME",
        "ATTRIBUTE_NAME",
        "ATTRIBUTE_VALUE",
        "VALUE"
      ]);
      const tools = await queryMetadataView(dbConnection, "USER_AI_AGENT_TOOLS", [
        "TOOL_NAME",
        "ATTRIBUTES",
        "DESCRIPTION",
        "STATUS",
        "CREATED",
        "LAST_MODIFIED"
      ]);
      const toolAttributes = await queryFirstAvailableMetadataView(dbConnection, [
        "USER_AI_AGENT_TOOL_ATTRIBUTES",
        "USER_AI_AGENT_TOOLS_ATTRIBUTES"
      ], [
        "TOOL_NAME",
        "ATTRIBUTE_NAME",
        "ATTRIBUTE_VALUE",
        "VALUE"
      ]);

      return {
        teams: mergeAiObjectAttributes(teams, teamAttributes, ["TEAM_NAME", "AGENT_TEAM_NAME"]),
        agents: mergeAiObjectAttributes(agents, agentAttributes, ["AGENT_NAME"]),
        tasks: mergeAiObjectAttributes(tasks, taskAttributes, ["TASK_NAME"]),
        tools: mergeAiObjectAttributes(tools, toolAttributes, ["TOOL_NAME"])
      };
    });

    sendJson(res, 200, {
      ok: true,
      defaultTeam,
      ...topology
    });
  } catch (error) {
    sendJson(res, 500, {
      ok: false,
      error: "Could not load AI topology metadata",
      detail: error.message
    });
  }
}

async function handleSelectAiProfiles(res) {
  try {
    const profiles = await executeWithReconnect(async (dbConnection) => {
      return queryFirstAvailableMetadataView(dbConnection, [
        "USER_CLOUD_AI_PROFILES",
        "USER_DBMS_CLOUD_AI_PROFILES"
      ], [
        "PROFILE_NAME",
        "STATUS",
        "DESCRIPTION",
        "ATTRIBUTES",
        "CREATED",
        "CREATED_ON",
        "LAST_MODIFIED",
        "UPDATED_ON"
      ]);
    });

    sendJson(res, 200, {
      ok: true,
      defaultProfile,
      profiles
    });
  } catch (error) {
    sendJson(res, 500, {
      ok: false,
      error: "Could not load Select AI profiles",
      detail: error.message
    });
  }
}

async function handleLatestTeamTaskExecution(req, res) {
  const body = await readJson(req);
  const teamName = normalizeDbName(body.teamName) || defaultTeam;
  try {
    const startedAt = Date.now();
    const result = await executeWithReconnect(async (dbConnection) => {
      return dbConnection.execute(
        `with latest_team as (
           select team_exec_id, team_name, start_date
             from user_ai_agent_team_history
            where upper(team_name) = upper(:team_name)
            order by start_date desc
            fetch first 1 row only
         ),
         latest_task as (
           select team_exec_id,
                  task_name,
                  agent_name,
                  conversation_params,
                  start_date,
                  row_number() over (
                    partition by team_exec_id, task_name, agent_name
                    order by start_date desc
                  ) as rn
             from user_ai_agent_task_history
            where upper(team_name) = upper(:team_name)
         )
         select team.team_name,
                task.task_name,
                task.agent_name,
                p.prompt,
                p.prompt_response
           from latest_team team
           join latest_task task
             on team.team_exec_id = task.team_exec_id
            and task.rn = 1
           left join user_cloud_ai_conversation_prompts p
             on p.conversation_id = json_value(task.conversation_params, '$.conversation_id')
          order by task.start_date desc nulls last,
                   p.created desc nulls last`,
        { team_name: teamName }
      );
    });

    sendJson(res, 200, {
      ok: true,
      teamName,
      elapsedMs: Date.now() - startedAt,
      columns: (result.metaData || []).map((column) => column.name),
      rows: (result.rows || []).map(normalizeMetadataRow)
    });
  } catch (error) {
    sendJson(res, 500, {
      ok: false,
      error: "Latest team task execution failed",
      detail: error.message
    });
  }
}

async function handleUserPrompts(url, res) {
  const limit = clampNumber(url.searchParams.get("limit"), 10, 1, 50);
  const offset = clampNumber(url.searchParams.get("offset"), 0, 0, 1000000);
  try {
    const prompts = await executeWithReconnect(async (dbConnection) => {
      return queryUserPromptHistory(dbConnection, { limit, offset });
    });

    sendJson(res, 200, {
      ok: true,
      limit,
      offset,
      prompts
    });
  } catch (error) {
    sendJson(res, 500, {
      ok: false,
      error: "Could not load user prompts",
      detail: error.message
    });
  }
}

async function handleMemoryTable(url, res) {
  const limit = clampNumber(url.searchParams.get("limit"), 10, 1, 50);
  const offset = clampNumber(url.searchParams.get("offset"), 0, 0, 1000000);
  const rawTableName = String(process.env.MEMORY_TABLE || "").trim();

  if (!rawTableName) {
    return sendJson(res, 400, {
      ok: false,
      error: "MEMORY_TABLE is not configured in .env"
    });
  }

  let tableName;
  try {
    tableName = normalizeDbName(rawTableName);
  } catch (error) {
    return sendJson(res, 400, {
      ok: false,
      error: error.message
    });
  }

  try {
    const memory = await executeWithReconnect(async (dbConnection) => {
      return queryMemoryTable(dbConnection, { tableName, limit, offset });
    });

    sendJson(res, 200, {
      ok: true,
      limit,
      offset,
      memory
    });
  } catch (error) {
    sendJson(res, 500, {
      ok: false,
      error: "Could not load memory table",
      detail: error.message
    });
  }
}

async function handleRag(res) {
  try {
    const rag = await executeWithReconnect(async (dbConnection) => {
      const pipelines = await queryMetadataView(dbConnection, "USER_CLOUD_PIPELINES", [
        "PIPELINE_NAME",
        "STATUS",
        "PIPELINE_TYPE",
        "DESCRIPTION",
        "CREATED",
        "LAST_MODIFIED"
      ]);
      const attributes = await queryMetadataView(dbConnection, "USER_CLOUD_PIPELINE_ATTRIBUTES", [
        "PIPELINE_NAME",
        "ATTRIBUTE_NAME",
        "ATTRIBUTE_VALUE",
        "STATUS",
        "CREATED",
        "LAST_MODIFIED"
      ]);
      const objects = await queryCloudStorageObjects(dbConnection);
      const history = await querySqlSection(
        dbConnection,
        "USER_CLOUD_PIPELINE_HISTORY",
        `select pipeline_id,
                pipeline_name,
                pipeline_type,
                job_id,
                job_name,
                status,
                start_date,
                end_date,
                instance_id,
                session_id,
                error_number,
                error_message,
                job_output
           from user_cloud_pipeline_history
          order by 1 desc
          fetch first 10 rows only`
      );

      return { pipelines, attributes, objects, history };
    });

    sendJson(res, 200, {
      ok: true,
      storageLocation: process.env.OCI_STORAGE_LOCATION || "",
      ...rag
    });
  } catch (error) {
    sendJson(res, 500, {
      ok: false,
      error: "Could not load RAG metadata",
      detail: error.message
    });
  }
}

function handleMarkdownUploadConfig(res) {
  const storageLocation = String(process.env.OCI_STORAGE_LOCATION || "").trim();
  let target = null;
  let error = "";

  if (storageLocation) {
    try {
      target = parseOciStorageLocation(storageLocation);
    } catch (parseError) {
      error = parseError.message;
    }
  } else {
    error = "OCI_STORAGE_LOCATION is not configured";
  }

  sendJson(res, 200, {
    ok: true,
    storageLocation,
    target: target ? {
      namespaceName: target.namespaceName,
      bucketName: target.bucketName,
      objectPrefix: target.objectPrefix,
      objectPattern: target.objectPattern
    } : null,
    error
  });
}

async function handleReports(res) {
  try {
    const { files, folders } = await listReportEntries();
    sendJson(res, 200, {
      ok: true,
      root: "Reports",
      folders,
      files
    });
  } catch (error) {
    sendJson(res, 500, {
      ok: false,
      error: "Could not load reports",
      detail: error.message
    });
  }
}

function handleReportFile(url, res) {
  let reportPath;
  try {
    reportPath = safeReportFilePath(url.searchParams.get("path") || "");
  } catch (error) {
    return sendJson(res, 400, {
      ok: false,
      error: error.message
    });
  }

  fs.stat(reportPath, (error, stats) => {
    if (error || !stats.isFile()) {
      return sendJson(res, 404, {
        ok: false,
        error: "Report file not found"
      });
    }

    const filename = path.basename(reportPath).replaceAll('"', "");
    res.writeHead(200, {
      "Content-Type": reportContentType(reportPath),
      "Content-Length": stats.size,
      "Content-Disposition": `inline; filename="${filename}"`,
      "Cache-Control": "no-store",
      "X-Content-Type-Options": "nosniff"
    });
    fs.createReadStream(reportPath).pipe(res);
  });
}

async function handleRenameReport(req, res) {
  try {
    const body = await readJson(req);
    const currentPath = String(body.path || "");
    const currentFilePath = safeReportFilePath(currentPath);
    const newName = normalizeReportFilename(body.newName, currentFilePath);
    const targetFilePath = path.join(path.dirname(currentFilePath), newName);
    const reportsRoot = path.normalize(reportsDir);
    const normalizedTarget = path.normalize(targetFilePath);

    if (normalizedTarget !== reportsRoot && !normalizedTarget.startsWith(reportsRoot + path.sep)) {
      return sendJson(res, 400, {
        ok: false,
        error: "Report path is outside the Reports folder"
      });
    }

    if (normalizedTarget === currentFilePath) {
      const relativePath = path.relative(reportsDir, normalizedTarget).split(path.sep).join("/");
      return sendJson(res, 200, {
        ok: true,
        path: relativePath,
        message: "Report filename unchanged"
      });
    }

    if (fs.existsSync(normalizedTarget)) {
      return sendJson(res, 409, {
        ok: false,
        error: "A report with that filename already exists"
      });
    }

    await fs.promises.rename(currentFilePath, normalizedTarget);
    const relativePath = path.relative(reportsDir, normalizedTarget).split(path.sep).join("/");
    sendJson(res, 200, {
      ok: true,
      path: relativePath,
      name: path.basename(relativePath),
      message: "Report renamed"
    });
  } catch (error) {
    sendJson(res, 400, {
      ok: false,
      error: error.message || "Could not rename report"
    });
  }
}

async function handleDeleteReport(req, res) {
  try {
    const body = await readJson(req);
    const reportPath = safeReportFilePath(body.path || "");
    const stats = await fs.promises.stat(reportPath);
    if (!stats.isFile()) {
      return sendJson(res, 400, {
        ok: false,
        error: "Report path is not a file"
      });
    }

    await fs.promises.unlink(reportPath);
    sendJson(res, 200, {
      ok: true,
      message: "Report deleted"
    });
  } catch (error) {
    sendJson(res, 400, {
      ok: false,
      error: error.message || "Could not delete report"
    });
  }
}

async function handleSaveHtmlReport(req, res) {
  try {
    const body = await readJson(req);
    const html = String(body.html || "");
    if (!html.trim()) {
      return sendJson(res, 400, {
        ok: false,
        error: "HTML report content is required"
      });
    }

    const filename = normalizeNewHtmlReportFilename(body.filename);
    const targetFolder = String(body.folder || "");
    const targetDir = safeReportFolderPath(targetFolder);
    await fs.promises.mkdir(targetDir, { recursive: true });
    const targetPath = await uniqueReportPath(path.join(targetDir, filename));
    await fs.promises.writeFile(targetPath, html, "utf8");

    const relativePath = path.relative(reportsDir, targetPath).split(path.sep).join("/");
    sendJson(res, 200, {
      ok: true,
      path: relativePath,
      name: path.basename(relativePath),
      url: `/api/reports/file?path=${encodeURIComponent(relativePath)}`,
      message: "HTML report saved"
    });
  } catch (error) {
    sendJson(res, 400, {
      ok: false,
      error: error.message || "Could not save HTML report"
    });
  }
}

async function handleCreateReportFolder(req, res) {
  try {
    const body = await readJson(req);
    const parentPath = String(body.parent || "");
    const folderName = normalizeReportFolderName(body.name);
    const parentFolder = safeReportFolderPath(parentPath);
    const folderPath = safeReportFolderPath(path.join(parentPath, folderName));

    if (!fs.existsSync(parentFolder)) {
      return sendJson(res, 404, {
        ok: false,
        error: "Parent folder not found"
      });
    }
    if (fs.existsSync(folderPath)) {
      return sendJson(res, 409, {
        ok: false,
        error: "A folder with that name already exists"
      });
    }

    await fs.promises.mkdir(folderPath, { recursive: false });
    const relativePath = path.relative(reportsDir, folderPath).split(path.sep).join("/");
    sendJson(res, 200, {
      ok: true,
      path: relativePath,
      name: path.basename(relativePath),
      message: "Folder created"
    });
  } catch (error) {
    sendJson(res, 400, {
      ok: false,
      error: error.message || "Could not create folder"
    });
  }
}

async function handleRenameReportFolder(req, res) {
  try {
    const body = await readJson(req);
    const currentPath = String(body.path || "");
    if (!currentPath.trim()) {
      return sendJson(res, 400, {
        ok: false,
        error: "Select a folder under Reports to rename"
      });
    }

    const currentFolderPath = safeReportFolderPath(currentPath);
    const stats = await fs.promises.stat(currentFolderPath);
    if (!stats.isDirectory()) {
      return sendJson(res, 400, {
        ok: false,
        error: "Report folder path is not a folder"
      });
    }

    const newName = normalizeReportFolderName(body.newName);
    const targetFolderPath = path.join(path.dirname(currentFolderPath), newName);
    const reportsRoot = path.normalize(reportsDir);
    const normalizedTarget = path.normalize(targetFolderPath);

    if (normalizedTarget === reportsRoot || !normalizedTarget.startsWith(reportsRoot + path.sep)) {
      return sendJson(res, 400, {
        ok: false,
        error: "Report folder is outside the Reports folder"
      });
    }

    const relativePath = path.relative(reportsDir, normalizedTarget).split(path.sep).join("/");
    if (normalizedTarget === currentFolderPath) {
      return sendJson(res, 200, {
        ok: true,
        path: relativePath,
        message: "Folder name unchanged"
      });
    }

    if (fs.existsSync(normalizedTarget)) {
      return sendJson(res, 409, {
        ok: false,
        error: "A folder with that name already exists"
      });
    }

    await fs.promises.rename(currentFolderPath, normalizedTarget);
    sendJson(res, 200, {
      ok: true,
      path: relativePath,
      oldPath: currentPath.replaceAll("\\", "/").replace(/^\/+|\/+$/g, ""),
      name: path.basename(relativePath),
      message: "Folder renamed"
    });
  } catch (error) {
    sendJson(res, 400, {
      ok: false,
      error: error.message || "Could not rename folder"
    });
  }
}

async function handleDeleteReportFolder(req, res) {
  try {
    const body = await readJson(req);
    const folderPathInput = String(body.path || "");
    if (!folderPathInput.trim()) {
      return sendJson(res, 400, {
        ok: false,
        error: "Select a folder under Reports to delete"
      });
    }

    const folderPath = safeReportFolderPath(folderPathInput);
    const reportsRoot = path.normalize(reportsDir);
    if (path.normalize(folderPath) === reportsRoot) {
      return sendJson(res, 400, {
        ok: false,
        error: "The Reports folder cannot be deleted"
      });
    }

    const stats = await fs.promises.stat(folderPath);
    if (!stats.isDirectory()) {
      return sendJson(res, 400, {
        ok: false,
        error: "Report folder path is not a folder"
      });
    }

    await fs.promises.rm(folderPath, { recursive: true, force: false });
    sendJson(res, 200, {
      ok: true,
      path: folderPathInput.replaceAll("\\", "/").replace(/^\/+|\/+$/g, ""),
      message: "Folder deleted"
    });
  } catch (error) {
    sendJson(res, 400, {
      ok: false,
      error: error.message || "Could not delete folder"
    });
  }
}

async function handleMoveReport(req, res) {
  try {
    const body = await readJson(req);
    const currentPath = String(body.path || "");
    const targetFolderPath = String(body.targetFolder || "");
    const currentFilePath = safeReportFilePath(currentPath);
    const targetFolder = safeReportFolderPath(targetFolderPath);
    const stats = await fs.promises.stat(targetFolder);

    if (!stats.isDirectory()) {
      return sendJson(res, 400, {
        ok: false,
        error: "Target path is not a folder"
      });
    }

    const targetPath = path.join(targetFolder, path.basename(currentFilePath));
    if (path.normalize(targetPath) === path.normalize(currentFilePath)) {
      const relativePath = path.relative(reportsDir, currentFilePath).split(path.sep).join("/");
      return sendJson(res, 200, {
        ok: true,
        path: relativePath,
        message: "Report already in that folder"
      });
    }
    if (fs.existsSync(targetPath)) {
      return sendJson(res, 409, {
        ok: false,
        error: "A report with that filename already exists in the target folder"
      });
    }

    await fs.promises.rename(currentFilePath, targetPath);
    const relativePath = path.relative(reportsDir, targetPath).split(path.sep).join("/");
    sendJson(res, 200, {
      ok: true,
      path: relativePath,
      name: path.basename(relativePath),
      message: "Report moved"
    });
  } catch (error) {
    sendJson(res, 400, {
      ok: false,
      error: error.message || "Could not move report"
    });
  }
}

async function listReportEntries() {
  if (!fs.existsSync(reportsDir)) {
    return { files: [], folders: [] };
  }

  const files = [];
  const folders = [];

  async function walk(directory) {
    const entries = await fs.promises.readdir(directory, { withFileTypes: true });
    for (const entry of entries) {
      const fullPath = path.join(directory, entry.name);
      if (entry.isDirectory()) {
        const stats = await fs.promises.stat(fullPath);
        const relativePath = path.relative(reportsDir, fullPath).split(path.sep).join("/");
        folders.push({
          name: entry.name,
          path: relativePath,
          modifiedAt: stats.mtime.toISOString()
        });
        await walk(fullPath);
      } else if (entry.isFile() && isReportFile(entry.name)) {
        const stats = await fs.promises.stat(fullPath);
        const relativePath = path.relative(reportsDir, fullPath).split(path.sep).join("/");
        const folder = path.dirname(relativePath) === "." ? "" : path.dirname(relativePath).split(path.sep).join("/");
        const extension = path.extname(entry.name).toLowerCase().replace(".", "");
        files.push({
          name: entry.name,
          path: relativePath,
          folder,
          type: extension,
          size: stats.size,
          modifiedAt: stats.mtime.toISOString(),
          url: `/api/reports/file?path=${encodeURIComponent(relativePath)}`
        });
      }
    }
  }

  await walk(reportsDir);
  files.sort((left, right) => left.path.localeCompare(right.path));
  folders.sort((left, right) => left.path.localeCompare(right.path));
  return { files, folders };
}

function safeReportFilePath(relativePath) {
  const normalizedInput = String(relativePath || "").replaceAll("\\", "/").replace(/^\/+/, "");
  if (!normalizedInput || !isReportFile(normalizedInput)) {
    throw new Error("A PDF or HTML report path is required");
  }

  const filePath = path.normalize(path.join(reportsDir, normalizedInput));
  const reportsRoot = path.normalize(reportsDir);
  if (filePath !== reportsRoot && !filePath.startsWith(reportsRoot + path.sep)) {
    throw new Error("Report path is outside the Reports folder");
  }
  return filePath;
}

function safeReportFolderPath(relativePath) {
  const normalizedInput = String(relativePath || "").replaceAll("\\", "/").replace(/^\/+|\/+$/g, "");
  if (normalizedInput.split("/").some((segment) => segment === "." || segment === "..")) {
    throw new Error("Invalid report folder path");
  }

  const folderPath = path.normalize(path.join(reportsDir, normalizedInput));
  const reportsRoot = path.normalize(reportsDir);
  if (folderPath !== reportsRoot && !folderPath.startsWith(reportsRoot + path.sep)) {
    throw new Error("Report folder is outside the Reports folder");
  }
  return folderPath;
}

function isReportFile(filePath) {
  return [".pdf", ".html", ".htm"].includes(path.extname(String(filePath || "")).toLowerCase());
}

function normalizeReportFilename(value, currentFilePath) {
  let filename = String(value || "").trim();
  if (!filename) {
    throw new Error("New filename is required");
  }
  if (filename.includes("/") || filename.includes("\\") || filename !== path.basename(filename)) {
    throw new Error("Enter a filename only, not a folder path");
  }
  if (filename === "." || filename === ".." || filename.length > 180) {
    throw new Error("Invalid report filename");
  }

  if (!path.extname(filename)) {
    filename += path.extname(currentFilePath);
  }
  if (!isReportFile(filename)) {
    throw new Error("Report filename must end with .pdf, .html, or .htm");
  }
  return filename;
}

function normalizeNewHtmlReportFilename(value) {
  let filename = String(value || "").trim();
  if (!filename) {
    filename = `AI_Agent_Report_${new Date().toISOString().slice(0, 19).replace(/[T:]/g, "-")}.html`;
  }
  if (filename.includes("/") || filename.includes("\\") || filename !== path.basename(filename)) {
    throw new Error("Enter a filename only, not a folder path");
  }
  filename = filename.replace(/[^A-Za-z0-9._ -]+/g, "_").replace(/\s+/g, "_").replace(/^_+|_+$/g, "");
  if (!path.extname(filename)) {
    filename += ".html";
  }
  if (![".html", ".htm"].includes(path.extname(filename).toLowerCase())) {
    throw new Error("Saved report filename must end with .html or .htm");
  }
  if (filename === "." || filename === ".." || filename.length > 180) {
    throw new Error("Invalid report filename");
  }
  return filename;
}

function normalizeReportFolderName(value) {
  let folderName = String(value || "").trim();
  if (!folderName) {
    throw new Error("Folder name is required");
  }
  if (folderName.includes("/") || folderName.includes("\\") || folderName !== path.basename(folderName)) {
    throw new Error("Enter a folder name only, not a path");
  }
  folderName = folderName.replace(/[^A-Za-z0-9._ -]+/g, "_").replace(/\s+/g, " ").replace(/^_+|_+$/g, "");
  if (!folderName || folderName === "." || folderName === ".." || folderName.length > 120) {
    throw new Error("Invalid folder name");
  }
  return folderName;
}

async function uniqueReportPath(filePath) {
  const parsed = path.parse(filePath);
  let candidate = filePath;
  let suffix = 1;
  while (fs.existsSync(candidate)) {
    candidate = path.join(parsed.dir, `${parsed.name}_${suffix}${parsed.ext}`);
    suffix += 1;
  }
  return candidate;
}

function reportContentType(filePath) {
  const ext = path.extname(filePath).toLowerCase();
  if (ext === ".pdf") {
    return "application/pdf";
  }
  return "text/html; charset=utf-8";
}

async function handleMarkdownUpload(req, res) {
  try {
    const form = await readMultipartForm(req, {
      maxBytes: Number(process.env.MARKDOWN_UPLOAD_MAX_BYTES || 10 * 1024 * 1024)
    });
    const file = form.files.file || form.files.markdownFile || Object.values(form.files)[0];
    if (!file || !file.filename) {
      return sendJson(res, 400, {
        ok: false,
        error: "Select a knowledge-base file to upload"
      });
    }

    const result = await uploadKnowledgeFileToRag(file);

    sendJson(res, 200, {
      ok: true,
      ...result
    });
  } catch (error) {
    sendJson(res, 500, {
      ok: false,
      error: "Could not upload knowledge-base file",
      detail: error.message
    });
  }
}

async function handleUploadReportToRag(req, res) {
  try {
    const body = await readJson(req);
    const reportPath = safeReportFilePath(body.path || "");
    const content = await fs.promises.readFile(reportPath);
    const result = await uploadKnowledgeFileToRag({
      filename: path.basename(reportPath),
      content
    });

    sendJson(res, 200, {
      ok: true,
      reportPath: path.relative(reportsDir, reportPath).split(path.sep).join("/"),
      ...result
    });
  } catch (error) {
    sendJson(res, 500, {
      ok: false,
      error: "Could not upload selected report to RAG",
      detail: error.message
    });
  }
}

function handleAskStatus(url, res, currentUser) {
  cleanupAskRequestStatuses();
  const requestId = normalizeAskRequestId(url.searchParams.get("requestId"));
  if (!requestId) {
    return sendJson(res, 400, {
      ok: false,
      error: "requestId is required"
    });
  }

  const status = askRequestStatuses.get(requestId);
  if (!status) {
    return sendJson(res, 404, {
      ok: false,
      error: "No status found for this request"
    });
  }

  if (status.username && currentUser && status.username !== currentUser.username && !isAdmin(currentUser)) {
    return sendForbidden(res);
  }

  sendJson(res, 200, {
    ok: true,
    requestId,
    status: status.status,
    stage: status.stage,
    completed: Boolean(status.completed),
    error: status.error || "",
    elapsedMs: status.elapsedMs,
    updatedAt: status.updatedAt
  });
}

function normalizeAskRequestId(value) {
  const requestId = String(value || "").trim();
  return /^[A-Za-z0-9._:-]{8,128}$/.test(requestId) ? requestId : "";
}

function setAskRequestStatus(requestId, currentUser, status, options = {}) {
  if (!requestId) {
    return;
  }

  cleanupAskRequestStatuses();
  askRequestStatuses.set(requestId, {
    username: currentUser && currentUser.username || "",
    status: String(status || "").trim() || "Running",
    stage: String(options.stage || "").trim(),
    completed: Boolean(options.completed),
    error: String(options.error || "").trim(),
    elapsedMs: Number.isFinite(Number(options.elapsedMs)) ? Number(options.elapsedMs) : null,
    updatedAt: new Date().toISOString(),
    expiresAt: Date.now() + askRequestStatusTtlMs
  });
}

function cleanupAskRequestStatuses() {
  const now = Date.now();
  for (const [requestId, status] of askRequestStatuses.entries()) {
    if (!status || Number(status.expiresAt) <= now) {
      askRequestStatuses.delete(requestId);
    }
  }
}

async function handleAsk(req, res, currentUser) {
  const body = await readJson(req);
  const prompt = String(body.prompt || "").trim();
  const llmInstructionName = normalizeLlmInstructionName(body.llmInstructionName);
  let llmInstructions = normalizeLlmInstructions(body.llmInstructions);
  const mode = body.mode === "select-ai" ? "select-ai" : "agent";
  const profileName = normalizeDbName(body.profileName) || defaultProfile;
  const teamName = normalizeDbName(body.teamName) || defaultTeam;
  const llmName = String(body.llmName || "").trim();
  const requestId = normalizeAskRequestId(body.requestId);
  const updateStatus = (status, options = {}) => setAskRequestStatus(requestId, currentUser, status, options);

  if (!prompt) {
    return sendJson(res, 400, { error: "Prompt is required" });
  }
  if (llmName && !isAdmin(currentUser)) {
    return sendForbidden(res);
  }
  try {
    updateStatus("Preparing AI request", { stage: "handleAsk" });
    if (!llmInstructions && llmInstructionName) {
      updateStatus("Loading saved LLM instructions", { stage: "readLlmInstructionsConfig" });
      const instructionConfig = await readLlmInstructionsConfig();
      const profile = instructionConfig.profiles[llmInstructionName];
      llmInstructions = normalizeLlmInstructions(profile && profile.instructions);
    }
    const startedAt = Date.now();
    const llmConfig = llmName ? getRuntimeLlmConfig(llmName) : null;
    updateStatus("Opening database connection", { stage: "executeWithReconnect" });
    const execution = await executeWithReconnect(async (dbConnection) => {
      let queryResult;

      if (mode === "agent") {
        updateStatus(`Running DBMS_CLOUD_AI_AGENT.SET_TEAM for ${teamName}`, {
          stage: "dbms_cloud_ai_agent.set_team"
        });
        await dbConnection.execute(
          "begin dbms_cloud_ai_agent.set_team(:team_name); end;",
          { team_name: teamName }
        );
      } else {
        if (llmConfig) {
          updateStatus(`Applying Select AI LLM config: ${llmName}`, {
            stage: "applySelectAiProfileLlmConfig"
          });
          await applySelectAiProfileLlmConfig(dbConnection, profileName, llmName, llmConfig);
        }
        updateStatus(`Running DBMS_CLOUD_AI.SET_PROFILE for ${profileName}`, {
          stage: "dbms_cloud_ai.set_profile"
        });
        await dbConnection.execute(
          "begin dbms_cloud_ai.set_profile(:profile_name); end;",
          { profile_name: profileName }
        );
      }

      if (mode === "agent") {
        updateStatus(`Running DBMS_CLOUD_AI_AGENT.RUN_TEAM for ${teamName}`, {
          stage: "dbms_cloud_ai_agent.run_team"
        });
        queryResult = await dbConnection.execute(
          "select dbms_cloud_ai_agent.run_team(team_name => :team_name, user_prompt => :prompt) as response from dual",
          { team_name: teamName, prompt }
        );
      } else {
        updateStatus(`Running Select AI query for ${profileName}`, {
          stage: "select ai"
        });
        queryResult = await dbConnection.execute(`select ai ${toSqlLiteral(prompt)} as response`);
      }

      updateStatus("Formatting database response", { stage: "formatQueryResultResponse" });
      const baseResponse = formatQueryResultResponse(queryResult);
      const thirdPartySummary = shouldAppendFsiThirdPartyEvidence(mode, teamName, prompt, baseResponse)
        ? (updateStatus("Running FSI_THIRD_PARTY_FRAUD_DATA", { stage: "fsi_third_party_fraud_data" }),
          await runFsiThirdPartyEvidenceSummary(dbConnection, extractClaimIdFromPrompt(prompt)))
        : null;
      const ragSearch = shouldAppendFsiRagSearch(mode, teamName, prompt) && !hasFsiRagSearchSection(baseResponse)
        ? (updateStatus("Running DBMS_CLOUD_AI.GENERATE for RAG search", { stage: "dbms_cloud_ai.generate" }),
          await runRagSearchForPrompt(dbConnection, prompt, "fsi_select_ai_rag_kb_profile"))
        : null;

      return { queryResult, thirdPartySummary, ragSearch };
    });

    updateStatus("Preparing rendered output", { stage: "renderResponse" });
    const result = execution.queryResult;
    const baseText = formatQueryResultResponse(result);
    const textWithThirdParty = appendFsiThirdPartyEvidenceToResponse(baseText, execution.thirdPartySummary);
    const text = appendRagSearchToResponse(textWithThirdParty, execution.ragSearch);
    const llmResult = llmPostProcess
      ? (updateStatus("Rendering HTML with OCI Generative AI", { stage: "renderWithOciLlm" }),
        await renderWithOciLlm({ prompt, mode, databaseResponse: text, llmInstructions }).catch((error) => {
          return {
            ok: false,
            error: error.message,
            text: "",
            html: ""
          };
        }))
      : { ok: false, skipped: "LLM post-processing is disabled", text: "", html: "" };
    updateStatus("Completed AI response rendering", {
      stage: "complete",
      completed: true,
      elapsedMs: Date.now() - startedAt
    });

    sendJson(res, 200, {
      ok: true,
      mode,
      prompt,
      profileName,
      teamName,
      llmName,
      llmInstructionName,
      elapsedMs: Date.now() - startedAt,
      response: text,
      html: llmResult.html || extractHtml(text),
      llmResponse: llmResult.text || "",
      ragSearch: execution.ragSearch,
      llm: {
        ok: Boolean(llmResult.ok),
        endpoint: llmEndpoint,
        modelId: llmConfig && llmConfig.LLM_MODEL_ID || llmModelId,
        customInstructions: Boolean(llmInstructions),
        instructionName: llmInstructionName,
        error: llmResult.error || "",
        skipped: llmResult.skipped || ""
      },
      rows: result.rows || []
    });
  } catch (error) {
    updateStatus("AI query failed", {
      stage: "error",
      completed: true,
      error: error.message
    });
    sendJson(res, 500, {
      ok: false,
      error: "AI query failed",
      detail: error.message
    });
  }
}

async function queryFirstAvailableMetadataView(connection, viewNames, preferredColumns) {
  for (const viewName of viewNames) {
    const result = await queryMetadataView(connection, viewName, preferredColumns);
    if (result.available || result.rows.length) {
      return result;
    }
  }

  return {
    viewName: viewNames[0],
    available: false,
    columns: [],
    rows: []
  };
}

async function queryMetadataView(connection, viewName, preferredColumns) {
  let availableColumns;
  try {
    const metadataResult = await connection.execute(`select * from ${viewName} where 1 = 0`);
    availableColumns = (metadataResult.metaData || []).map((column) => column.name);
  } catch (error) {
    if (isMissingDbObjectError(error)) {
      return {
        viewName,
        available: false,
        columns: [],
        rows: []
      };
    }
    throw error;
  }

  if (!availableColumns.length) {
    return {
      viewName,
      available: false,
      columns: [],
      rows: []
    };
  }

  const preferred = preferredColumns.filter((column) => availableColumns.includes(column));
  const selectedColumns = preferred.length ? preferred : availableColumns.slice(0, 8);
  const firstNameColumn = selectedColumns.find((column) => /(^|_)NAME$/.test(column)) || selectedColumns[0];
  const sql = `select ${selectedColumns.join(", ")} from ${viewName} order by ${firstNameColumn}`;
  const result = await connection.execute(sql);

  return {
    viewName,
    available: true,
    columns: selectedColumns,
    rows: (result.rows || []).map(normalizeMetadataRow)
  };
}

function mergeAiObjectAttributes(metadata, attributeMetadata, nameColumns) {
  const rows = metadata && metadata.rows || [];
  const attributeRows = attributeMetadata && attributeMetadata.rows || [];
  if (!rows.length || !attributeRows.length) {
    return metadata;
  }

  const attributesByName = new Map();
  attributeRows.forEach((row) => {
    const objectName = firstNonEmptyValue(row, nameColumns);
    if (!objectName) {
      return;
    }

    const attributeName = firstNonEmptyValue(row, ["ATTRIBUTE_NAME", "NAME", "ATTR_NAME"]);
    const attributeValue = firstNonEmptyValue(row, ["ATTRIBUTE_VALUE", "VALUE", "ATTR_VALUE"]);
    if (!attributeName && !attributeValue) {
      return;
    }

    const key = objectName.toLowerCase();
    const attributes = attributesByName.get(key) || {};
    if (!attributeName || /^attributes$/i.test(attributeName)) {
      Object.assign(attributes, parseJsonLike(attributeValue));
    } else {
      attributes[attributeName] = parseJsonLike(attributeValue);
    }
    attributesByName.set(key, attributes);
  });

  return {
    ...metadata,
    rows: rows.map((row) => {
      const objectName = firstNonEmptyValue(row, nameColumns);
      const mergedAttributes = objectName ? attributesByName.get(objectName.toLowerCase()) : null;
      if (!mergedAttributes) {
        return row;
      }

      const existingAttributes = parseJsonLike(row.ATTRIBUTES);
      const attributes = {
        ...(existingAttributes && typeof existingAttributes === "object" && !Array.isArray(existingAttributes) ? existingAttributes : {}),
        ...mergedAttributes
      };

      return {
        ...row,
        ATTRIBUTES: JSON.stringify(attributes, null, 2)
      };
    })
  };
}

function firstNonEmptyValue(row, columns) {
  for (const column of columns) {
    const value = row && row[column];
    if (value != null && String(value).trim()) {
      return String(value).trim();
    }
  }
  return "";
}

function parseJsonLike(value) {
  const text = String(value || "").trim();
  if (!text) {
    return "";
  }
  try {
    return JSON.parse(text);
  } catch {
    return text;
  }
}

async function queryUserPromptHistory(connection, { limit, offset }) {
  const viewName = "USER_CLOUD_AI_CONVERSATION_PROMPTS";
  let availableColumns;
  try {
    const metadataResult = await connection.execute(`select * from ${viewName} where 1 = 0`);
    availableColumns = (metadataResult.metaData || []).map((column) => column.name);
  } catch (error) {
    if (isMissingDbObjectError(error)) {
      return {
        viewName,
        available: false,
        columns: [],
        rows: []
      };
    }
    throw error;
  }

  const preferredColumns = [
    "CREATED",
    "CONVERSATION_ID",
    "PROMPT"
  ];
  const selectedColumns = preferredColumns.filter((column) => availableColumns.includes(column));
  const columns = selectedColumns.length ? selectedColumns : availableColumns.slice(0, 8);
  const orderColumn = availableColumns.includes("CREATED") ? "CREATED" : columns[0];
  const countResult = await connection.execute(`select count(*) as total_count from ${viewName}`);
  const result = await connection.execute(
    `select ${columns.join(", ")}
       from ${viewName}
      order by ${orderColumn} desc nulls last
      offset :offset rows fetch next :limit rows only`,
    { offset, limit }
  );

  return {
    viewName,
    available: true,
    columns,
    total: Number(firstValue(countResult)) || 0,
    limit,
    offset,
    rows: (result.rows || []).map(normalizeMetadataRow)
  };
}

async function queryMemoryTable(connection, { tableName, limit, offset }) {
  let availableColumns;
  try {
    const metadataResult = await connection.execute(`select * from ${tableName} where 1 = 0`);
    availableColumns = (metadataResult.metaData || []).map((column) => column.name);
  } catch (error) {
    if (isMissingDbObjectError(error)) {
      return {
        viewName: tableName,
        available: false,
        columns: [],
        rows: [],
        total: 0,
        limit,
        offset
      };
    }
    throw error;
  }

  const preferredOrderColumns = [
    "CREATED_AT",
    "CREATED",
    "UPDATED_AT",
    "LAST_MODIFIED",
    "MODIFIED_AT"
  ];
  const orderColumn = preferredOrderColumns.find((column) => availableColumns.includes(column));
  const orderExpression = orderColumn ? `${orderColumn} desc nulls last` : "ora_rowscn desc";
  const countResult = await connection.execute(`select count(*) as total_count from ${tableName}`);
  const result = await connection.execute(
    `select *
       from ${tableName}
      order by ${orderExpression}
      offset :offset rows fetch next :limit rows only`,
    { offset, limit }
  );

  return {
    viewName: tableName,
    available: true,
    columns: availableColumns,
    orderColumn: orderColumn || "ORA_ROWSCN",
    total: Number(firstValue(countResult)) || 0,
    limit,
    offset,
    rows: (result.rows || []).map(normalizeMetadataRow)
  };
}

async function queryCloudStorageObjects(connection) {
  const location = String(process.env.OCI_STORAGE_LOCATION || "").trim();
  if (!location) {
    return {
      viewName: "DBMS_CLOUD.LIST_OBJECTS",
      available: false,
      error: "OCI_STORAGE_LOCATION is not configured",
      columns: [],
      rows: []
    };
  }

  return querySqlSection(
    connection,
    "DBMS_CLOUD.LIST_OBJECTS",
    "select * from dbms_cloud.list_objects(:credential_name, :location)",
    {
      credential_name: process.env.OCI_CREDENTIAL_NAME || "oci",
      location
    }
  );
}

function parseOciStorageLocation(location) {
  let parsed;
  try {
    parsed = new URL(location);
  } catch {
    throw new Error("OCI_STORAGE_LOCATION must be an Object Storage URL");
  }

  const parts = parsed.pathname.split("/").filter(Boolean).map((part) => decodeURIComponent(part));
  const namespaceIndex = parts.indexOf("n");
  const bucketIndex = parts.indexOf("b");
  const objectIndex = parts.indexOf("o");
  const namespaceName = namespaceIndex >= 0 ? parts[namespaceIndex + 1] : "";
  const bucketName = bucketIndex >= 0 ? parts[bucketIndex + 1] : "";

  if (!namespaceName || !bucketName || objectIndex < 0) {
    throw new Error("OCI_STORAGE_LOCATION must include /n/{namespace}/b/{bucket}/o/{object-prefix}");
  }

  const objectPattern = parts.slice(objectIndex + 1).join("/");
  return {
    endpoint: parsed.origin,
    namespaceName,
    bucketName,
    objectPattern,
    objectPrefix: deriveUploadObjectPrefix(objectPattern)
  };
}

function deriveUploadObjectPrefix(objectPattern) {
  if (!objectPattern) {
    return "";
  }
  if (objectPattern.endsWith("/")) {
    return objectPattern;
  }

  const wildcardIndex = objectPattern.search(/[*?\[]/);
  if (wildcardIndex >= 0) {
    const beforeWildcard = objectPattern.slice(0, wildcardIndex);
    const slashIndex = beforeWildcard.lastIndexOf("/");
    return slashIndex >= 0 ? beforeWildcard.slice(0, slashIndex + 1) : "";
  }

  const slashIndex = objectPattern.lastIndexOf("/");
  return slashIndex >= 0 ? objectPattern.slice(0, slashIndex + 1) : "";
}

function objectNameMatchesPattern(objectName, objectPattern) {
  if (!objectPattern) {
    return true;
  }

  if (!/[*?\[]/.test(objectPattern)) {
    return objectPattern.endsWith("/")
      ? objectName.startsWith(objectPattern)
      : objectName === objectPattern;
  }

  return globPatternToRegExp(objectPattern).test(objectName);
}

function globPatternToRegExp(pattern) {
  let source = "";
  for (let index = 0; index < pattern.length; index += 1) {
    const char = pattern[index];
    if (char === "*") {
      source += ".*";
    } else if (char === "?") {
      source += ".";
    } else if (char === "[") {
      const closeIndex = pattern.indexOf("]", index + 1);
      if (closeIndex > index + 1) {
        source += pattern.slice(index, closeIndex + 1);
        index = closeIndex;
      } else {
        source += "\\[";
      }
    } else {
      source += escapeRegExp(char);
    }
  }

  return new RegExp(`^${source}$`, "i");
}

function escapeRegExp(value) {
  return String(value).replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

async function rebuildRagVectorIndex(connection, uploadContext) {
  const config = getRagVectorIndexConfig();
  const tableName = `${config.indexName}$vectab`;
  const beforeCount = await getTableCount(connection, tableName);
  const startedAt = Date.now();

  await connection.execute(
    `begin
       begin
         dbms_cloud_ai.drop_vector_index(
           index_name => :index_name,
           include_data => true,
           force => true
         );
       exception
         when others then
           null;
       end;

       dbms_cloud_ai.create_vector_index(
         index_name => :index_name,
         status => 'Enabled',
         wait_for_completion => true,
         attributes => :attributes
       );
     end;`,
    {
      index_name: config.indexName,
      attributes: JSON.stringify({
        vector_db_provider: "oracle",
        location: config.location,
        object_storage_credential_name: config.objectStorageCredentialName,
        profile_name: config.profileName,
        vector_dimension: config.vectorDimension,
        vector_distance_metric: config.vectorDistanceMetric,
        chunk_overlap: config.chunkOverlap,
        chunk_size: config.chunkSize,
        refresh_rate: config.refreshRate
      })
    }
  );

  const afterCount = await getTableCount(connection, tableName);
  const history = await getLatestVectorPipelineHistory(connection, config.indexName);

  return {
    status: "completed",
    indexName: config.indexName,
    profileName: config.profileName,
    location: config.location,
    objectName: uploadContext.objectName,
    filename: uploadContext.filename,
    vectorTable: tableName,
    chunkCountBefore: beforeCount,
    chunkCountAfter: afterCount,
    chunksAdded: Math.max(0, afterCount - beforeCount),
    elapsedMs: Date.now() - startedAt,
    pipeline: history
  };
}

function getRagVectorIndexConfig() {
  return {
    indexName: normalizeDbName(process.env.RAG_VECTOR_INDEX_NAME || "dtc_hub_vector_index_kb"),
    profileName: normalizeDbName(process.env.RAG_PROFILE_NAME || "dtc_select_ai_rag_kb_profile"),
    location: String(process.env.OCI_STORAGE_LOCATION || "").trim(),
    objectStorageCredentialName: normalizeDbName(process.env.OCI_CREDENTIAL_NAME || "oci"),
    vectorDimension: clampNumber(process.env.RAG_VECTOR_DIMENSION, 1024, 1, 65535),
    vectorDistanceMetric: process.env.RAG_VECTOR_DISTANCE_METRIC || "cosine",
    chunkOverlap: clampNumber(process.env.RAG_CHUNK_OVERLAP, 128, 0, 100000),
    chunkSize: clampNumber(process.env.RAG_CHUNK_SIZE, 1024, 1, 100000),
    refreshRate: clampNumber(process.env.RAG_REFRESH_RATE, 1440, 1, 525600)
  };
}

async function getTableCount(connection, tableName) {
  try {
    const result = await connection.execute(`select count(*) as total_count from ${tableName}`);
    return Number(firstValue(result)) || 0;
  } catch (error) {
    if (isMissingDbObjectError(error)) {
      return 0;
    }
    throw error;
  }
}

async function getLatestVectorPipelineHistory(connection, indexName) {
  try {
    const result = await connection.execute(
      `select pipeline_id,
              pipeline_name,
              pipeline_type,
              status,
              start_date,
              end_date,
              error_number,
              error_message
         from user_cloud_pipeline_history
        where upper(pipeline_name) = upper(:index_name)
           or upper(pipeline_name) like upper(:index_name) || '%'
        order by start_date desc nulls last, pipeline_id desc
        fetch first 1 rows only`,
      { index_name: indexName }
    );
    return (result.rows || []).map(normalizeMetadataRow)[0] || null;
  } catch (error) {
    return {
      error: error.message
    };
  }
}

async function uploadKnowledgeFileToRag(file) {
  const storageLocation = String(process.env.OCI_STORAGE_LOCATION || "").trim();
  if (!storageLocation) {
    throw new Error("OCI_STORAGE_LOCATION is not configured");
  }

  const target = parseOciStorageLocation(storageLocation);
  const preparedFile = prepareKnowledgeUploadFile(file);
  const filename = preparedFile.filename;
  if (!filename) {
    throw new Error("Invalid knowledge-base filename");
  }

  const objectName = `${target.objectPrefix}${filename}`;
  if (!objectNameMatchesPattern(objectName, target.objectPattern)) {
    throw new Error(`The uploaded filename must match the configured RAG object pattern: ${target.objectPattern}`);
  }

  const uploadResult = await uploadMarkdownObject({
    target,
    objectName,
    body: preparedFile.content
  });
  const vectorization = await executeWithReconnect((dbConnection) => {
    return rebuildRagVectorIndex(dbConnection, { objectName, filename });
  });

  return {
    message: `Uploaded ${filename} to OCI Object Storage and completed vectorization.`,
    namespaceName: target.namespaceName,
    bucketName: target.bucketName,
    objectName,
    etag: uploadResult && uploadResult.eTag || uploadResult && uploadResult.etag || "",
    vectorization
  };
}

async function uploadMarkdownObject({ target, objectName, body }) {
  const client = getObjectStorageClient(target.endpoint);
  return client.putObject({
    namespaceName: target.namespaceName,
    bucketName: target.bucketName,
    objectName,
    contentLength: body.length,
    contentType: "text/markdown; charset=utf-8",
    putObjectBody: body
  });
}

function getObjectStorageClient(endpoint) {
  if (!objectStorageClient) {
    const common = require("oci-common");
    const objectstorage = require("oci-objectstorage");
    const { authType, configFile, profile } = getOciAuthConfig();
    let authenticationDetailsProvider;

    if (authType === "instance_principal") {
      authenticationDetailsProvider = new common.InstancePrincipalsAuthenticationDetailsProviderBuilder().build();
    } else if (authType === "resource_principal") {
      authenticationDetailsProvider = new common.ResourcePrincipalAuthenticationDetailsProvider();
    } else {
      authenticationDetailsProvider = createConfigFileAuthProvider(common, configFile, profile);
    }

    objectStorageClient = new objectstorage.ObjectStorageClient({
      authenticationDetailsProvider
    });
  }

  if (endpoint) {
    objectStorageClient.endpoint = endpoint;
  }
  return objectStorageClient;
}

function sanitizeObjectFilename(filename) {
  const baseName = path.basename(String(filename || "").replaceAll("\\", "/"));
  const cleaned = baseName.replace(/[^A-Za-z0-9._-]+/g, "_").replace(/^_+|_+$/g, "");
  if (!cleaned || cleaned === "." || cleaned === "..") {
    throw new Error("Invalid knowledge-base filename");
  }
  return cleaned;
}

function prepareKnowledgeUploadFile(file) {
  const originalName = sanitizeObjectFilename(file.filename);
  const extension = path.extname(originalName).toLowerCase();
  const baseName = path.basename(originalName, extension).slice(0, 150) || "knowledge_file";
  const text = file.content.toString("utf8");

  if ([".md", ".markdown"].includes(extension)) {
    return {
      filename: extension === ".markdown" ? `${baseName}.md` : originalName,
      content: Buffer.from(text, "utf8")
    };
  }

  if ([".html", ".htm"].includes(extension)) {
    return {
      filename: `${baseName}.md`,
      content: Buffer.from(htmlToKnowledgeMarkdown(text, originalName), "utf8")
    };
  }

  if (extension === ".txt") {
    return {
      filename: `${baseName}.md`,
      content: Buffer.from(`# ${baseName.replace(/[_-]+/g, " ")}\n\n${text.trim()}\n`, "utf8")
    };
  }

  throw new Error("Only .md, .markdown, .html, .htm, or .txt files can be uploaded for RAG indexing");
}

function htmlToKnowledgeMarkdown(html, filename) {
  const titleMatch = String(html || "").match(/<title[^>]*>([\s\S]*?)<\/title>/i);
  const title = decodeHtmlEntities(stripHtml(titleMatch && titleMatch[1] || path.basename(filename, path.extname(filename))));
  const bodyMatch = String(html || "").match(/<body[^>]*>([\s\S]*?)<\/body>/i);
  let body = bodyMatch ? bodyMatch[1] : String(html || "");
  body = body
    .replace(/<script[\s\S]*?<\/script>/gi, " ")
    .replace(/<style[\s\S]*?<\/style>/gi, " ")
    .replace(/<\/(h[1-6]|p|div|section|article|header|footer|aside|main|li|tr)>/gi, "\n")
    .replace(/<br\s*\/?>/gi, "\n")
    .replace(/<li[^>]*>/gi, "- ")
    .replace(/<th[^>]*>/gi, " ")
    .replace(/<td[^>]*>/gi, " ");

  const text = decodeHtmlEntities(stripHtml(body))
    .replace(/[ \t]+\n/g, "\n")
    .replace(/\n{3,}/g, "\n\n")
    .trim();

  return [`# ${title}`, "", text].filter(Boolean).join("\n").trim() + "\n";
}

function stripHtml(value) {
  return String(value || "").replace(/<[^>]+>/g, " ");
}

function decodeHtmlEntities(value) {
  return String(value || "")
    .replace(/&nbsp;/gi, " ")
    .replace(/&amp;/gi, "&")
    .replace(/&lt;/gi, "<")
    .replace(/&gt;/gi, ">")
    .replace(/&quot;/gi, '"')
    .replace(/&#39;/gi, "'")
    .replace(/&#(\d+);/g, (_match, code) => {
      const point = Number(code);
      return Number.isFinite(point) ? String.fromCodePoint(point) : "";
    })
    .replace(/&#x([0-9a-f]+);/gi, (_match, code) => {
      const point = Number.parseInt(code, 16);
      return Number.isFinite(point) ? String.fromCodePoint(point) : "";
    })
    .replace(/[ \t\r\f\v]+/g, " ")
    .replace(/ *\n */g, "\n")
    .trim();
}

async function querySqlSection(connection, viewName, sql, binds = {}) {
  try {
    const result = await connection.execute(sql, binds);
    return {
      viewName,
      available: true,
      columns: (result.metaData || []).map((column) => column.name),
      rows: (result.rows || []).map(normalizeMetadataRow)
    };
  } catch (error) {
    if (isMissingDbObjectError(error)) {
      return {
        viewName,
        available: false,
        columns: [],
        rows: []
      };
    }

    return {
      viewName,
      available: false,
      error: error.message,
      columns: [],
      rows: []
    };
  }
}

function clampNumber(value, fallback, min, max) {
  const number = Number(value);
  if (!Number.isFinite(number)) {
    return fallback;
  }
  return Math.min(max, Math.max(min, Math.floor(number)));
}

function isMissingDbObjectError(error) {
  return /ORA-00942|ORA-04043/i.test(String(error && error.message || error || ""));
}

function normalizeMetadataRow(row) {
  const normalized = {};
  for (const [key, value] of Object.entries(row)) {
    normalized[key] = valueToString(value);
  }
  return normalized;
}

function filterProfileMetadata(metadata, ragOnly) {
  const rows = metadata && metadata.rows || [];
  return {
    ...metadata,
    rows: rows.filter((row) => {
      const profileName = String(row.PROFILE_NAME || "").toLowerCase();
      const isRagProfile = profileName.includes("rag");
      return ragOnly ? isRagProfile : !isRagProfile;
    })
  };
}

async function handleGetLlmInstructions(res) {
  try {
    const config = await readLlmInstructionsConfig();
    const profiles = getLlmInstructionProfileList(config);
    const active = profiles.find((profile) => profile.name === config.defaultInstruction) || profiles[0] || null;
    sendJson(res, 200, {
      ok: true,
      instructionName: active ? active.name : "",
      instructions: active ? active.instructions || "" : config.instructions || "",
      updatedAt: active ? active.updatedAt || "" : config.updatedAt || "",
      defaultInstruction: config.defaultInstruction || active && active.name || "",
      profiles,
      path: llmInstructionsConfigPath
    });
  } catch (error) {
    sendJson(res, 500, {
      ok: false,
      error: "Could not read LLM instruction config",
      detail: error.message
    });
  }
}

async function handleSaveLlmInstructions(req, res) {
  try {
    const body = await readJson(req);
    const name = normalizeLlmInstructionName(body.name) || "Default";
    const instructions = normalizeLlmInstructions(body.instructions);
    const existing = await readLlmInstructionsConfig();
    const profiles = getLlmInstructionProfiles(existing);
    const updatedAt = new Date().toISOString();
    profiles[name] = {
      instructions,
      updatedAt
    };
    const defaultInstruction = existing.defaultInstruction || name;
    const config = {
      defaultInstruction,
      instructions,
      updatedAt,
      profiles
    };

    await fs.promises.mkdir(configDir, { recursive: true });
    await fs.promises.writeFile(llmInstructionsConfigPath, `${JSON.stringify(config, null, 2)}\n`, "utf8");

    sendJson(res, 200, {
      ok: true,
      instructionName: name,
      instructions,
      updatedAt,
      defaultInstruction,
      profiles: getLlmInstructionProfileList(config),
      path: llmInstructionsConfigPath
    });
  } catch (error) {
    sendJson(res, 500, {
      ok: false,
      error: "Could not save LLM instruction config",
      detail: error.message
    });
  }
}

async function readLlmInstructionsConfig() {
  try {
    const raw = await fs.promises.readFile(llmInstructionsConfigPath, "utf8");
    return normalizeLlmInstructionsConfig(JSON.parse(raw));
  } catch (error) {
    if (error.code === "ENOENT") {
      return normalizeLlmInstructionsConfig({ instructions: "", updatedAt: "" });
    }
    throw error;
  }
}

function normalizeLlmInstructionsConfig(config) {
  const baseInstructions = normalizeLlmInstructions(config && config.instructions);
  const baseUpdatedAt = String(config && config.updatedAt || "");
  const profiles = getLlmInstructionProfiles(config);
  if (!Object.keys(profiles).length && (baseInstructions || baseUpdatedAt)) {
    profiles.Default = {
      instructions: baseInstructions,
      updatedAt: baseUpdatedAt
    };
  }
  const profileNames = Object.keys(profiles);
  const defaultInstruction = normalizeLlmInstructionName(config && config.defaultInstruction)
    || profileNames[0]
    || "";
  return {
    defaultInstruction,
    instructions: baseInstructions || defaultInstruction && profiles[defaultInstruction] && profiles[defaultInstruction].instructions || "",
    updatedAt: baseUpdatedAt || defaultInstruction && profiles[defaultInstruction] && profiles[defaultInstruction].updatedAt || "",
    profiles
  };
}

function getLlmInstructionProfiles(config) {
  const rawProfiles = config && config.profiles && typeof config.profiles === "object" ? config.profiles : {};
  const profiles = {};
  for (const [rawName, rawProfile] of Object.entries(rawProfiles)) {
    const name = normalizeLlmInstructionName(rawName);
    if (!name) {
      continue;
    }
    profiles[name] = {
      instructions: normalizeLlmInstructions(rawProfile && rawProfile.instructions),
      updatedAt: String(rawProfile && rawProfile.updatedAt || "")
    };
  }
  return profiles;
}

function getLlmInstructionProfileList(config) {
  const normalized = normalizeLlmInstructionsConfig(config || {});
  return Object.entries(normalized.profiles).map(([name, profile]) => {
    return {
      name,
      instructions: profile.instructions || "",
      updatedAt: profile.updatedAt || "",
      isDefault: name === normalized.defaultInstruction
    };
  }).sort((a, b) => {
    if (a.isDefault !== b.isDefault) {
      return a.isDefault ? -1 : 1;
    }
    return a.name.localeCompare(b.name);
  });
}

async function executeWithReconnect(operation) {
  let connection;
  try {
    connection = await getConnection();
    return await operation(connection);
  } catch (error) {
    if (!isTransientDbNetworkError(error)) {
      throw error;
    }

    if (connection) {
      await connection.close().catch(() => undefined);
      connection = null;
    }

    await resetPool();
    connection = await getConnection();
    return operation(connection);
  } finally {
    if (connection) {
      await connection.close().catch(() => undefined);
    }
  }
}

async function runMcpTest({ action, toolName, toolArguments }) {
  const endpoint = normalizeMcpEndpoint(process.env.MCP_ENDPOINT);
  if (!endpoint) {
    throw new Error("MCP_ENDPOINT is not configured in .env");
  }

  const auth = await getMcpBearerToken(endpoint);
  let sessionId = "";
  const responses = [];

  const initialize = await postMcpJson({
    endpoint,
    token: auth.token,
    sessionId,
    payload: {
      jsonrpc: "2.0",
      id: 1,
      method: "initialize",
      params: {
        protocolVersion: "2024-11-05",
        capabilities: {},
        clientInfo: {
          name: "dtc-webapp-mcp-tester",
          version: "1.0.0"
        }
      }
    }
  });
  sessionId = initialize.sessionId || sessionId;
  responses.push({ step: "initialize", response: initialize.body });

  const initialized = await postMcpJson({
    endpoint,
    token: auth.token,
    sessionId,
    payload: {
      jsonrpc: "2.0",
      method: "notifications/initialized"
    }
  });
  sessionId = initialized.sessionId || sessionId;
  responses.push({ step: "notifications/initialized", response: initialized.body });

  if (action === "initialize") {
    return {
      endpoint,
      authMode: auth.mode,
      sessionId,
      responses,
      finalResponse: initialize.body
    };
  }

  if (action === "list_tools") {
    const listTools = await postMcpJson({
      endpoint,
      token: auth.token,
      sessionId,
      payload: {
        jsonrpc: "2.0",
        id: 2,
        method: "tools/list",
        params: {}
      }
    });
    sessionId = listTools.sessionId || sessionId;
    responses.push({ step: "tools/list", response: listTools.body });

    return {
      endpoint,
      authMode: auth.mode,
      sessionId,
      responses,
      finalResponse: listTools.body
    };
  }

  if (action !== "call_tool") {
    throw new Error(`Unsupported MCP action: ${action}`);
  }

  const callTool = await postMcpJson({
    endpoint,
    token: auth.token,
    sessionId,
    payload: {
      jsonrpc: "2.0",
      id: 3,
      method: "tools/call",
      params: {
        name: toolName,
        arguments: toolArguments
      }
    }
  });
  sessionId = callTool.sessionId || sessionId;
  responses.push({ step: `tools/call:${toolName}`, response: callTool.body });

  return {
    endpoint,
    authMode: auth.mode,
    sessionId,
    responses,
    finalResponse: callTool.body
  };
}

async function runMcpNaturalLanguageQuery({ prompt, profileName }) {
  const queryResult = await executeWithReconnect(async (dbConnection) => {
    await dbConnection.execute(
      "begin dbms_cloud_ai.set_profile(:profile_name); end;",
      { profile_name: profileName }
    );

    return dbConnection.execute(`select ai ${toSqlLiteral(prompt)} as response`);
  });

  return {
    action: "natural_language",
    executionMode: "select-ai",
    profileName,
    prompt,
    response: formatQueryResultResponse(queryResult),
    rows: queryResult.rows || []
  };
}

function normalizeMcpEndpoint(value) {
  return String(value || "").trim().replace(/\/+$/, "");
}

async function getMcpBearerToken(endpoint) {
  const configuredToken = String(process.env.MCP_AUTH_TOKEN || "").trim();
  if (configuredToken && !isHttpUrl(configuredToken)) {
    return {
      mode: "MCP_AUTH_TOKEN",
      token: configuredToken
    };
  }

  const username = String(process.env.DB_USER || "").trim();
  const password = String(process.env.DB_PASSWORD || "");
  if (!username || !password) {
    throw new Error("Set MCP_AUTH_TOKEN or configure DB_USER and DB_PASSWORD in .env");
  }

  const authEndpoint = getMcpAuthEndpoint(endpoint);
  const response = await fetch(authEndpoint, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "Accept": "application/json"
    },
    body: JSON.stringify({
      grant_type: "password",
      username,
      password
    })
  });
  const text = await response.text();
  const json = parseJsonText(text);
  const token = json && (json.access_token || json.accessToken || json.token);

  if (!response.ok || !token) {
    throw new Error(`MCP authentication failed (${response.status}). ${summarizeMcpBody(json || text)}`);
  }

  return {
    mode: "DB_USER/DB_PASSWORD",
    token: String(token)
  };
}

function getMcpAuthEndpoint(endpoint) {
  const configured = String(process.env.MCP_AUTH_ENDPOINT || "").trim();
  if (configured) {
    return configured.replace(/([^:])\/{2,}/g, "$1/");
  }

  const tokenConfig = String(process.env.MCP_AUTH_TOKEN || "").trim();
  if (isHttpUrl(tokenConfig)) {
    return tokenConfig.replace(/([^:])\/{2,}/g, "$1/");
  }

  const authEndpoint = `${endpoint.replace("/adb/mcp/v1/databases/", "/adb/auth/v1/databases/")}/token`;
  return authEndpoint.replace(/([^:])\/{2,}/g, "$1/");
}

function isHttpUrl(value) {
  return /^https?:\/\//i.test(String(value || "").trim());
}

async function postMcpJson({ endpoint, token, sessionId, payload }) {
  const headers = {
    "Content-Type": "application/json",
    "Accept": "application/json, text/event-stream",
    "MCP-Protocol-Version": "2024-11-05",
    "Authorization": `Bearer ${token}`
  };

  if (sessionId) {
    headers["Mcp-Session-Id"] = sessionId;
  }

  const response = await fetch(endpoint, {
    method: "POST",
    headers,
    body: JSON.stringify(payload)
  });
  const text = await response.text();
  const bodyText = extractSseJsonText(text);
  const parsedBody = parseJsonText(bodyText);

  if (!response.ok) {
    throw new Error(`MCP endpoint returned ${response.status}. ${summarizeMcpBody(parsedBody || bodyText)}`);
  }

  return {
    sessionId: response.headers.get("mcp-session-id") || response.headers.get("Mcp-Session-Id") || "",
    body: parsedBody || bodyText
  };
}

function extractSseJsonText(text) {
  const raw = String(text || "").trim();
  if (!raw.startsWith("data:")) {
    return raw;
  }

  return raw.split(/\r?\n/)
    .filter((line) => line.startsWith("data:"))
    .map((line) => line.slice(5).trim())
    .join("\n")
    .trim();
}

function parseJsonText(text) {
  try {
    return JSON.parse(text);
  } catch {
    return null;
  }
}

function summarizeMcpBody(value) {
  if (typeof value === "string") {
    return value.slice(0, 700);
  }
  return JSON.stringify(value).slice(0, 700);
}

async function getConnection() {
  if (!pool) {
    assertDbConfig();
    const poolConfig = {
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      connectString: process.env.DB_CONNECT_STRING,
      poolMin: Number(process.env.DB_POOL_MIN || 1),
      poolMax: Number(process.env.DB_POOL_MAX || 6),
      poolIncrement: 1,
      queueTimeout: Number(process.env.DB_QUEUE_TIMEOUT_MS || 120000),
      poolTimeout: Number(process.env.DB_POOL_TIMEOUT_SECONDS || 300),
      enableStatistics: true
    };

    if (process.env.TNS_ADMIN) {
      poolConfig.configDir = process.env.TNS_ADMIN;
      poolConfig.walletLocation = process.env.TNS_ADMIN;
    }

    if (process.env.DB_WALLET_PASSWORD || process.env.WALLET_PASSWORD) {
      poolConfig.walletPassword = process.env.DB_WALLET_PASSWORD || process.env.WALLET_PASSWORD;
    }

    pool = await oracledb.createPool(poolConfig);
  }
  const connection = await pool.getConnection();
  await connection.ping();
  await syncDatabaseRuntimeConfig(connection);
  return connection;
}

async function syncDatabaseRuntimeConfig(connection) {
  const googleSheetUrl = String(process.env.GOOGLE_SHEET_URL || "").trim();
  if (!googleSheetUrl || databaseRuntimeConfigReady && syncedGoogleSheetUrl === googleSheetUrl) {
    return;
  }

  await connection.execute(
    `begin
       begin
         execute immediate '
           create table fsi_runtime_config (
             config_key   varchar2(128) primary key,
             config_value clob,
             updated_at   timestamp default systimestamp not null
           )';
       exception
         when others then
           if sqlcode != -955 then
             raise;
           end if;
       end;
     end;`
  );

  await connection.execute(
    `begin
       merge into fsi_runtime_config target
       using (
         select upper(:config_key) config_key,
                :config_value config_value
           from dual
       ) source
          on (target.config_key = source.config_key)
        when matched then update set
             target.config_value = to_clob(source.config_value),
             target.updated_at = systimestamp
        when not matched then insert (
             config_key,
             config_value,
             updated_at
        ) values (
             source.config_key,
             to_clob(source.config_value),
             systimestamp
        );
     end;`,
    {
      config_key: "GOOGLE_SHEET_URL",
      config_value: googleSheetUrl
    },
    { autoCommit: true }
  );

  databaseRuntimeConfigReady = true;
  syncedGoogleSheetUrl = googleSheetUrl;
}

async function resetPool() {
  if (!pool) {
    return;
  }

  const oldPool = pool;
  pool = null;
  databaseRuntimeConfigReady = false;
  syncedGoogleSheetUrl = "";
  await oldPool.close(0).catch(() => undefined);
}

function isTransientDbNetworkError(error) {
  const message = String(error && error.message || error || "");
  return /NJS-500|NJS-501|NJS-503|NJS-508|EADDRNOTAVAIL|ECONNRESET|ETIMEDOUT|ENETUNREACH|socket|connection.*terminated/i.test(message);
}

function assertDbConfig() {
  const missing = ["DB_USER", "DB_PASSWORD", "DB_CONNECT_STRING"].filter((key) => {
    return !process.env[key];
  });
  if (missing.length) {
    throw new Error(`Missing required environment variables: ${missing.join(", ")}`);
  }
}

const editableConfigFields = [
  { key: "DB_USER", label: "Database user", type: "text", group: "Database", required: true },
  { key: "DB_PASSWORD", label: "Database password", type: "password", group: "Database", required: true, secret: true },
  { key: "DB_CONNECT_STRING", label: "Connect string", type: "text", group: "Database", required: true },
  { key: "TNS_ADMIN", label: "TNS admin / wallet directory", type: "text", group: "Database" },
  { key: "SELECT_AI_PROFILE", label: "Default Select AI profile", type: "text", group: "Database AI" },
  { key: "AI_AGENT_TEAM", label: "Default agent team", type: "text", group: "Database AI" },
  { key: "MEMORY_TABLE", label: "Memory table", type: "text", group: "Database AI" },
  { key: "OCI_STORAGE_LOCATION", label: "OCI storage location", type: "text", group: "RAG" },
  { key: "OCI_CREDENTIAL_NAME", label: "OCI DB credential", type: "text", group: "RAG" },
  { key: "RAG_PROFILE_NAME", label: "RAG Select AI profile", type: "text", group: "RAG" },
  { key: "RAG_VECTOR_INDEX_NAME", label: "RAG vector index", type: "text", group: "RAG" },
  { key: "RAG_VECTOR_DIMENSION", label: "RAG vector dimension", type: "number", group: "RAG" },
  { key: "RAG_VECTOR_DISTANCE_METRIC", label: "RAG vector distance metric", type: "text", group: "RAG" },
  { key: "RAG_CHUNK_SIZE", label: "RAG chunk size", type: "number", group: "RAG" },
  { key: "RAG_CHUNK_OVERLAP", label: "RAG chunk overlap", type: "number", group: "RAG" },
  { key: "RAG_REFRESH_RATE", label: "RAG refresh rate minutes", type: "number", group: "RAG" },
  { key: "LLM_POST_PROCESS", label: "LLM post-processing", type: "boolean", group: "LLM" },
  { key: "LLM_ENDPOINT", label: "LLM endpoint", type: "text", group: "LLM" },
  { key: "LLM_MODEL_ID", label: "LLM model", type: "text", group: "LLM" },
  { key: "OCI_COMPARTMENT_ID", label: "OCI compartment", type: "text", group: "OCI" },
  { key: "OCI_CONFIG_FILE", label: "OCI config file", type: "text", group: "OCI" },
  { key: "OCI_PROFILE", label: "OCI profile", type: "text", group: "OCI" },
  { key: "OCI_AUTH_TYPE", label: "OCI auth type", type: "text", group: "OCI" }
];

const databaseConfigFields = [
  { key: "DB_CONNECTION_NAME", label: "Connection name", type: "text" },
  { key: "DB_USER", label: "Database user", type: "text", required: true },
  { key: "DB_PASSWORD", label: "Database password", type: "password", required: true, secret: true },
  { key: "DB_CONNECT_STRING", label: "Connect string", type: "text", required: true },
  { key: "TNS_ADMIN", label: "TNS admin / wallet directory", type: "text" },
  { key: "DB_WALLET_PASSWORD", label: "Wallet password", type: "password", secret: true },
  { key: "SELECT_AI_PROFILE", label: "Select AI profile", type: "text" },
  { key: "AI_AGENT_TEAM", label: "AI agent team", type: "text" },
  { key: "MEMORY_TABLE", label: "Memory table", type: "text" },
  { key: "RAG_PROFILE_NAME", label: "RAG profile", type: "text" },
  { key: "RAG_VECTOR_INDEX_NAME", label: "RAG vector index", type: "text" }
];

const llmConfigFields = [
  { key: "LLM_POST_PROCESS", label: "LLM post-processing", type: "boolean" },
  { key: "LLM_ENDPOINT", label: "LLM endpoint", type: "text" },
  { key: "LLM_MODEL_ID", label: "LLM model", type: "text" },
  { key: "OCI_COMPARTMENT_ID", label: "OCI compartment", type: "text" },
  { key: "OCI_STORAGE_LOCATION", label: "OCI storage location", type: "text" },
  { key: "OCI_CREDENTIAL_NAME", label: "OCI DB credential", type: "text" },
  { key: "RAG_VECTOR_DIMENSION", label: "RAG vector dimension", type: "number" },
  { key: "RAG_VECTOR_DISTANCE_METRIC", label: "RAG vector distance metric", type: "text" },
  { key: "RAG_CHUNK_SIZE", label: "RAG chunk size", type: "number" },
  { key: "RAG_CHUNK_OVERLAP", label: "RAG chunk overlap", type: "number" },
  { key: "RAG_REFRESH_RATE", label: "RAG refresh rate minutes", type: "number" },
  { key: "OCI_PROFILE", label: "OCI profile", type: "text" },
  { key: "OCI_AUTH_TYPE", label: "OCI auth type", type: "text" },
  { key: "OCI_CONFIG_FILE", label: "OCI config file", type: "text" }
];

const runtimeConfigKeys = new Set([
  ...databaseConfigFields.map((field) => field.key),
  ...llmConfigFields.map((field) => field.key)
]);

const secretRuntimeConfigKeys = new Set([
  ...databaseConfigFields,
  ...llmConfigFields
].filter((field) => field.secret).map((field) => field.key));

ensureRuntimeConfigFile();
applyRuntimeConfig();
refreshRuntimeConfig();

function refreshRuntimeConfig() {
  defaultProfile = process.env.SELECT_AI_PROFILE || "dtc_select_ai_hub_nl2sql";
  defaultTeam = process.env.AI_AGENT_TEAM || "dtc_ai_team";
  llmEndpoint = process.env.LLM_ENDPOINT || "https://inference.generativeai.us-chicago-1.oci.oraclecloud.com";
  llmModelId = process.env.LLM_MODEL_ID || "xai.grok-4-1-fast-reasoning";
  llmPostProcess = String(process.env.LLM_POST_PROCESS || "true").toLowerCase() !== "false";
}

function ensureRuntimeConfigFile() {
  if (fs.existsSync(runtimeConfigPath)) {
    return;
  }

  const config = buildRuntimeConfigFromEnv();
  fs.mkdirSync(configDir, { recursive: true });
  fs.writeFileSync(runtimeConfigPath, `${JSON.stringify(config, null, 2)}\n`, "utf8");
}

function buildRuntimeConfigFromEnv() {
  return {
    defaultDatabase: "default",
    defaultLlm: "default",
    databases: {
      default: pickRuntimeVariables(databaseConfigFields)
    },
    llms: {
      default: pickRuntimeVariables(llmConfigFields)
    }
  };
}

function pickRuntimeVariables(fields) {
  return fields.reduce((values, field) => {
    if (process.env[field.key] != null) {
      values[field.key] = process.env[field.key];
    }
    return values;
  }, {});
}

function readRuntimeConfig() {
  try {
    const raw = fs.readFileSync(runtimeConfigPath, "utf8");
    return normalizeRuntimeConfig(JSON.parse(raw));
  } catch (error) {
    if (error.code === "ENOENT") {
      return normalizeRuntimeConfig(buildRuntimeConfigFromEnv());
    }
    throw error;
  }
}

function normalizeRuntimeConfig(config, existingConfig = null) {
  const existing = existingConfig || { databases: {}, llms: {} };
  const databases = normalizeConfigCollection(config && config.databases, existing.databases, databaseConfigFields);
  const llms = normalizeConfigCollection(config && config.llms, existing.llms, llmConfigFields);
  const databaseNames = Object.keys(databases);
  const llmNames = Object.keys(llms);
  const defaultDatabase = databaseNames.includes(config && config.defaultDatabase)
    ? config.defaultDatabase
    : databaseNames[0] || "default";
  const defaultLlm = llmNames.includes(config && config.defaultLlm)
    ? config.defaultLlm
    : llmNames[0] || "default";

  return {
    defaultDatabase,
    defaultLlm,
    databases: databaseNames.length ? databases : { default: {} },
    llms: llmNames.length ? llms : { default: {} }
  };
}

function normalizeConfigCollection(collection, existingCollection, fields) {
  const entries = Array.isArray(collection)
    ? collection.map((item) => [item && item.name, item && (item.variables || item.values || item)])
    : Object.entries(collection || {});
  const normalized = {};

  for (const [rawName, rawValues] of entries) {
    const name = normalizeConfigName(rawName);
    if (!name) {
      continue;
    }

    const previousValues = existingCollection && existingCollection[name] || {};
    normalized[name] = normalizeConfigValues(rawValues || {}, previousValues, fields);
  }

  return normalized;
}

function normalizeConfigValues(values, previousValues, fields) {
  const allowed = new Set(fields.map((field) => field.key));
  const normalized = {};

  for (const field of fields) {
    if (!Object.prototype.hasOwnProperty.call(values, field.key)) {
      if (previousValues && previousValues[field.key] != null) {
        normalized[field.key] = previousValues[field.key];
      }
      continue;
    }

    const value = String(values[field.key] ?? "").trim();
    if (field.secret && !value && previousValues && previousValues[field.key]) {
      normalized[field.key] = previousValues[field.key];
    } else if (value) {
      normalized[field.key] = value;
    }
  }

  Object.keys(values || {}).forEach((key) => {
    if (allowed.has(key) || key === "name" || key === "variables" || key === "values") {
      return;
    }
    if (runtimeConfigKeys.has(key) && values[key] != null && String(values[key]).trim()) {
      normalized[key] = String(values[key]).trim();
    }
  });

  return normalized;
}

function normalizeConfigName(name) {
  return String(name || "").trim().replace(/\s+/g, "_");
}

function writeRuntimeConfig(config) {
  fs.mkdirSync(configDir, { recursive: true });
  fs.writeFileSync(runtimeConfigPath, `${JSON.stringify(config, null, 2)}\n`, "utf8");
}

function applyRuntimeConfig(config = readRuntimeConfig()) {
  const normalized = normalizeRuntimeConfig(config);
  const activeDatabase = normalized.databases[normalized.defaultDatabase] || {};
  const activeLlm = normalized.llms[normalized.defaultLlm] || {};

  runtimeConfigKeys.forEach((key) => {
    const value = activeDatabase[key] ?? activeLlm[key];
    if (value != null && String(value).trim()) {
      process.env[key] = String(value);
    } else {
      delete process.env[key];
    }
  });

  return normalized;
}

function publicRuntimeConfig(config) {
  return {
    path: runtimeConfigPath,
    defaultDatabase: config.defaultDatabase,
    defaultLlm: config.defaultLlm,
    databaseFields: databaseConfigFields,
    llmFields: llmConfigFields,
    databaseConfigs: Object.entries(config.databases).map(([name, values]) => {
      return publicConfigNode(name, values, databaseConfigFields, name === config.defaultDatabase);
    }),
    llmConfigs: Object.entries(config.llms).map(([name, values]) => {
      return publicConfigNode(name, values, llmConfigFields, name === config.defaultLlm);
    })
  };
}

function publicConfigNode(name, values, fields, isDefault) {
  return {
    name,
    isDefault,
    values: Object.fromEntries(fields.map((field) => {
      const value = values && values[field.key] || "";
      return [field.key, field.secret ? "" : value];
    })),
    configured: Object.fromEntries(fields.map((field) => {
      return [field.key, Boolean(values && values[field.key])];
    }))
  };
}

function getActiveDatabaseConnectionName() {
  const runtimeConfig = readRuntimeConfig();
  const activeDatabase = runtimeConfig.databases[runtimeConfig.defaultDatabase] || {};
  return String(activeDatabase.DB_CONNECTION_NAME || runtimeConfig.defaultDatabase || "").trim();
}

function getPublicConfig(includeEditableFields = false) {
  const runtimeConfig = readRuntimeConfig();
  const config = {
    hasDbUser: Boolean(process.env.DB_USER),
    hasDbPassword: Boolean(process.env.DB_PASSWORD),
    hasDbConnectString: Boolean(process.env.DB_CONNECT_STRING),
    hasMcpEndpoint: Boolean(process.env.MCP_ENDPOINT),
    hasMcpAuthToken: Boolean(process.env.MCP_AUTH_TOKEN),
    tnsAdmin: process.env.TNS_ADMIN || "",
    profileName: defaultProfile,
    teamName: defaultTeam,
    llmPostProcess,
    llmEndpoint,
    llmModelId,
    hasOciCompartmentId: Boolean(process.env.OCI_COMPARTMENT_ID),
    runtimeConfig: publicRuntimeConfig(runtimeConfig)
  };

  if (!includeEditableFields) {
    return config;
  }

  return {
    ...config,
    envPath,
    configPath: runtimeConfigPath,
    fields: editableConfigFields.map((field) => ({
      ...field,
      value: field.secret ? "" : process.env[field.key] || "",
      configured: Boolean(process.env[field.key])
    }))
  };
}

async function handleSaveConfig(req, res) {
  try {
    const body = await readJson(req);
    const previousEnv = Object.fromEntries([...runtimeConfigKeys].map((key) => [key, process.env[key] || ""]));
    const existingConfig = readRuntimeConfig();
    const previousDefaultDatabase = existingConfig.defaultDatabase;
    let nextConfig;

    if (body.runtimeConfig && typeof body.runtimeConfig === "object") {
      nextConfig = normalizeRuntimeConfig(body.runtimeConfig, existingConfig);
    } else {
      const values = body.values && typeof body.values === "object" ? body.values : {};
      nextConfig = normalizeRuntimeConfig(existingConfig, existingConfig);
      const activeDatabase = nextConfig.databases[nextConfig.defaultDatabase] || {};
      const activeLlm = nextConfig.llms[nextConfig.defaultLlm] || {};
      const unknownKeys = Object.keys(values).filter((key) => !runtimeConfigKeys.has(key));

      if (unknownKeys.length) {
        return sendJson(res, 400, {
          ok: false,
          error: `Unsupported config variable: ${unknownKeys.join(", ")}`
        });
      }

      Object.entries(values).forEach(([key, rawValue]) => {
        const value = String(rawValue ?? "").trim();
        if (databaseConfigFields.some((field) => field.key === key)) {
          if (!secretRuntimeConfigKeys.has(key) || value || !activeDatabase[key]) {
            activeDatabase[key] = value;
          }
        } else if (!secretRuntimeConfigKeys.has(key) || value || !activeLlm[key]) {
          activeLlm[key] = value;
        }
      });
    }

    writeRuntimeConfig(nextConfig);
    applyRuntimeConfig(nextConfig);
    refreshRuntimeConfig();

    const changedKeys = [...runtimeConfigKeys].filter((key) => previousEnv[key] !== (process.env[key] || ""));
    const dbKeys = databaseConfigFields.map((field) => field.key);
    const ociKeys = llmConfigFields.map((field) => field.key);

    if (changedKeys.some((key) => dbKeys.includes(key))) {
      await resetPool();
    }
    if (changedKeys.some((key) => ociKeys.includes(key))) {
      genAiClient = null;
      objectStorageClient = null;
    }

    const restartRequired = previousDefaultDatabase !== nextConfig.defaultDatabase;
    sendJson(res, 200, {
      ok: true,
      changedKeys,
      restartRequired,
      config: getPublicConfig(true)
    });
    if (restartRequired) {
      scheduleServerRestart(res);
    }
  } catch (error) {
    sendJson(res, 500, {
      ok: false,
      error: "Could not save configuration",
      detail: error.message
    });
  }
}

async function handleUpdateSelectAiProfileLlm(req, res) {
  try {
    const body = await readJson(req);
    const profileName = normalizeDbName(body.profileName) || defaultProfile;
    const llmName = String(body.llmName || "").trim();
    const llmConfig = getRuntimeLlmConfig(llmName);

    if (!llmConfig) {
      return sendJson(res, 400, {
        ok: false,
        error: `LLM configuration not found: ${llmName}`
      });
    }

    const profileUpdate = getSelectAiProfileLlmUpdate(llmConfig);

    if (!profileUpdate.model) {
      return sendJson(res, 400, {
        ok: false,
        error: `LLM configuration ${llmName} does not define LLM_MODEL_ID`
      });
    }

    await executeWithReconnect(async (dbConnection) => {
      await applySelectAiProfileLlmConfig(dbConnection, profileName, llmName, llmConfig);
    });

    sendJson(res, 200, {
      ok: true,
      profileName,
      llmName,
      model: profileUpdate.model,
      credentialName: profileUpdate.credentialName,
      region: profileUpdate.region,
      message: `Select AI profile ${profileName} was updated to ${llmName} (${profileUpdate.model}).`
    });
  } catch (error) {
    sendJson(res, 500, {
      ok: false,
      error: "Could not update Select AI profile LLM",
      detail: error.message
    });
  }
}

function getRuntimeLlmConfig(llmName) {
  const runtimeConfig = readRuntimeConfig();
  return runtimeConfig.llms[String(llmName || "").trim()] || null;
}

function getSelectAiProfileLlmUpdate(llmConfig) {
  return {
    model: String(llmConfig && llmConfig.LLM_MODEL_ID || "").trim(),
    credentialName: String(llmConfig && llmConfig.OCI_CREDENTIAL_NAME || process.env.OCI_CREDENTIAL_NAME || "oci").trim(),
    region: String(llmConfig && (llmConfig.OCI_REGION || deriveOciRegionFromEndpoint(llmConfig.LLM_ENDPOINT)) || "").trim()
  };
}

async function applySelectAiProfileLlmConfig(connection, profileName, llmName, llmConfig) {
  const update = getSelectAiProfileLlmUpdate(llmConfig);
  if (!update.model) {
    throw new Error(`LLM configuration ${llmName} does not define LLM_MODEL_ID`);
  }

  await setSelectAiProfileAttribute(connection, profileName, "provider", "oci");
  await setSelectAiProfileAttribute(connection, profileName, "model", update.model);
  await setSelectAiProfileAttribute(connection, profileName, "credential_name", update.credentialName);
  await setSelectAiProfileAttribute(connection, profileName, "oci_apiformat", "GENERIC");
  if (update.region) {
    await setSelectAiProfileAttribute(connection, profileName, "region", update.region);
  }
  await connection.execute(
    "begin dbms_cloud_ai.set_profile(profile_name => :profile_name); end;",
    { profile_name: profileName }
  );
  await connection.commit();
}

async function setSelectAiProfileAttribute(connection, profileName, attributeName, attributeValue) {
  await connection.execute(
    `begin
       dbms_cloud_ai.set_attribute(
         profile_name    => :profile_name,
         attribute_name  => :attribute_name,
         attribute_value => :attribute_value
       );
     end;`,
    {
      profile_name: profileName,
      attribute_name: attributeName,
      attribute_value: String(attributeValue)
    }
  );
}

function deriveOciRegionFromEndpoint(endpoint) {
  const text = String(endpoint || "").trim();
  if (!text) {
    return "";
  }
  try {
    const host = new URL(text).hostname;
    const match = host.match(/(?:^|\.)generativeai\.([a-z]+-[a-z]+-\d+)\.oci\./i)
      || host.match(/(?:^|\.)([a-z]+-[a-z]+-\d+)\.oci\./i);
    return match ? match[1] : "";
  } catch {
    return "";
  }
}

function handleRestart(res) {
  sendJson(res, 200, {
    ok: true,
    message: `Restarting application server on http://${host}:${port}`
  });

  scheduleServerRestart(res);
}

function scheduleServerRestart(res) {
  res.on("finish", () => {
    setTimeout(() => {
      server.close(() => {
        const child = spawn(process.execPath, [path.join(__dirname, "server.js")], {
          cwd: __dirname,
          detached: true,
          env: process.env,
          stdio: "ignore"
        });
        child.unref();
        process.exit(0);
      });

      setTimeout(() => process.exit(0), 3000).unref();
    }, 150);
  });
}

function serveStatic(urlPath, res) {
  const requested = urlPath === "/" ? "/index.html" : urlPath;
  const filePath = path.normalize(path.join(publicDir, requested));

  if (!filePath.startsWith(publicDir)) {
    return sendText(res, 403, "Forbidden", "text/plain");
  }

  fs.readFile(filePath, (error, content) => {
    if (error) {
      return sendText(res, 404, "Not found", "text/plain");
    }
    sendText(res, 200, content, contentType(filePath));
  });
}

function readJson(req) {
  return new Promise((resolve, reject) => {
    let raw = "";
    req.on("data", (chunk) => {
      raw += chunk;
      if (Buffer.byteLength(raw, "utf8") > jsonBodyMaxBytes) {
        req.destroy(new Error(`Request body too large. Maximum size is ${Math.floor(jsonBodyMaxBytes / 1024 / 1024)} MB.`));
      }
    });
    req.on("end", () => {
      try {
        resolve(raw ? JSON.parse(raw) : {});
      } catch (error) {
        reject(new Error("Invalid JSON request body"));
      }
    });
    req.on("error", reject);
  });
}

function readMultipartForm(req, { maxBytes }) {
  return new Promise((resolve, reject) => {
    const contentTypeHeader = String(req.headers["content-type"] || "");
    const boundaryMatch = contentTypeHeader.match(/boundary=(?:"([^"]+)"|([^;]+))/i);
    if (!boundaryMatch) {
      reject(new Error("Expected multipart form data"));
      return;
    }

    const chunks = [];
    let total = 0;
    req.on("data", (chunk) => {
      total += chunk.length;
      if (total > maxBytes) {
        req.destroy(new Error(`Upload is too large. Maximum size is ${Math.floor(maxBytes / 1024 / 1024)} MB.`));
        return;
      }
      chunks.push(chunk);
    });
    req.on("end", () => {
      try {
        resolve(parseMultipartBuffer(Buffer.concat(chunks), boundaryMatch[1] || boundaryMatch[2]));
      } catch (error) {
        reject(error);
      }
    });
    req.on("error", reject);
  });
}

function parseMultipartBuffer(buffer, boundary) {
  const form = {
    fields: {},
    files: {}
  };
  const boundaryText = `--${boundary}`;
  const raw = buffer.toString("binary");

  for (const rawPart of raw.split(boundaryText)) {
    if (!rawPart || rawPart === "--\r\n" || rawPart === "--") {
      continue;
    }

    const part = rawPart.replace(/^\r\n/, "").replace(/\r\n$/, "").replace(/--$/, "");
    const headerEnd = part.indexOf("\r\n\r\n");
    if (headerEnd < 0) {
      continue;
    }

    const headerText = part.slice(0, headerEnd);
    const bodyBinary = part.slice(headerEnd + 4).replace(/\r\n$/, "");
    const disposition = headerText.match(/content-disposition:\s*form-data;([^\r\n]+)/i);
    if (!disposition) {
      continue;
    }

    const nameMatch = disposition[1].match(/name="([^"]+)"/i);
    if (!nameMatch) {
      continue;
    }

    const name = nameMatch[1];
    const filenameMatch = disposition[1].match(/filename="([^"]*)"/i);
    if (filenameMatch) {
      form.files[name] = {
        filename: filenameMatch[1],
        content: Buffer.from(bodyBinary, "binary")
      };
    } else {
      form.fields[name] = Buffer.from(bodyBinary, "binary").toString("utf8");
    }
  }

  return form;
}

function sendJson(res, status, payload) {
  sendText(res, status, JSON.stringify(payload), "application/json; charset=utf-8");
}

function sendForbidden(res) {
  sendJson(res, 403, {
    ok: false,
    error: "Admin role required"
  });
}

function sendText(res, status, content, type) {
  res.writeHead(status, {
    "Content-Type": type,
    "Cache-Control": "no-store"
  });
  res.end(content);
}

function contentType(filePath) {
  const ext = path.extname(filePath);
  return {
    ".html": "text/html; charset=utf-8",
    ".css": "text/css; charset=utf-8",
    ".js": "application/javascript; charset=utf-8",
    ".json": "application/json; charset=utf-8",
    ".pdf": "application/pdf",
    ".svg": "image/svg+xml"
  }[ext] || "application/octet-stream";
}

function loadDotEnv(filePath) {
  if (!fs.existsSync(filePath)) {
    return;
  }

  const lines = fs.readFileSync(filePath, "utf8").split(/\r?\n/);
  for (const line of lines) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith("#")) {
      continue;
    }

    const index = trimmed.indexOf("=");
    if (index < 1) {
      continue;
    }

    const key = trimmed.slice(0, index).trim();
    let value = trimmed.slice(index + 1).trim();
    if ((value.startsWith('"') && value.endsWith('"')) || (value.startsWith("'") && value.endsWith("'"))) {
      value = value.slice(1, -1);
    }
    if (!process.env[key]) {
      process.env[key] = value;
    }
  }
}

function ensureAuthFile(filePath) {
  if (fs.existsSync(filePath)) {
    return;
  }

  const users = [
    { username: "admin", displayName: "Administrator", password: encodePassword("admin123"), role: "Admin" },
    { username: "user", displayName: "Standard User", password: encodePassword("user123"), role: "User" }
  ];
  fs.writeFileSync(filePath, `${JSON.stringify(users, null, 2)}\n`, "utf8");
}

function readAuthUsers() {
  const raw = fs.readFileSync(authPath, "utf8").trim();
  if (!raw) {
    return [];
  }
  if (raw.startsWith("[")) {
    return JSON.parse(raw).map(normalizeAuthUser).filter((user) => user.username);
  }
  return raw.split(/\r?\n/)
    .map((line) => line.trim())
    .filter((line) => line && !line.startsWith("#"))
    .map((line) => {
      const [username, password, role] = line.split(",").map((part) => String(part || "").trim());
      return normalizeAuthUser({ username, password, role });
    })
    .filter((user) => user.username);
}

function normalizeAuthUser(user) {
  const username = String(user && user.username || "").trim();
  return {
    username,
    displayName: String(user && user.displayName || user && user.name || username).trim(),
    password: normalizeStoredPassword(user && user.password),
    role: normalizeRole(user && user.role)
  };
}

async function writeAuthUsers(users) {
  const normalized = users.map((user) => ({
    username: normalizeUsername(user.username),
    displayName: String(user.displayName || user.username || "").trim(),
    password: normalizeStoredPassword(user.password),
    role: normalizeRole(user.role)
  }));
  await fs.promises.writeFile(authPath, `${JSON.stringify(normalized, null, 2)}\n`, "utf8");
}

function readLinks() {
  if (!fs.existsSync(linksConfigPath)) {
    return [];
  }

  const raw = fs.readFileSync(linksConfigPath, "utf8").trim();
  if (!raw) {
    return [];
  }

  const parsed = JSON.parse(raw);
  const links = Array.isArray(parsed) ? parsed : parsed.links;
  return Array.isArray(links)
    ? links.map(normalizeStoredLink).filter((link) => link.name && link.url)
    : [];
}

async function writeLinks(links) {
  const normalized = links.map(normalizeStoredLink).filter((link) => link.name && link.url);
  await fs.promises.mkdir(configDir, { recursive: true });
  await fs.promises.writeFile(linksConfigPath, `${JSON.stringify(normalized, null, 2)}\n`, "utf8");
}

function normalizeStoredLink(link) {
  return {
    id: String(link && link.id || crypto.randomUUID()).trim(),
    name: String(link && link.name || "").trim(),
    url: String(link && link.url || "").trim(),
    createdAt: String(link && link.createdAt || "").trim()
  };
}

function normalizeLinkInput(body) {
  const name = String(body && body.name || "").trim();
  const rawUrl = String(body && body.url || "").trim();
  if (!name || !rawUrl) {
    throw new Error("Link name and URL are required");
  }
  if (name.length > 120) {
    throw new Error("Link name must be 120 characters or fewer");
  }

  let parsed;
  try {
    parsed = new URL(rawUrl);
  } catch {
    throw new Error("Enter a valid URL including http:// or https://");
  }

  if (!["http:", "https:"].includes(parsed.protocol)) {
    throw new Error("Only http:// and https:// URLs are supported");
  }

  return {
    name,
    url: parsed.toString()
  };
}

function normalizeUsername(value) {
  const username = String(value || "").trim();
  if (!username) {
    return "";
  }
  if (!/^[A-Za-z][A-Za-z0-9_.@-]{1,63}$/.test(username)) {
    throw new Error("Username must start with a letter and use only letters, numbers, dot, underscore, hyphen, or @");
  }
  return username;
}

function normalizeStoredPassword(password) {
  const text = String(password || "");
  if (!text) {
    return "";
  }
  if (isBase64Password(text)) {
    return text;
  }
  return encodePassword(text);
}

function encodePassword(password) {
  return Buffer.from(String(password || ""), "utf8").toString("base64");
}

function decodePassword(password) {
  const text = String(password || "");
  if (!isBase64Password(text)) {
    return text;
  }
  return Buffer.from(text, "base64").toString("utf8");
}

function isBase64Password(value) {
  const text = String(value || "");
  return /^[A-Za-z0-9+/]+={0,2}$/.test(text) && text.length % 4 === 0;
}

function normalizeRole(role) {
  const text = String(role || "User").trim();
  return text.toLowerCase() === "admin" ? "Admin" : "User";
}

function getCurrentUser(req) {
  const sessionId = getSessionId(req);
  if (!sessionId) {
    return null;
  }

  const session = sessions.get(sessionId);
  if (!session) {
    return null;
  }

  const lastSeenAt = session.lastSeenAt || session.createdAt || 0;
  if (Date.now() - lastSeenAt > sessionTimeoutMs) {
    sessions.delete(sessionId);
    return null;
  }

  session.lastSeenAt = Date.now();
  return session;
}

function getSessionId(req) {
  const cookies = parseCookies(req.headers.cookie || "");
  return cookies.dtc_session || "";
}

function parseCookies(cookieHeader) {
  return String(cookieHeader || "").split(";").reduce((cookies, part) => {
    const index = part.indexOf("=");
    if (index < 0) {
      return cookies;
    }
    const key = part.slice(0, index).trim();
    const value = part.slice(index + 1).trim();
    cookies[key] = decodeURIComponent(value);
    return cookies;
  }, {});
}

function sessionCookie(sessionId) {
  return `dtc_session=${encodeURIComponent(sessionId)}; HttpOnly; SameSite=Lax; Path=/; Max-Age=${sessionTimeoutSeconds}`;
}

function publicUser(user) {
  return {
    username: user.username,
    displayName: user.displayName || user.username,
    role: normalizeRole(user.role)
  };
}

function isAdmin(user) {
  return Boolean(user && normalizeRole(user.role) === "Admin");
}

async function writeDotEnv(filePath, updates) {
  const existing = fs.existsSync(filePath)
    ? await fs.promises.readFile(filePath, "utf8")
    : "";
  const seen = new Set();
  const lines = existing.split(/\r?\n/);
  const hasTrailingNewline = /\r?\n$/.test(existing);
  const updatedLines = lines.map((line, index) => {
    if (index === lines.length - 1 && !line && hasTrailingNewline) {
      return line;
    }

    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith("#")) {
      return line;
    }

    const separator = line.indexOf("=");
    if (separator < 1) {
      return line;
    }

    const key = line.slice(0, separator).trim();
    if (!Object.prototype.hasOwnProperty.call(updates, key)) {
      return line;
    }

    seen.add(key);
    return `${key}=${formatEnvValue(updates[key])}`;
  });

  const missingLines = Object.entries(updates)
    .filter(([key]) => !seen.has(key))
    .map(([key, value]) => `${key}=${formatEnvValue(value)}`);

  const nextContent = [...updatedLines.filter((line, index) => {
    return !(index === updatedLines.length - 1 && !line && !hasTrailingNewline);
  }), ...missingLines].join("\n").replace(/\n*$/, "\n");
  await fs.promises.writeFile(filePath, nextContent, "utf8");
}

function formatEnvValue(value) {
  const text = String(value ?? "");
  if (!text) {
    return "";
  }
  if (/[\s#"'\\]/.test(text)) {
    return JSON.stringify(text);
  }
  return text;
}

function normalizeDbName(value) {
  const text = String(value || "").trim();
  if (!text) {
    return "";
  }
  if (!/^[A-Za-z][A-Za-z0-9_$#]{0,127}$/.test(text)) {
    throw new Error(`Invalid database object name: ${text}`);
  }
  return text;
}

function normalizeManagerItemType(value) {
  const text = String(value || "").trim().toLowerCase();
  return {
    tool: "Tool",
    task: "Task",
    agent: "Agent",
    team: "Team",
    profile: "Profile"
  }[text] || "";
}

function getManagerDropSql(itemType) {
  return {
    Tool: "begin dbms_cloud_ai_agent.drop_tool(tool_name => :item_name, force => true); end;",
    Task: "begin dbms_cloud_ai_agent.drop_task(task_name => :item_name, force => true); end;",
    Agent: "begin dbms_cloud_ai_agent.drop_agent(agent_name => :item_name, force => true); end;",
    Team: "begin dbms_cloud_ai_agent.drop_team(team_name => :item_name, force => true); end;",
    Profile: "begin dbms_cloud_ai.drop_profile(profile_name => :item_name); end;"
  }[itemType];
}

function normalizeBuilderItemType(value) {
  const text = String(value || "").trim().toLowerCase();
  return {
    tool: "Tool",
    task: "Task",
    agent: "Agent",
    team: "Team",
    selectprofile: "SelectProfile",
    ragprofile: "RagProfile"
  }[text] || "";
}

function getBuilderCreateSql(itemType) {
  const sql = {
    Tool: `begin
             dbms_cloud_ai_agent.create_tool(
               tool_name   => :item_name,
               attributes  => :attributes,
               description => :description
             );
           end;`,
    Task: `begin
             dbms_cloud_ai_agent.create_task(
               task_name   => :item_name,
               attributes  => :attributes,
               description => :description
             );
           end;`,
    Agent: `begin
              dbms_cloud_ai_agent.create_agent(
                agent_name  => :item_name,
                attributes  => :attributes,
                description => :description
              );
            end;`,
    Team: `begin
             dbms_cloud_ai_agent.create_team(
               team_name   => :item_name,
               attributes  => :attributes,
               description => :description
             );
           end;`
    ,
    SelectProfile: `declare
                      l_description varchar2(4000) := :description;
                    begin
                      dbms_cloud_ai.create_profile(
                        profile_name => :item_name,
                        attributes   => :attributes
                      );
                    end;`,
    RagProfile: `declare
                   l_description varchar2(4000) := :description;
                 begin
                   dbms_cloud_ai.create_profile(
                     profile_name => :item_name,
                     attributes   => :attributes
                   );
                 end;`
  }[itemType];

  if (!sql) {
    throw new Error(`Unsupported builder item type: ${itemType}`);
  }
  return sql;
}

function normalizeLlmInstructions(value) {
  const text = String(value || "").trim();
  return text.slice(0, Number(process.env.LLM_CUSTOM_INSTRUCTIONS_MAX_CHARS || 4000));
}

function normalizeLlmInstructionName(value) {
  const text = String(value || "").trim().replace(/\s+/g, " ");
  return text.slice(0, 80);
}

function toSqlLiteral(value) {
  return `'${String(value).replaceAll("'", "''")}'`;
}

function firstValue(result) {
  const row = result.rows && result.rows[0];
  if (!row) {
    return "";
  }
  if (Array.isArray(row)) {
    return row[0];
  }
  return row.RESPONSE ?? row.response ?? Object.values(row)[0];
}

function formatQueryResultResponse(result) {
  const rows = result.rows || [];
  if (!rows.length) {
    return "";
  }

  const columnNames = (result.metaData || []).map((column) => column.name);
  const firstRow = rows[0];
  const isSingleColumn = columnNames.length <= 1
    || Array.isArray(firstRow) && firstRow.length <= 1
    || !Array.isArray(firstRow) && Object.keys(firstRow).length <= 1;

  if (isSingleColumn) {
    return valueToString(firstValue(result));
  }

  const normalizedRows = rows.map((row) => normalizeResultRow(row, columnNames));
  return [
    `Returned ${rows.length} row${rows.length === 1 ? "" : "s"} with ${Object.keys(normalizedRows[0] || {}).length} columns.`,
    "",
    JSON.stringify(normalizedRows, null, 2)
  ].join("\n");
}

function shouldAppendFsiRagSearch(mode, teamName, prompt) {
  if (mode !== "agent" || normalizeDbName(teamName).toUpperCase() !== "FSI_FRAUD_INVESTIGATION_TEAM") {
    return false;
  }

  return /\b(rag|knowledge\s*base|citation|citations|document|documents|policy|policies|procedure|procedures|guidance|manual|uploaded|source|sources)\b/i
    .test(String(prompt || ""));
}

function extractClaimIdFromPrompt(prompt) {
  const match = String(prompt || "").match(/\bclaim\s*(?:id|#)?\s*[:#-]?\s*(\d+)\b/i);
  return match ? Number(match[1]) : null;
}

function shouldAppendFsiThirdPartyEvidence(mode, teamName, prompt, databaseResponse) {
  if (mode !== "agent" || normalizeDbName(teamName).toUpperCase() !== "FSI_FRAUD_INVESTIGATION_TEAM") {
    return false;
  }

  if (!extractClaimIdFromPrompt(prompt)) {
    return false;
  }

  return !/FSI Third-Party Evidence Summary/i.test(String(databaseResponse || ""));
}

function hasFsiRagSearchSection(value) {
  return /FSI RAG Search Results and Document Citations/i.test(String(value || ""));
}

async function runFsiThirdPartyEvidenceSummary(connection, claimId) {
  if (!claimId) {
    return null;
  }

  try {
    const result = await connection.execute(
      `with payload as (
         select fsi_third_party_fraud_data(:claim_id) data
           from dual
       )
       select json_object(
                'claim_id' value :claim_id,
                'weather_data' value coalesce(json_query(data, '$.weather_data' returning clob), to_clob('{}')) format json,
                'google_sheet_fraud_score' value coalesce(json_query(data, '$.google_sheet_fraud_score' returning clob), to_clob('{}')) format json
              returning clob) as evidence_summary
         from payload`,
      { claim_id: claimId }
    );
    const raw = valueToString(firstValue(result));
    return {
      ok: true,
      claimId,
      evidence: raw ? JSON.parse(raw) : {}
    };
  } catch (error) {
    return {
      ok: false,
      claimId,
      error: error.message
    };
  }
}

function appendFsiThirdPartyEvidenceToResponse(databaseResponse, thirdPartySummary) {
  if (!thirdPartySummary) {
    return databaseResponse;
  }

  const lines = [
    databaseResponse || "",
    "",
    "## FSI Third-Party Evidence Summary",
    "",
    `Claim ID: ${thirdPartySummary.claimId || "UNKNOWN"}`
  ];

  if (!thirdPartySummary.ok) {
    lines.push("", `Third-party evidence error: ${thirdPartySummary.error || "Unknown error"}`);
    return lines.join("\n").trim();
  }

  const evidence = thirdPartySummary.evidence || {};
  const weather = evidence.weather_data || {};
  const weatherRisk = weather.risk_indicators || {};
  const google = evidence.google_sheet_fraud_score || {};

  lines.push(
    "",
    "### Weather Evidence",
    "",
    `- Provider: ${weather.provider || "Open-Meteo"}`,
    `- Status: ${weather.status || "UNKNOWN"}`,
    `- Requested city: ${weather.requested_city || weather.city || "UNKNOWN"}`,
    `- Weather date: ${weather.weather_date || weather.requested_date || weather.date || "UNKNOWN"}`,
    `- Weather may affect accident risk: ${weatherRisk.weather_may_affect_accident_risk ?? "UNKNOWN"}`,
    "",
    "Weather data JSON:",
    JSON.stringify(weather, null, 2),
    "",
    "### Google Sheet Fraud Score",
    "",
    `- Provider: ${google.provider || "Google Sheets customer fraud score"}`,
    `- Status: ${google.status || "UNKNOWN"}`,
    `- Lookup customer: ${google.lookup_customer_name || "UNKNOWN"}`,
    `- Matched customer: ${google.matched_customer_name || "UNKNOWN"}`,
    `- Fraud score: ${google.fraud_score ?? google.fraud_score_display ?? google.fraud_score_raw ?? "UNKNOWN"}`,
    `- Match found: ${google.match_found ?? "UNKNOWN"}`,
    "",
    "Google Sheet fraud score JSON:",
    JSON.stringify(google, null, 2)
  );

  return lines.join("\n").trim();
}

async function runRagSearchForPrompt(connection, prompt, profileName) {
  const ragProfileName = normalizeDbName(profileName);
  if (!ragProfileName) {
    return null;
  }

  try {
    const ragPrompt = [
      "Search the FSI fraud investigation RAG knowledge base for the user's prompt.",
      "Return concise relevant findings.",
      "At the end, include a 'Document Citations' section with cited document names, source object names, or URLs returned by the RAG profile.",
      "If the RAG profile does not return citations, state that no document citations were returned.",
      "",
      "User prompt:",
      prompt
    ].join("\n");
    const result = await connection.execute(
      "select dbms_cloud_ai.generate(prompt => :prompt, profile_name => :profile_name, action => 'narrate') as response from dual",
      {
        prompt: ragPrompt,
        profile_name: ragProfileName
      }
    );
    const response = formatQueryResultResponse(result).trim();
    return {
      ok: true,
      profileName: ragProfileName,
      response
    };
  } catch (error) {
    return {
      ok: false,
      profileName: ragProfileName,
      error: error.message
    };
  }
}

function appendRagSearchToResponse(databaseResponse, ragSearch) {
  if (!ragSearch) {
    return databaseResponse;
  }

  const lines = [
    databaseResponse || "",
    "",
    "## FSI RAG Search Results and Document Citations",
    "",
    `RAG profile: ${ragSearch.profileName || "fsi_select_ai_rag_kb_profile"}`,
    ""
  ];

  if (ragSearch.ok) {
    lines.push(ragSearch.response || "No RAG search response was returned.");
  } else {
    lines.push(`RAG search error: ${ragSearch.error || "Unknown error"}`);
  }

  return lines.join("\n").trim();
}

function normalizeResultRow(row, columnNames) {
  if (!Array.isArray(row)) {
    return Object.fromEntries(Object.entries(row).map(([key, value]) => [key, normalizeResultValue(value)]));
  }

  return row.reduce((normalized, value, index) => {
    normalized[columnNames[index] || `COLUMN_${index + 1}`] = normalizeResultValue(value);
    return normalized;
  }, {});
}

function normalizeResultValue(value) {
  if (value instanceof Date) {
    return value.toISOString();
  }
  if (Buffer.isBuffer(value)) {
    return `0x${value.toString("hex").toUpperCase()}`;
  }
  return value;
}

function valueToString(value) {
  if (value == null) {
    return "";
  }
  if (typeof value === "string") {
    return value;
  }
  if (Buffer.isBuffer(value)) {
    return `0x${value.toString("hex").toUpperCase()}`;
  }
  if (value instanceof Date) {
    return value.toISOString();
  }
  return JSON.stringify(value, null, 2);
}

async function renderWithOciLlm({ prompt, mode, databaseResponse, llmInstructions }) {
  if (!process.env.OCI_COMPARTMENT_ID) {
    return {
      ok: false,
      skipped: "OCI_COMPARTMENT_ID is not configured",
      text: "",
      html: ""
    };
  }

  const client = getGenAiClient();
  const llmPrompt = buildRenderPrompt({ prompt, mode, databaseResponse, llmInstructions });
  const chatDetails = {
    compartmentId: process.env.OCI_COMPARTMENT_ID,
    servingMode: {
      servingType: "ON_DEMAND",
      modelId: llmModelId
    },
    chatRequest: {
      apiFormat: "GENERIC",
      temperature: Number(process.env.LLM_TEMPERATURE || 0),
      maxTokens: Number(process.env.LLM_MAX_TOKENS || 8000),
      messages: [
        {
          role: "SYSTEM",
          content: [
            {
              type: "TEXT",
              text: "You transform Oracle Database AI results into complete, standalone HTML for a business web app. Preserve every row, value, heading, caveat, and explanation from the input. Do not invent data. Executive summaries must cite concrete values from the returned database data. Always keep the full returned data visible in a Report Data section unless the input has no data. Return only HTML, with inline CSS, and no Markdown fences."
            }
          ]
        },
        {
          role: "USER",
          content: [
            {
              type: "TEXT",
              text: llmPrompt
            }
          ]
        }
      ]
    }
  };

  const response = await client.chat({ chatDetails });
  const text = extractChatText(response.chatResult);
  return {
    ok: true,
    text,
    html: extractHtml(text) || text
  };
}

function getGenAiClient() {
  if (genAiClient) {
    return genAiClient;
  }

  const common = require("oci-common");
  const generativeaiinference = require("oci-generativeaiinference");
  const { authType, configFile, profile } = getOciAuthConfig();
  let authenticationDetailsProvider;

  if (authType === "instance_principal") {
    authenticationDetailsProvider = new common.InstancePrincipalsAuthenticationDetailsProviderBuilder().build();
  } else if (authType === "resource_principal") {
    authenticationDetailsProvider = new common.ResourcePrincipalAuthenticationDetailsProvider();
  } else {
    authenticationDetailsProvider = createConfigFileAuthProvider(common, configFile, profile);
  }

  genAiClient = new generativeaiinference.GenerativeAiInferenceClient({
    authenticationDetailsProvider
  });
  genAiClient.endpoint = llmEndpoint;
  return genAiClient;
}

function getOciAuthConfig() {
  const rawAuthType = String(process.env.OCI_AUTH_TYPE || "config_file").trim();
  let authType = rawAuthType.toLowerCase();
  let configFile = process.env.OCI_CONFIG_FILE || "";

  if (rawAuthType.includes("/") || rawAuthType.includes("\\")) {
    authType = "config_file";
    configFile = rawAuthType;
  }

  return {
    authType,
    configFile: configFile || undefined,
    profile: String(process.env.OCI_PROFILE || "DEFAULT").trim() || "DEFAULT"
  };
}

function createConfigFileAuthProvider(common, configFile, profile) {
  const resolvedConfigFile = expandHome(configFile || path.join("~", ".oci", "config"));
  const content = fs.existsSync(resolvedConfigFile) ? fs.readFileSync(resolvedConfigFile, "utf8") : "";

  if (/^\s*\[[^\]]+\]/m.test(content)) {
    return new common.ConfigFileAuthenticationDetailsProvider(configFile, profile);
  }

  const values = parseSimpleConfig(content);
  const missing = ["tenancy", "user", "fingerprint", "key_file", "region"].filter((key) => !values[key]);
  if (missing.length) {
    throw new Error(`OCI config is missing required values: ${missing.join(", ")}`);
  }

  const privateKey = fs.readFileSync(expandHome(values.key_file), "utf8");
  const region = common.Region.fromRegionId(values.region) || values.region;
  return new common.SimpleAuthenticationDetailsProvider(
    values.tenancy,
    values.user,
    values.fingerprint,
    privateKey,
    values.pass_phrase || values.passphrase || null,
    region
  );
}

function parseSimpleConfig(content) {
  const values = {};
  for (const line of content.split(/\r?\n/)) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith("#") || trimmed.startsWith("[")) {
      continue;
    }

    const index = trimmed.indexOf("=");
    if (index < 1) {
      continue;
    }

    values[trimmed.slice(0, index).trim()] = trimmed.slice(index + 1).trim();
  }
  return values;
}

function expandHome(filePath) {
  if (!filePath) {
    return filePath;
  }
  if (filePath === "~") {
    return process.env.HOME;
  }
  if (filePath.startsWith("~/")) {
    return path.join(process.env.HOME, filePath.slice(2));
  }
  return filePath;
}

function buildRenderPrompt({ prompt, mode, databaseResponse, llmInstructions }) {
  return [
    "Render the following Oracle Database AI result as complete HTML.",
    "",
    `Runtime mode: ${mode === "agent" ? "AI Agent" : "Select AI"}`,
    `User prompt: ${prompt}`,
    "",
    "Rendering requirements:",
    "- Preserve the complete result. Include every returned row and field visible in the source text.",
    "- Start with an Executive Summary or Analysis section that is complete enough to answer the user request using concrete returned values: IDs, names, dates, statuses, amounts, scores, risk levels, counts, and tool outcomes when present.",
    "- Do not write a vague executive summary. Every summary bullet or sentence must be supported by a returned database value visible elsewhere in the report.",
    "- Add a visible section named 'Report Data' after the main narrative. This section must show the full database-returned dataset, not a sample and not only a summary.",
    "- If the database result is JSON or nested text, render it in readable subsections, tables, or preformatted blocks so the source database values are visible in the chat response.",
    "- Do not use the heading 'Complete Database AI response'. If user instructions say to hide that section, hide only that duplicate raw-source heading, not the required Report Data section.",
    "- For tabular data, create a readable HTML table with sticky-looking headers through inline CSS.",
    "- For chart requests, include the chart and a table of the source values below it.",
    "- If the source already contains HTML, repair/wrap it into one complete document without dropping content.",
    "- Use only inline CSS and plain browser-native HTML/CSS/JavaScript.",
    "- Return only HTML. Do not include Markdown, explanations, or code fences.",
    llmInstructions ? "" : null,
    llmInstructions ? "Additional user-provided rendering instructions for this Grok step:" : null,
    llmInstructions || null,
    llmInstructions ? "" : null,
    "Non-negotiable preservation rule: if the source contains 'FSI Third-Party Evidence Summary', render that section visibly, including Weather Evidence and Google Sheet Fraud Score. Do not omit those sections when hiding or summarizing duplicate raw database response sections.",
    "",
    "Oracle Database AI result:",
    databaseResponse
  ].filter((line) => line !== null).join("\n");
}

function extractChatText(chatResult) {
  const chatResponse = chatResult && chatResult.chatResponse;
  const choices = chatResponse && chatResponse.choices;
  if (Array.isArray(choices) && choices.length) {
    return choices.map((choice) => messageToText(choice.message)).filter(Boolean).join("\n\n");
  }

  if (chatResponse && typeof chatResponse.text === "string") {
    return chatResponse.text;
  }

  return valueToString(chatResult);
}

function messageToText(message) {
  if (!message) {
    return "";
  }

  if (typeof message.content === "string") {
    return message.content;
  }

  if (Array.isArray(message.content)) {
    return message.content.map((item) => {
      if (typeof item === "string") {
        return item;
      }
      return item.text || item.content || "";
    }).filter(Boolean).join("\n");
  }

  return message.text || "";
}

function extractHtml(text) {
  if (!text) {
    return "";
  }

  const fenced = text.match(/```html\s*([\s\S]*?)```/i);
  if (fenced) {
    return fenced[1].trim();
  }

  if (/<(?:!doctype\s+html|html|body|table|div|section|article|canvas|svg|style|script)\b/i.test(text)) {
    return text.trim();
  }

  return "";
}
