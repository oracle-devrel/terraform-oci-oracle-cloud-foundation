"use strict";

const loginScreen = document.querySelector("#loginScreen");
const appShell = document.querySelector("#appShell");
const loginForm = document.querySelector("#loginForm");
const loginUsername = document.querySelector("#loginUsername");
const loginPassword = document.querySelector("#loginPassword");
const rememberUsername = document.querySelector("#rememberUsername");
const loginButton = document.querySelector("#loginButton");
const loginStatus = document.querySelector("#loginStatus");
const logoutButton = document.querySelector("#logoutButton");
const changePasswordButton = document.querySelector("#changePasswordButton");
const passwordModal = document.querySelector("#passwordModal");
const passwordForm = document.querySelector("#passwordForm");
const closePasswordModal = document.querySelector("#closePasswordModal");
const currentPassword = document.querySelector("#currentPassword");
const newUserPassword = document.querySelector("#newUserPassword");
const confirmUserPassword = document.querySelector("#confirmUserPassword");
const savePasswordButton = document.querySelector("#savePasswordButton");
const passwordStatus = document.querySelector("#passwordStatus");
const instructionsModal = document.querySelector("#instructionsModal");
const instructionsForm = document.querySelector("#instructionsForm");
const closeInstructionsModal = document.querySelector("#closeInstructionsModal");
const openInstructionsModalButton = document.querySelector("#openInstructionsModalButton");
const instructionDisplay = document.querySelector("#instructionDisplay");
const sidebarInstructionSelect = document.querySelector("#sidebarInstructionSelect");
const htmlSaveModal = document.querySelector("#htmlSaveModal");
const htmlSaveForm = document.querySelector("#htmlSaveForm");
const closeHtmlSaveModal = document.querySelector("#closeHtmlSaveModal");
const htmlReportFilename = document.querySelector("#htmlReportFilename");
const htmlReportFolderSelect = document.querySelector("#htmlReportFolderSelect");
const htmlReportNewFolder = document.querySelector("#htmlReportNewFolder");
const htmlSaveStatus = document.querySelector("#htmlSaveStatus");
const confirmSaveHtmlButton = document.querySelector("#confirmSaveHtmlButton");
const markdownResponseModal = document.querySelector("#markdownResponseModal");
const markdownResponseForm = document.querySelector("#markdownResponseForm");
const closeMarkdownResponseModal = document.querySelector("#closeMarkdownResponseModal");
const markdownResponseFilename = document.querySelector("#markdownResponseFilename");
const markdownResponseStatus = document.querySelector("#markdownResponseStatus");
const confirmUploadResponseMarkdownButton = document.querySelector("#confirmUploadResponseMarkdownButton");
const authUser = document.querySelector("#authUser");
const adminMenu = document.querySelector("#adminMenu");
const mode = document.querySelector("#mode");
const teamName = document.querySelector("#teamName");
const profileName = document.querySelector("#profileName");
const llmProfileControl = document.querySelector("#llmProfileControl");
const runtimeLlmConfigSelect = document.querySelector("#runtimeLlmConfigSelect");
const updateProfileLlmButton = document.querySelector("#updateProfileLlmButton");
const profileLlmStatus = document.querySelector("#profileLlmStatus");
const promptInput = document.querySelector("#prompt");
const llmInstructionSelect = document.querySelector("#llmInstructionSelect");
const llmInstructionName = document.querySelector("#llmInstructionName");
const newInstructionButton = document.querySelector("#newInstructionButton");
const llmInstructions = document.querySelector("#llmInstructions");
const instructionPanel = document.querySelector("#instructionPanel");
const saveInstructionsButton = document.querySelector("#saveInstructionsButton");
const instructionStatus = document.querySelector("#instructionStatus");
const promptForm = document.querySelector("#promptForm");
const runButton = document.querySelector("#runButton");
const clearButton = document.querySelector("#clearButton");
const htmlResponseTime = document.querySelector("#htmlResponseTime");
const runProgress = document.querySelector("#runProgress");
const runProgressFill = document.querySelector("#runProgressFill");
const runProgressText = document.querySelector("#runProgressText");
const runProgressElapsed = document.querySelector("#runProgressElapsed");
const rawOutput = document.querySelector("#rawOutput");
const renderedOutput = document.querySelector("#renderedOutput");
const outputSurface = document.querySelector(".output-surface");
const statusPill = document.querySelector("#statusPill");
const statusText = document.querySelector("#statusText");
const resultTitle = document.querySelector("#resultTitle");
const elapsed = document.querySelector("#elapsed");
const outputStatus = document.querySelector("#outputStatus");
const tabs = document.querySelectorAll(".tabs button");
const askSection = document.querySelector(".ask-section");
const askToggle = document.querySelector("#askToggle");
const responseSection = document.querySelector("#responseSection");
const responseToggle = document.querySelector("#responseToggle");
const openHtmlButton = document.querySelector("#openHtmlButton");
const consoleActionStatus = document.querySelector("#consoleActionStatus");
const saveHtmlButton = document.querySelector("#saveHtmlButton");
const exportPdfButton = document.querySelector("#exportPdfButton");
const uploadResponseMarkdownButton = document.querySelector("#uploadResponseMarkdownButton");
const navButtons = document.querySelectorAll("[data-page-target]");
const pages = document.querySelectorAll("[data-page]");
const refreshAgentsButton = document.querySelector("#refreshAgentsButton");
const refreshManagerButton = document.querySelector("#refreshManagerButton");
const resetBuilderButton = document.querySelector("#resetBuilderButton");
const refreshTopologyButton = document.querySelector("#refreshTopologyButton");
const downloadTopologyButton = document.querySelector("#downloadTopologyButton");
const topologyTeamSelect = document.querySelector("#topologyTeamSelect");
const topologyCanvas = document.querySelector("#topologyCanvas");
const topologyLegend = document.querySelector("#topologyLegend");
const refreshUsersButton = document.querySelector("#refreshUsersButton");
const refreshPromptsButton = document.querySelector("#refreshPromptsButton");
const previousPromptsButton = document.querySelector("#previousPromptsButton");
const nextPromptsButton = document.querySelector("#nextPromptsButton");
const refreshMemoryButton = document.querySelector("#refreshMemoryButton");
const previousMemoryButton = document.querySelector("#previousMemoryButton");
const nextMemoryButton = document.querySelector("#nextMemoryButton");
const refreshRagButton = document.querySelector("#refreshRagButton");
const refreshReportsButton = document.querySelector("#refreshReportsButton");
const refreshProfilesButton = document.querySelector("#refreshProfilesButton");
const refreshConfigButton = document.querySelector("#refreshConfigButton");
const runLatestTaskButton = document.querySelector("#runLatestTaskButton");
const changeDefaultTeamButton = document.querySelector("#changeDefaultTeamButton");
const agentTeamsTable = document.querySelector("#agentTeamsTable");
const agentsTable = document.querySelector("#agentsTable");
const managerToolsTable = document.querySelector("#managerToolsTable");
const managerTasksTable = document.querySelector("#managerTasksTable");
const managerAgentsTable = document.querySelector("#managerAgentsTable");
const managerTeamsTable = document.querySelector("#managerTeamsTable");
const managerSelectProfilesTable = document.querySelector("#managerSelectProfilesTable");
const managerRagProfilesTable = document.querySelector("#managerRagProfilesTable");
const builderToolForm = document.querySelector("#builderToolForm");
const builderTaskForm = document.querySelector("#builderTaskForm");
const builderAgentForm = document.querySelector("#builderAgentForm");
const builderTeamForm = document.querySelector("#builderTeamForm");
const builderSelectProfileForm = document.querySelector("#builderSelectProfileForm");
const builderRagProfileForm = document.querySelector("#builderRagProfileForm");
const builderToolName = document.querySelector("#builderToolName");
const builderToolDescription = document.querySelector("#builderToolDescription");
const builderToolAttributes = document.querySelector("#builderToolAttributes");
const builderTaskName = document.querySelector("#builderTaskName");
const builderTaskDescription = document.querySelector("#builderTaskDescription");
const builderTaskAttributes = document.querySelector("#builderTaskAttributes");
const builderAgentName = document.querySelector("#builderAgentName");
const builderAgentDescription = document.querySelector("#builderAgentDescription");
const builderAgentAttributes = document.querySelector("#builderAgentAttributes");
const builderTeamName = document.querySelector("#builderTeamName");
const builderTeamDescription = document.querySelector("#builderTeamDescription");
const builderTeamAttributes = document.querySelector("#builderTeamAttributes");
const builderSelectProfileName = document.querySelector("#builderSelectProfileName");
const builderSelectProfileDescription = document.querySelector("#builderSelectProfileDescription");
const builderSelectProfileAttributes = document.querySelector("#builderSelectProfileAttributes");
const builderRagProfileName = document.querySelector("#builderRagProfileName");
const builderRagProfileDescription = document.querySelector("#builderRagProfileDescription");
const builderRagProfileAttributes = document.querySelector("#builderRagProfileAttributes");
const usersTable = document.querySelector("#usersTable");
const userForm = document.querySelector("#userForm");
const newUsername = document.querySelector("#newUsername");
const newDisplayName = document.querySelector("#newDisplayName");
const newPassword = document.querySelector("#newPassword");
const newRole = document.querySelector("#newRole");
const saveUserButton = document.querySelector("#saveUserButton");
const refreshLinksButton = document.querySelector("#refreshLinksButton");
const linkForm = document.querySelector("#linkForm");
const newLinkName = document.querySelector("#newLinkName");
const newLinkUrl = document.querySelector("#newLinkUrl");
const saveLinkButton = document.querySelector("#saveLinkButton");
const linksTable = document.querySelector("#linksTable");
const mcpTesterForm = document.querySelector("#mcpTesterForm");
const mcpAction = document.querySelector("#mcpAction");
const mcpNaturalPrompt = document.querySelector("#mcpNaturalPrompt");
const mcpProfileName = document.querySelector("#mcpProfileName");
const mcpToolName = document.querySelector("#mcpToolName");
const mcpArguments = document.querySelector("#mcpArguments");
const runMcpTesterButton = document.querySelector("#runMcpTesterButton");
const mcpResponseOutput = document.querySelector("#mcpResponseOutput");
const latestTaskTable = document.querySelector("#latestTaskTable");
const promptsTable = document.querySelector("#promptsTable");
const memoryTable = document.querySelector("#memoryTable");
const ragPipelinesTable = document.querySelector("#ragPipelinesTable");
const ragAttributesTable = document.querySelector("#ragAttributesTable");
const ragObjectsTable = document.querySelector("#ragObjectsTable");
const ragHistoryTable = document.querySelector("#ragHistoryTable");
const reportsLayout = document.querySelector("#reportsLayout");
const reportsFileList = document.querySelector("#reportsFileList");
const reportsPdfFrame = document.querySelector("#reportsPdfFrame");
const reportsSelectedName = document.querySelector("#reportsSelectedName");
const toggleReportsBrowserButton = document.querySelector("#toggleReportsBrowserButton");
const newReportsFolderButton = document.querySelector("#newReportsFolderButton");
const uploadReportsKnowledgeButton = document.querySelector("#uploadReportsKnowledgeButton");
const selectedReportsFolderLabel = document.querySelector("#selectedReportsFolder");
const refreshMarkdownUploadButton = document.querySelector("#refreshMarkdownUploadButton");
const markdownUploadForm = document.querySelector("#markdownUploadForm");
const markdownFile = document.querySelector("#markdownFile");
const uploadMarkdownButton = document.querySelector("#uploadMarkdownButton");
const markdownUploadLocation = document.querySelector("#markdownUploadLocation");
const profilesTable = document.querySelector("#profilesTable");
const configTable = document.querySelector("#configTable");
const agentTeamsCount = document.querySelector("#agentTeamsCount");
const agentsCount = document.querySelector("#agentsCount");
const managerToolsCount = document.querySelector("#managerToolsCount");
const managerTasksCount = document.querySelector("#managerTasksCount");
const managerAgentsCount = document.querySelector("#managerAgentsCount");
const managerTeamsCount = document.querySelector("#managerTeamsCount");
const managerSelectProfilesCount = document.querySelector("#managerSelectProfilesCount");
const managerRagProfilesCount = document.querySelector("#managerRagProfilesCount");
const usersCount = document.querySelector("#usersCount");
const linksCount = document.querySelector("#linksCount");
const promptsCount = document.querySelector("#promptsCount");
const promptsPageText = document.querySelector("#promptsPageText");
const memoryCount = document.querySelector("#memoryCount");
const memoryPageText = document.querySelector("#memoryPageText");
const memoryTableName = document.querySelector("#memoryTableName");
const ragPipelinesCount = document.querySelector("#ragPipelinesCount");
const ragAttributesCount = document.querySelector("#ragAttributesCount");
const ragObjectsCount = document.querySelector("#ragObjectsCount");
const ragHistoryCount = document.querySelector("#ragHistoryCount");
const reportsCount = document.querySelector("#reportsCount");
const profilesCount = document.querySelector("#profilesCount");
const agentsStatus = document.querySelector("#agentsStatus");
const managerStatus = document.querySelector("#managerStatus");
const builderStatus = document.querySelector("#builderStatus");
const topologyStatus = document.querySelector("#topologyStatus");
const usersStatus = document.querySelector("#usersStatus");
const linksStatus = document.querySelector("#linksStatus");
const mcpTesterStatus = document.querySelector("#mcpTesterStatus");
const latestTaskStatus = document.querySelector("#latestTaskStatus");
const promptsStatus = document.querySelector("#promptsStatus");
const memoryStatus = document.querySelector("#memoryStatus");
const ragStatus = document.querySelector("#ragStatus");
const ragStorageLocation = document.querySelector("#ragStorageLocation");
const reportsStatus = document.querySelector("#reportsStatus");
const reportsUploadConfirmation = document.querySelector("#reportsUploadConfirmation");
const markdownUploadStatus = document.querySelector("#markdownUploadStatus");
const profilesStatus = document.querySelector("#profilesStatus");
let renderedBlobUrl = "";
let currentRenderedHtml = "";
let lastPromptPayload = null;
let publicConfig = {};
let agentsLoaded = false;
let managerLoaded = false;
let builderLoaded = false;
let topologyLoaded = false;
let topologyData = null;
let usersLoaded = false;
let linksLoaded = false;
let promptsLoaded = false;
let memoryLoaded = false;
let ragLoaded = false;
let reportsLoaded = false;
let reportsFiles = [];
let reportsFolders = [];
let selectedReportFile = null;
let selectedReportsFolder = localStorage.getItem("dtc-selected-reports-folder") || "";
let markdownUploadLoaded = false;
let profilesLoaded = false;
let selectedAgentTeamName = "";
let currentDefaultTeamName = "";
let latestTaskRows = [];
let selectedDatabaseConfigName = "";
let selectedLlmConfigName = "";
let llmInstructionProfiles = [];
let selectedLlmInstructionName = localStorage.getItem("dtc-llm-instruction-name") || "";
let progressTimer = 0;
let progressHideTimer = 0;
let runStatusTimer = 0;
let runStatusPollInFlight = false;
let activeRunStatusRequestId = "";
const promptsPageSize = 10;
let promptsOffset = 0;
let promptsTotal = 0;
const memoryPageSize = 10;
let memoryOffset = 0;
let memoryTotal = 0;
let currentUser = null;

const emptyHtml = `
<!doctype html>
<html>
  <head>
    <style>
      body {
        margin: 0;
        padding: 24px;
        color: #64748b;
        font: 15px/1.5 "Oracle Sans", "OracleSans", "Redwood", system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
        background: #fff;
      }
    </style>
  </head>
  <body>Run a prompt to render database HTML output here.</body>
</html>`;

setRenderedHtml(emptyHtml);

init();

async function init() {
  loginForm.addEventListener("submit", login);
  logoutButton.addEventListener("click", logout);
  changePasswordButton.addEventListener("click", openPasswordModal);
  closePasswordModal.addEventListener("click", closePasswordDialog);
  passwordForm.addEventListener("submit", changePassword);
  passwordModal.addEventListener("click", (event) => {
    if (event.target === passwordModal) {
      closePasswordDialog();
    }
  });
  openInstructionsModalButton.addEventListener("click", openInstructionsDialog);
  closeInstructionsModal.addEventListener("click", closeInstructionsDialog);
  instructionsForm.addEventListener("submit", saveInstructions);
  instructionsModal.addEventListener("click", (event) => {
    if (event.target === instructionsModal) {
      closeInstructionsDialog();
    }
  });
  hydrateRememberedUsername();
  navButtons.forEach((button) => {
    button.addEventListener("click", () => setPage(button.dataset.pageTarget));
  });

  tabs.forEach((button) => {
    button.addEventListener("click", () => setView(button.dataset.view));
  });

  askToggle.addEventListener("click", () => {
    setAskCollapsed(!askSection.classList.contains("is-collapsed"));
  });
  setAskCollapsed(localStorage.getItem("dtc-ask-collapsed") === "true");

  responseToggle.addEventListener("click", () => {
    setResponseCollapsed(!responseSection.classList.contains("is-collapsed"));
  });
  setResponseCollapsed(localStorage.getItem("dtc-response-collapsed") === "true");

  openHtmlButton.addEventListener("click", openRenderedHtml);
  saveHtmlButton.addEventListener("click", saveRenderedHtmlReport);
  htmlSaveForm.addEventListener("submit", submitHtmlSaveDialog);
  closeHtmlSaveModal.addEventListener("click", () => closeHtmlSaveDialog(null));
  htmlSaveModal.addEventListener("click", (event) => {
    if (event.target === htmlSaveModal) {
      closeHtmlSaveDialog(null);
    }
  });
  htmlReportNewFolder.addEventListener("input", () => {
    htmlReportFolderSelect.disabled = Boolean(htmlReportNewFolder.value.trim());
  });
  exportPdfButton.addEventListener("click", exportRenderedPdf);
  uploadResponseMarkdownButton.addEventListener("click", openResponseMarkdownDialog);
  markdownResponseForm.addEventListener("submit", uploadResponseMarkdown);
  closeMarkdownResponseModal.addEventListener("click", closeResponseMarkdownDialog);
  markdownResponseModal.addEventListener("click", (event) => {
    if (event.target === markdownResponseModal) {
      closeResponseMarkdownDialog();
    }
  });
  uploadResponseMarkdownButton.disabled = true;

  clearButton.addEventListener("click", () => {
    promptInput.value = "";
    lastPromptPayload = null;
    rawOutput.textContent = "";
    htmlResponseTime.textContent = "";
    setRenderedHtml(emptyHtml);
    resultTitle.textContent = "Ready";
    elapsed.textContent = "";
    uploadResponseMarkdownButton.disabled = true;
  });

  llmInstructions.value = localStorage.getItem("dtc-llm-instructions") || "";
  llmInstructionName.value = selectedLlmInstructionName;
  updateInstructionDisplay(llmInstructions.value);
  llmInstructions.addEventListener("input", () => {
    localStorage.setItem("dtc-llm-instructions", llmInstructions.value);
    syncCurrentInstructionDraft();
  });
  llmInstructionName.addEventListener("input", () => {
    selectedLlmInstructionName = llmInstructionName.value.trim();
  });
  llmInstructionSelect.addEventListener("change", () => selectLlmInstructionProfile(llmInstructionSelect.value));
  sidebarInstructionSelect.addEventListener("change", () => selectLlmInstructionProfile(sidebarInstructionSelect.value));
  newInstructionButton.addEventListener("click", startNewInstructionProfile);

  promptForm.addEventListener("submit", runPrompt);
  refreshAgentsButton.addEventListener("click", loadAgents);
  refreshManagerButton.addEventListener("click", loadManager);
  resetBuilderButton.addEventListener("click", hydrateBuilderDefaults);
  [builderToolForm, builderTaskForm, builderAgentForm, builderTeamForm, builderSelectProfileForm, builderRagProfileForm].forEach((form) => {
    form.addEventListener("submit", saveBuilderItem);
  });
  refreshTopologyButton.addEventListener("click", loadTopology);
  topologyTeamSelect.addEventListener("change", renderSelectedTopology);
  downloadTopologyButton.addEventListener("click", downloadTopologyPng);
  refreshUsersButton.addEventListener("click", loadUsers);
  userForm.addEventListener("submit", saveUser);
  refreshLinksButton.addEventListener("click", loadLinks);
  linkForm.addEventListener("submit", saveLink);
  mcpTesterForm.addEventListener("submit", runMcpTester);
  mcpAction.addEventListener("change", updateMcpTesterDefaults);
  updateMcpTesterDefaults();
  refreshPromptsButton.addEventListener("click", () => loadPrompts(0));
  previousPromptsButton.addEventListener("click", () => loadPrompts(Math.max(0, promptsOffset - promptsPageSize)));
  nextPromptsButton.addEventListener("click", () => loadPrompts(promptsOffset + promptsPageSize));
  refreshMemoryButton.addEventListener("click", () => loadMemory(0));
  previousMemoryButton.addEventListener("click", () => loadMemory(Math.max(0, memoryOffset - memoryPageSize)));
  nextMemoryButton.addEventListener("click", () => loadMemory(memoryOffset + memoryPageSize));
  refreshRagButton.addEventListener("click", loadRag);
  refreshReportsButton.addEventListener("click", loadReports);
  newReportsFolderButton.addEventListener("click", createReportsFolder);
  uploadReportsKnowledgeButton.addEventListener("click", uploadSelectedReportToRag);
  toggleReportsBrowserButton.addEventListener("click", () => {
    setReportsBrowserCollapsed(!reportsLayout.classList.contains("is-browser-collapsed"));
  });
  updateSelectedReportsFolderLabel();
  setReportsBrowserCollapsed(localStorage.getItem("dtc-reports-browser-collapsed") === "true");
  refreshMarkdownUploadButton.addEventListener("click", loadMarkdownUploadConfig);
  markdownUploadForm.addEventListener("submit", uploadMarkdownFile);
  refreshProfilesButton.addEventListener("click", loadProfiles);
  refreshConfigButton.addEventListener("click", loadConfig);
  updateProfileLlmButton.addEventListener("click", updateSelectAiProfileLlm);
  runLatestTaskButton.addEventListener("click", runLatestTeamTaskExecution);
  changeDefaultTeamButton.addEventListener("click", changeDefaultAgentTeam);
  latestTaskTable.addEventListener("click", handleLatestTaskRowClick);

  const authenticated = await loadAuthState();
  if (!authenticated) {
    showLogin();
    return;
  }

  await loadConfig();
  await loadSavedInstructions();
  await checkHealth();
}

async function loadAuthState() {
  try {
    const response = await fetch("/api/auth/me");
    const payload = await response.json();
    if (payload.authenticated && payload.user) {
      currentUser = payload.user;
      showApplication();
      return true;
    }
  } catch {
    currentUser = null;
  }
  return false;
}

async function login(event) {
  event.preventDefault();
  loginButton.disabled = true;
  loginStatus.textContent = "Signing in...";

  try {
    const response = await fetch("/api/auth/login", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        username: loginUsername.value,
        password: loginPassword.value
      })
    });
    const payload = await response.json();
    if (!response.ok || !payload.ok) {
      throw new Error(payload.error || "Login failed");
    }

    currentUser = payload.user;
    saveRememberedUsername();
    loginPassword.value = "";
    showApplication();
    await loadConfig();
    await loadSavedInstructions();
    await checkHealth();
  } catch (error) {
    loginStatus.textContent = error.message;
  } finally {
    loginButton.disabled = false;
  }
}

async function logout() {
  await fetch("/api/auth/logout", { method: "POST" }).catch(() => undefined);
  currentUser = null;
  showLogin();
}

function showLogin() {
  loginScreen.hidden = false;
  appShell.hidden = true;
  loginStatus.textContent = "";
  hydrateRememberedUsername();
  loginUsername.focus();
}

function showApplication() {
  loginScreen.hidden = true;
  appShell.hidden = false;
  const role = currentUser && currentUser.role || "User";
  authUser.textContent = `${currentUser.displayName || currentUser.username} (${role})`;
  const admin = isCurrentUserAdmin();
  adminMenu.hidden = !admin;
  if (llmProfileControl) {
    llmProfileControl.hidden = !admin;
  }
  if (uploadResponseMarkdownButton) {
    uploadResponseMarkdownButton.hidden = !admin;
    uploadResponseMarkdownButton.disabled = !admin || !lastPromptPayload;
  }
  if (!admin) {
    setPage("console");
  }
}

function isCurrentUserAdmin() {
  return Boolean(currentUser && currentUser.role === "Admin");
}

function hydrateRememberedUsername() {
  const remembered = localStorage.getItem("dtc-remembered-username") || "";
  if (remembered && !loginUsername.value) {
    loginUsername.value = remembered;
  }
  rememberUsername.checked = Boolean(remembered);
}

function saveRememberedUsername() {
  if (rememberUsername.checked) {
    localStorage.setItem("dtc-remembered-username", loginUsername.value.trim());
  } else {
    localStorage.removeItem("dtc-remembered-username");
  }
}

function openPasswordModal() {
  passwordForm.reset();
  passwordStatus.textContent = "";
  passwordModal.hidden = false;
  currentPassword.focus();
}

function closePasswordDialog() {
  passwordModal.hidden = true;
  passwordForm.reset();
  passwordStatus.textContent = "";
}

function openInstructionsDialog() {
  instructionStatus.textContent = "";
  instructionsModal.hidden = false;
  llmInstructions.focus();
}

function closeInstructionsDialog() {
  instructionsModal.hidden = true;
  instructionStatus.textContent = "";
}

async function changePassword(event) {
  event.preventDefault();
  savePasswordButton.disabled = true;
  passwordStatus.textContent = "Saving password...";

  try {
    const response = await fetch("/api/auth/change-password", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        currentPassword: currentPassword.value,
        newPassword: newUserPassword.value,
        confirmPassword: confirmUserPassword.value
      })
    });
    const payload = await response.json();
    if (!response.ok || !payload.ok) {
      throw new Error(payload.error || payload.detail || "Could not change password");
    }

    passwordStatus.textContent = "Password changed.";
    passwordForm.reset();
    window.setTimeout(closePasswordDialog, 700);
  } catch (error) {
    passwordStatus.textContent = error.message;
  } finally {
    savePasswordButton.disabled = false;
  }
}

async function loadConfig() {
  const response = await fetch("/api/config");
  const config = await response.json();
  publicConfig = config;
  teamName.value = config.teamName || "";
  profileName.value = config.profileName || "";
  if (mcpProfileName && !mcpProfileName.value) {
    mcpProfileName.value = config.profileName || "";
  }
  renderRuntimeLlmOptions(config);
  renderConfig(config);
}

async function loadSavedInstructions() {
  const localInstructions = localStorage.getItem("dtc-llm-instructions") || "";
  try {
    const response = await fetch("/api/llm-instructions");
    const payload = await response.json();
    if (!response.ok || !payload.ok) {
      throw new Error(payload.detail || payload.error || "Could not load saved instructions");
    }

    llmInstructionProfiles = Array.isArray(payload.profiles) ? payload.profiles : [];
    const savedName = localStorage.getItem("dtc-llm-instruction-name") || "";
    const initialName = llmInstructionProfiles.some((profile) => profile.name === savedName)
      ? savedName
      : payload.instructionName || payload.defaultInstruction || llmInstructionProfiles[0] && llmInstructionProfiles[0].name || "";
    renderInstructionProfileOptions(initialName);
    if (initialName) {
      selectLlmInstructionProfile(initialName);
    } else {
      llmInstructions.value = payload.instructions || localInstructions;
      llmInstructionName.value = "";
      localStorage.setItem("dtc-llm-instructions", llmInstructions.value);
      updateInstructionDisplay(llmInstructions.value, "");
    }
  } catch {
    llmInstructionProfiles = [];
    renderInstructionProfileOptions("");
    llmInstructions.value = localInstructions;
    updateInstructionDisplay(llmInstructions.value, selectedLlmInstructionName);
  }
}

function renderInstructionProfileOptions(selectedName) {
  const options = llmInstructionProfiles.map((profile) => {
    const label = profile.name === selectedName ? `${profile.name} (active)` : profile.name;
    return `<option value="${escapeHtml(profile.name)}"${profile.name === selectedName ? " selected" : ""}>${escapeHtml(label)}</option>`;
  }).join("");
  const emptyLabel = llmInstructionProfiles.length ? "New instruction" : "No saved instructions";
  const emptyOption = `<option value=""${selectedName ? "" : " selected"}>${emptyLabel}</option>`;
  llmInstructionSelect.innerHTML = `${selectedName ? "" : emptyOption}${options}`;
  sidebarInstructionSelect.innerHTML = `${selectedName ? "" : emptyOption}${options}`;
}

function selectLlmInstructionProfile(name) {
  const profile = llmInstructionProfiles.find((item) => item.name === name);
  selectedLlmInstructionName = profile ? profile.name : "";
  llmInstructionName.value = selectedLlmInstructionName;
  llmInstructions.value = profile ? profile.instructions || "" : "";
  localStorage.setItem("dtc-llm-instruction-name", selectedLlmInstructionName);
  localStorage.setItem("dtc-llm-instructions", llmInstructions.value);
  renderInstructionProfileOptions(selectedLlmInstructionName);
  updateInstructionDisplay(llmInstructions.value, selectedLlmInstructionName);
}

function syncCurrentInstructionDraft() {
  localStorage.setItem("dtc-llm-instructions", llmInstructions.value);
  const name = llmInstructionName.value.trim() || selectedLlmInstructionName;
  const index = llmInstructionProfiles.findIndex((profile) => profile.name === name);
  if (index >= 0) {
    llmInstructionProfiles[index] = {
      ...llmInstructionProfiles[index],
      instructions: llmInstructions.value
    };
  }
  updateInstructionDisplay(llmInstructions.value, name);
}

function startNewInstructionProfile() {
  selectedLlmInstructionName = "";
  llmInstructionName.value = "";
  llmInstructions.value = "";
  instructionStatus.textContent = "";
  renderInstructionProfileOptions("");
  updateInstructionDisplay("", "");
  llmInstructionName.focus();
}

function updateInstructionDisplay(value, name) {
  const text = String(value || "").trim();
  const label = String(name || "").trim();
  instructionDisplay.textContent = text
    ? `${label ? `${label}\n\n` : ""}${text}`
    : "No custom instructions saved.";
  instructionDisplay.classList.toggle("is-empty", !text);
}

function renderRuntimeLlmOptions(config) {
  const runtime = config.runtimeConfig || {};
  const llms = runtime.llmConfigs || [];
  runtimeLlmConfigSelect.innerHTML = llms.map((llm) => {
    const label = llm.isDefault ? `${llm.name} (default)` : llm.name;
    return `<option value="${escapeHtml(llm.name)}"${llm.name === runtime.defaultLlm ? " selected" : ""}>${escapeHtml(label)}</option>`;
  }).join("");
  updateProfileLlmButton.disabled = !llms.length || !isCurrentUserAdmin();
  profileLlmStatus.textContent = llms.length ? "" : "No LLM configurations found.";
}

async function updateSelectAiProfileLlm() {
  const llmName = runtimeLlmConfigSelect.value;
  const selectedProfileName = profileName.value.trim() || publicConfig.profileName || "";

  if (!llmName) {
    profileLlmStatus.textContent = "Select an LLM configuration.";
    return;
  }
  if (!selectedProfileName) {
    profileLlmStatus.textContent = "Enter a Select AI profile name.";
    return;
  }

  updateProfileLlmButton.disabled = true;
  profileLlmStatus.textContent = "Updating Select AI profile...";

  try {
    const response = await fetch("/api/select-ai-profile-llm", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        profileName: selectedProfileName,
        llmName
      })
    });
    const payload = await response.json();
    if (!response.ok || !payload.ok) {
      throw new Error(payload.detail || payload.error || "Could not update Select AI profile");
    }

    profileLlmStatus.textContent = payload.message || `Profile ${selectedProfileName} updated.`;
    mode.value = "select-ai";
    profilesLoaded = false;
  } catch (error) {
    profileLlmStatus.textContent = error.message;
  } finally {
    updateProfileLlmButton.disabled = false;
  }
}

async function checkHealth() {
  try {
    const response = await fetch("/api/health");
    const payload = await response.json();
    if (!response.ok || !payload.ok) {
      throw new Error(payload.detail || payload.error || "Database unavailable");
    }
    statusPill.className = "status-pill ok";
    statusText.textContent = `Connected as ${payload.connectionName || payload.username}`;
  } catch (error) {
    statusPill.className = "status-pill error";
    statusText.textContent = "Database not connected";
    rawOutput.textContent = error.message;
    resultTitle.textContent = "Connection needs attention";
  }
}

function setPage(pageName) {
  if (pageName !== "console" && !isCurrentUserAdmin()) {
    pageName = "console";
  }
  if ("open" in adminMenu) {
    adminMenu.open = false;
  }
  navButtons.forEach((button) => {
    button.classList.toggle("active", button.dataset.pageTarget === pageName);
  });
  adminMenu.classList.toggle("active", pageName !== "console");
  pages.forEach((page) => {
    page.classList.toggle("active", page.dataset.page === pageName);
  });

  if (pageName === "agents" && !agentsLoaded) {
    loadAgents();
  }
  if (pageName === "manager" && !managerLoaded) {
    loadManager();
  }
  if (pageName === "builder" && !builderLoaded) {
    hydrateBuilderDefaults();
  }
  if (pageName === "topology" && !topologyLoaded) {
    loadTopology();
  }
  if (pageName === "users" && !usersLoaded) {
    loadUsers();
  }
  if (pageName === "links" && !linksLoaded) {
    loadLinks();
  }
  if (pageName === "prompts" && !promptsLoaded) {
    loadPrompts(0);
  }
  if (pageName === "memory" && !memoryLoaded) {
    loadMemory(0);
  }
  if (pageName === "rag" && !ragLoaded) {
    loadRag();
  }
  if (pageName === "reports" && !reportsLoaded) {
    loadReports();
  }
  if (pageName === "markdown-upload" && !markdownUploadLoaded) {
    loadMarkdownUploadConfig();
  }
  if (pageName === "profiles" && !profilesLoaded) {
    loadProfiles();
  }
  if (pageName === "configuration") {
    renderConfig(publicConfig);
  }
}

async function loadAgents() {
  refreshAgentsButton.disabled = true;
  agentsStatus.textContent = "Loading...";

  try {
    const response = await fetch("/api/ai-agents");
    const payload = await response.json();
    if (!response.ok || !payload.ok) {
      throw new Error(payload.detail || payload.error || "Could not load AI agents");
    }

    renderMetadataTable(agentTeamsTable, payload.teams, {
      emptyText: "No AI agent teams found.",
      defaultName: payload.defaultTeam,
      radioName: "agentTeam",
      selectedName: selectedAgentTeamName || payload.defaultTeam,
      onSelect: selectAgentTeam
    });
    renderMetadataTable(agentsTable, payload.agents, {
      emptyText: "No AI agents found."
    });
    agentTeamsCount.textContent = String((payload.teams && payload.teams.rows || []).length);
    agentsCount.textContent = String((payload.agents && payload.agents.rows || []).length);
    currentDefaultTeamName = payload.defaultTeam || "";
    agentsStatus.textContent = payload.teams && payload.teams.available || payload.agents && payload.agents.available
      ? "Loaded"
      : "AI agent metadata views are not available for this user.";
    updateLatestTaskControls();
    agentsLoaded = true;
  } catch (error) {
    agentTeamsTable.innerHTML = "";
    agentsTable.innerHTML = "";
    latestTaskTable.innerHTML = "";
    latestTaskRows = [];
    agentTeamsCount.textContent = "0";
    agentsCount.textContent = "0";
    selectedAgentTeamName = "";
    currentDefaultTeamName = "";
    updateLatestTaskControls();
    agentsStatus.textContent = error.message;
  } finally {
    refreshAgentsButton.disabled = false;
  }
}

async function loadManager() {
  refreshManagerButton.disabled = true;
  managerStatus.textContent = "Loading...";

  try {
    const response = await fetch("/api/ai-manager");
    const payload = await response.json();
    if (!response.ok || !payload.ok) {
      throw new Error(payload.detail || payload.error || "Could not load AI manager metadata");
    }

    renderManagerTable(managerToolsTable, payload.tools, "Tool", "TOOL_NAME", "No AI tools found.");
    renderManagerTable(managerTasksTable, payload.tasks, "Task", "TASK_NAME", "No AI tasks found.");
    renderManagerTable(managerAgentsTable, payload.agents, "Agent", "AGENT_NAME", "No AI agents found.");
    renderManagerTable(managerTeamsTable, payload.teams, "Team", getManagerTeamNameColumn(payload.teams), "No AI teams found.");
    renderManagerTable(managerSelectProfilesTable, payload.selectProfiles, "Profile", "PROFILE_NAME", "No Select AI profiles found.");
    renderManagerTable(managerRagProfilesTable, payload.ragProfiles, "Profile", "PROFILE_NAME", "No RAG profiles found.");

    managerToolsCount.textContent = String((payload.tools && payload.tools.rows || []).length);
    managerTasksCount.textContent = String((payload.tasks && payload.tasks.rows || []).length);
    managerAgentsCount.textContent = String((payload.agents && payload.agents.rows || []).length);
    managerTeamsCount.textContent = String((payload.teams && payload.teams.rows || []).length);
    managerSelectProfilesCount.textContent = String((payload.selectProfiles && payload.selectProfiles.rows || []).length);
    managerRagProfilesCount.textContent = String((payload.ragProfiles && payload.ragProfiles.rows || []).length);
    managerStatus.textContent = "Loaded AI tools, tasks, agents, teams, and profiles.";
    managerLoaded = true;
  } catch (error) {
    managerToolsTable.innerHTML = "";
    managerTasksTable.innerHTML = "";
    managerAgentsTable.innerHTML = "";
    managerTeamsTable.innerHTML = "";
    managerSelectProfilesTable.innerHTML = "";
    managerRagProfilesTable.innerHTML = "";
    managerToolsCount.textContent = "0";
    managerTasksCount.textContent = "0";
    managerAgentsCount.textContent = "0";
    managerTeamsCount.textContent = "0";
    managerSelectProfilesCount.textContent = "0";
    managerRagProfilesCount.textContent = "0";
    managerStatus.textContent = error.message;
  } finally {
    refreshManagerButton.disabled = false;
  }
}

function renderManagerTable(container, metadata, itemType, nameColumn, emptyText) {
  const rows = metadata && metadata.rows || [];
  const columns = metadata && metadata.columns || [];

  if (!metadata || !metadata.available) {
    container.innerHTML = `<div class="empty-state">${escapeHtml(metadata && metadata.viewName || "Metadata view")} is not available.</div>`;
    return;
  }

  if (!rows.length) {
    container.innerHTML = `<div class="empty-state">${escapeHtml(emptyText)}</div>`;
    return;
  }

  const header = [
    ...columns.map((column) => `<th>${formatTableHeader(column)}</th>`),
    `<th>${formatTableHeader("Action")}</th>`
  ].join("");
  const body = rows.map((row) => {
    const itemName = row[nameColumn] || getMetadataName(row);
    const cells = columns.map((column) => `<td>${escapeHtml(row[column] || "")}</td>`).join("");
    return `
      <tr>
        ${cells}
        <td><button type="button" class="danger-link" data-manager-type="${escapeHtml(itemType)}" data-manager-name="${escapeHtml(itemName)}">Delete</button></td>
      </tr>`;
  }).join("");

  container.innerHTML = `
    <table>
      <thead><tr>${header}</tr></thead>
      <tbody>${body}</tbody>
    </table>`;

  container.querySelectorAll("[data-manager-type]").forEach((button) => {
    button.addEventListener("click", () => deleteManagerItem(button.dataset.managerType, button.dataset.managerName));
  });
}

async function deleteManagerItem(itemType, itemName) {
  const confirmed = window.confirm(`Delete ${itemType} "${itemName}"? This action uses force delete.`);
  if (!confirmed) {
    return;
  }

  managerStatus.textContent = `Deleting ${itemType} ${itemName}...`;

  try {
    const response = await fetch("/api/ai-manager/delete", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ itemType, itemName })
    });
    const payload = await response.json();
    if (!response.ok || !payload.ok) {
      throw new Error(payload.detail || payload.error || `Could not delete ${itemType}`);
    }

    managerStatus.textContent = payload.status || `${itemName} deleted.`;
    await loadManager();
  } catch (error) {
    managerStatus.textContent = error.message;
  }
}

function hydrateBuilderDefaults() {
  builderToolName.value = "dtc_select_ai_sql_tool";
  builderToolDescription.value = "Use Select AI to query GRID_DATA_COMPARISON for event sponsorship program data.";
  builderToolAttributes.value = JSON.stringify({
    tool_type: "SQL",
    tool_params: {
      profile_name: profileName.value || publicConfig.profileName || "dtc_select_ai_hub_nl2sql"
    }
  }, null, 2);

  builderTaskName.value = "dtc_ai_sql_rag_search_task";
  builderTaskDescription.value = "Routes each user request to DTC database search, RAG search, user memory, or a combination.";
  builderTaskAttributes.value = JSON.stringify({
    instruction: "Answer the user request using the correct tool or tools. Use the SQL tool for database questions, the RAG tool for knowledge-base questions, and memory tools for user context. User request: {query}",
    tools: [
      "dtc_select_ai_sql_tool",
      "dtc_rag_kb_tool",
      "dtc_store_user_memory_tool",
      "dtc_recall_user_memory_tool"
    ],
    enable_human_tool: "false"
  }, null, 2);

  builderAgentName.value = "dtc_ai_agent";
  builderAgentDescription.value = "Agent that searches GRID_DATA_COMPARISON, DTC RAG knowledge base documents, and DTC user memory.";
  builderAgentAttributes.value = JSON.stringify({
    profile_name: profileName.value || publicConfig.profileName || "dtc_select_ai_hub_nl2sql",
    role: "You are the DTC event sponsorship search agent. Answer questions using structured database data, knowledge base documents, and stored user memory. Use the SQL tool for rows, counts, filters, program details, fiscal years, funding organizations, regions, pipeline, ARR, and values from GRID_DATA_COMPARISON. Use the RAG tool for field interpretation, event sponsorship definitions, FAQ guidance, and documents stored in OCI Object Storage. Do not invent data."
  }, null, 2);

  builderTeamName.value = teamName.value || publicConfig.teamName || "dtc_ai_team";
  builderTeamDescription.value = "Team containing the DTC database and RAG search agent.";
  builderTeamAttributes.value = JSON.stringify({
    agents: [
      {
        name: "dtc_ai_agent",
        task: "dtc_ai_sql_rag_search_task"
      }
    ],
    process: "sequential"
  }, null, 2);

  builderSelectProfileName.value = publicConfig.profileName || "dtc_select_ai_hub_nl2sql";
  builderSelectProfileDescription.value = "Select AI NL2SQL profile for GRID_DATA_COMPARISON.";
  builderSelectProfileAttributes.value = JSON.stringify({
    provider: "oci",
    region: "us-ashburn-1",
    credential_name: "oci",
    model: publicConfig.llmModelId || "xai.grok-4-1-fast-reasoning",
    oci_apiformat: "GENERIC",
    comments: "true",
    temperature: 0,
    object_list: [
      {
        owner: "YOUR_SCHEMA",
        name: "GRID_DATA_COMPARISON"
      }
    ]
  }, null, 2);

  builderRagProfileName.value = "dtc_select_ai_rag_kb_profile";
  builderRagProfileDescription.value = "Select AI RAG profile for the DTC knowledge base vector index.";
  builderRagProfileAttributes.value = JSON.stringify({
    provider: "oci",
    credential_name: "oci",
    region: "us-chicago-1",
    oci_compartment_id: "",
    oci_apiformat: "GENERIC",
    vector_index_name: "dtc_hub_vector_index_kb",
    embedding_model: "cohere.embed-multilingual-v3.0",
    model: "meta.llama-4-maverick-17b-128e-instruct-fp8",
    max_tokens: 2000,
    temperature: 0
  }, null, 2);

  builderStatus.textContent = "Loaded defaults for AI profiles, tools, tasks, agents, and teams.";
  builderLoaded = true;
}

async function saveBuilderItem(event) {
  event.preventDefault();
  const form = event.currentTarget;
  const itemType = form.dataset.builderType;
  const submitButton = form.querySelector("button[type='submit']");
  const payload = getBuilderPayload(itemType);

  try {
    JSON.parse(payload.attributes);
  } catch (error) {
    builderStatus.textContent = `${itemType} attributes must be valid JSON: ${error.message}`;
    return;
  }

  submitButton.disabled = true;
  builderStatus.textContent = `Creating ${itemType} ${payload.name}...`;

  try {
    const response = await fetch("/api/ai-builder/create", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload)
    });
    const result = await readJsonResponse(response);
    if (!response.ok || !result.ok) {
      throw new Error(result.detail || result.error || `Could not create ${itemType}`);
    }

    builderStatus.textContent = result.status || confirmationMessage(payload.displayType || itemType, payload.name);
    managerLoaded = false;
    agentsLoaded = false;
    profilesLoaded = false;
  } catch (error) {
    builderStatus.textContent = error.message;
  } finally {
    submitButton.disabled = false;
  }
}

async function readJsonResponse(response) {
  const text = await response.text();
  if (!text) {
    return {};
  }
  try {
    return JSON.parse(text);
  } catch (error) {
    return {
      ok: false,
      error: `Server returned a non-JSON response (${response.status})`,
      detail: text.slice(0, 800)
    };
  }
}

function getBuilderPayload(itemType) {
  const fields = {
    Tool: {
      name: builderToolName.value,
      description: builderToolDescription.value,
      attributes: builderToolAttributes.value
    },
    Task: {
      name: builderTaskName.value,
      description: builderTaskDescription.value,
      attributes: builderTaskAttributes.value
    },
    Agent: {
      name: builderAgentName.value,
      description: builderAgentDescription.value,
      attributes: builderAgentAttributes.value
    },
    Team: {
      name: builderTeamName.value,
      description: builderTeamDescription.value,
      attributes: builderTeamAttributes.value
    },
    SelectProfile: {
      name: builderSelectProfileName.value,
      description: builderSelectProfileDescription.value,
      attributes: builderSelectProfileAttributes.value,
      displayType: "Select AI Profile"
    },
    RagProfile: {
      name: builderRagProfileName.value,
      description: builderRagProfileDescription.value,
      attributes: builderRagProfileAttributes.value,
      displayType: "RAG Profile"
    }
  }[itemType];

  return {
    itemType,
    displayType: fields.displayType || itemType,
    name: fields.name.trim(),
    description: fields.description.trim(),
    attributes: fields.attributes.trim()
  };
}

function confirmationMessage(itemType, itemName) {
  return `${itemType} "${itemName}" was added successfully.`;
}

async function loadTopology() {
  refreshTopologyButton.disabled = true;
  downloadTopologyButton.disabled = true;
  topologyStatus.textContent = "Loading AI topology metadata...";

  try {
    const response = await fetch("/api/ai-topology");
    const payload = await response.json();
    if (!response.ok || !payload.ok) {
      throw new Error(payload.detail || payload.error || "Could not load AI topology");
    }

    topologyData = payload;
    const teams = payload.teams && payload.teams.rows || [];
    topologyTeamSelect.innerHTML = teams.map((team) => {
      const name = getTopologyTeamName(team);
      return `<option value="${escapeHtml(name)}">${escapeHtml(name)}</option>`;
    }).join("");

    const defaultTeamName = payload.defaultTeam || "";
    if (defaultTeamName && teams.some((team) => getTopologyTeamName(team).toLowerCase() === defaultTeamName.toLowerCase())) {
      topologyTeamSelect.value = defaultTeamName;
    }

    topologyLoaded = true;
    topologyStatus.textContent = teams.length ? "Loaded topology metadata." : "No AI teams found.";
    renderSelectedTopology();
  } catch (error) {
    topologyData = null;
    topologyTeamSelect.innerHTML = "";
    topologyLegend.innerHTML = "";
    clearTopologyCanvas(error.message);
    topologyStatus.textContent = error.message;
  } finally {
    refreshTopologyButton.disabled = false;
  }
}

function renderSelectedTopology() {
  if (!topologyData) {
    clearTopologyCanvas("Load topology metadata to render connectivity.");
    return;
  }

  const teamName = topologyTeamSelect.value;
  if (!teamName) {
    clearTopologyCanvas("Select an AI team.");
    topologyStatus.textContent = "Select an AI team.";
    return;
  }

  const graph = buildTopologyGraph(topologyData, teamName);
  drawTopologyGraph(graph);
  renderTopologyLegend(graph);
  downloadTopologyButton.disabled = !graph.nodes.length;
  topologyStatus.textContent = `Rendered ${graph.nodes.length} nodes and ${graph.edges.length} connections for ${teamName}.`;
}

function buildTopologyGraph(data, selectedTeamName) {
  const rowsByName = (metadata, nameColumn) => {
    const map = new Map();
    (metadata && metadata.rows || []).forEach((row) => {
      const name = String(row[nameColumn] || "").trim();
      if (name) {
        map.set(name.toLowerCase(), row);
      }
    });
    return map;
  };

  const teams = data.teams && data.teams.rows || [];
  const team = teams.find((row) => getTopologyTeamName(row).toLowerCase() === selectedTeamName.toLowerCase());
  const agentsByName = rowsByName(data.agents, "AGENT_NAME");
  const tasksByName = rowsByName(data.tasks, "TASK_NAME");
  const toolsByName = rowsByName(data.tools, "TOOL_NAME");
  const nodes = [];
  const edges = [];
  const nodeIds = new Set();

  const addNode = (id, label, type, details = "") => {
    if (nodeIds.has(id)) {
      return id;
    }
    nodeIds.add(id);
    nodes.push({ id, label, type, details });
    return id;
  };
  const addEdge = (from, to) => {
    if (from && to && !edges.some((edge) => edge.from === from && edge.to === to)) {
      edges.push({ from, to });
    }
  };

  const teamId = addNode(`team:${selectedTeamName}`, selectedTeamName, "Team", team && team.DESCRIPTION || "");
  const teamAttrs = parseJsonObject(team && team.ATTRIBUTES);
  const teamAgents = getTopologyRelations(teamAttrs, team);

  teamAgents.forEach((entry, index) => {
    const agentName = getTopologyEntryValue(entry, ["name", "agent", "agent_name", "agentName"]);
    const taskName = getTopologyEntryValue(entry, ["task", "task_name", "taskName"]);
    const agentId = agentName ? addNode(`agent:${agentName}`, agentName, "Agent", getRowDescription(agentsByName.get(agentName.toLowerCase()))) : "";
    const taskId = taskName ? addNode(`task:${taskName}`, taskName, "Task", getRowDescription(tasksByName.get(taskName.toLowerCase()))) : "";

    addEdge(teamId, agentId || taskId);
    addEdge(agentId, taskId);

    if (taskName) {
      addTaskTools(taskName, taskId, tasksByName, toolsByName, addNode, addEdge);
    } else if (!agentName) {
      addNode(`note:${index}`, "Team attributes did not include agent/task names", "Note");
    }
  });

  if (!teamAgents.length) {
    addNode("note:no-relations", "No team agent links found", "Note", "Add agents in the team attributes JSON to render links.");
  }

  return { teamName: selectedTeamName, nodes, edges };
}

function addTaskTools(taskName, taskId, tasksByName, toolsByName, addNode, addEdge) {
  const taskRow = tasksByName.get(taskName.toLowerCase());
  const taskAttrs = parseJsonObject(taskRow && taskRow.ATTRIBUTES);
  const tools = getTopologyArrayValue(taskAttrs, ["tools", "tool", "tool_names", "toolNames"]);

  tools.forEach((toolEntry) => {
    const toolName = String(typeof toolEntry === "string" ? toolEntry : getTopologyEntryValue(toolEntry, ["name", "tool", "tool_name", "toolName"])).trim();
    if (!toolName) {
      return;
    }

    const toolRow = toolsByName.get(toolName.toLowerCase());
    const toolId = addNode(`tool:${toolName}`, toolName, "Tool", getRowDescription(toolRow));
    addEdge(taskId, toolId);

    const toolAttrs = parseJsonObject(toolRow && toolRow.ATTRIBUTES);
    const functionName = getTopologyEntryValue(toolAttrs, ["function", "function_name", "functionName", "plsql_function"]);
    if (functionName) {
      const functionId = addNode(`function:${functionName}`, functionName, "Function", "PL/SQL function");
      addEdge(toolId, functionId);
    }

    const toolParams = getTopologyObjectValue(toolAttrs, ["tool_params", "toolParams", "parameters", "params"]);
    const profileName = getTopologyEntryValue(toolParams, ["profile_name", "profileName", "profile"]);
    if (profileName) {
      const profileId = addNode(`profile:${profileName}`, profileName, "Profile", "Select AI profile");
      addEdge(toolId, profileId);
    }

    const toolType = getTopologyEntryValue(toolAttrs, ["tool_type", "toolType", "type"]);
    if (toolType && !functionName && !profileName) {
      const typeId = addNode(`type:${toolName}:${toolType}`, toolType, "Tool Type", "Tool type");
      addEdge(toolId, typeId);
    }
  });

  if (!tools.length) {
    const noteId = addNode(`note:${taskName}:no-tools`, "No tools array found", "Note", "Add tools in the task attributes JSON to render tool links.");
    addEdge(taskId, noteId);
  }
}

function getTopologyRelations(attributes, row) {
  if (Array.isArray(attributes)) {
    return attributes;
  }

  const agents = getTopologyArrayValue(attributes, ["agents", "agent", "agent_list", "agentList", "team_agents", "teamAgents"]);
  if (agents.length) {
    return agents;
  }

  const agentName = getTopologyEntryValue(attributes, ["agent", "agent_name", "agentName", "name"]);
  const taskName = getTopologyEntryValue(attributes, ["task", "task_name", "taskName"]);
  if (agentName || taskName) {
    return [{ name: agentName, task: taskName }];
  }

  const rowAgentName = getTopologyEntryValue(row, ["AGENT_NAME", "AGENT"]);
  const rowTaskName = getTopologyEntryValue(row, ["TASK_NAME", "TASK"]);
  return rowAgentName || rowTaskName ? [{ name: rowAgentName, task: rowTaskName }] : [];
}

function getTopologyArrayValue(source, keys) {
  const value = getTopologyObjectValue(source, keys);
  if (Array.isArray(value)) {
    return value;
  }
  if (value && typeof value === "object") {
    return [value];
  }
  if (typeof value === "string" && value.trim()) {
    return value.split(",").map((item) => item.trim()).filter(Boolean);
  }
  return [];
}

function getTopologyObjectValue(source, keys) {
  if (!source || typeof source !== "object") {
    return undefined;
  }
  const loweredKeys = keys.map((key) => key.toLowerCase());
  const match = Object.keys(source).find((key) => loweredKeys.includes(key.toLowerCase()));
  return match ? source[match] : undefined;
}

function getTopologyEntryValue(source, keys) {
  const value = getTopologyObjectValue(source, keys);
  if (value == null || typeof value === "object") {
    return "";
  }
  return String(value).trim();
}

function getTopologyTeamName(row) {
  return row && (row.AGENT_TEAM_NAME || row.TEAM_NAME) || "";
}

function getRowDescription(row) {
  return row && (row.DESCRIPTION || row.STATUS || "") || "";
}

function parseJsonObject(value) {
  try {
    const parsed = JSON.parse(String(value || "{}"));
    return typeof parsed === "string" ? JSON.parse(parsed) : parsed;
  } catch {
    return {};
  }
}

function drawTopologyGraph(graph) {
  const canvas = topologyCanvas;
  const ctx = canvas.getContext("2d");
  const typeOrder = ["Team", "Agent", "Task", "Tool", "Function", "Profile", "Tool Type", "Note"];
  const grouped = typeOrder.map((type) => graph.nodes.filter((node) => node.type === type)).filter((nodes) => nodes.length);
  const columnWidth = 220;
  const nodeWidth = 176;
  const nodeHeight = 70;
  const top = 92;
  const left = 48;
  const columnGap = 28;
  const rowGap = 28;
  const maxRows = Math.max(1, ...grouped.map((nodes) => nodes.length));
  const width = Math.max(1100, left * 2 + grouped.length * columnWidth + Math.max(0, grouped.length - 1) * columnGap);
  const height = Math.max(620, top + maxRows * (nodeHeight + rowGap) + 86);

  canvas.width = width;
  canvas.height = height;

  ctx.fillStyle = "#f7f3ee";
  ctx.fillRect(0, 0, width, height);
  ctx.fillStyle = "#221f1d";
  ctx.font = "700 26px Oracle Sans, system-ui, sans-serif";
  ctx.fillText("AI Team Connectivity", left, 42);
  ctx.font = "500 14px Oracle Sans, system-ui, sans-serif";
  ctx.fillStyle = "#6f6760";
  ctx.fillText(`Selected team: ${graph.teamName}`, left, 66);

  const positions = new Map();
  grouped.forEach((nodes, columnIndex) => {
    const x = left + columnIndex * (columnWidth + columnGap);
    const type = nodes[0] && nodes[0].type || "";
    ctx.font = "800 13px Oracle Sans, system-ui, sans-serif";
    ctx.fillStyle = "#6f6760";
    ctx.fillText(type.toUpperCase(), x, top - 20);
    nodes.forEach((node, rowIndex) => {
      const y = top + rowIndex * (nodeHeight + rowGap);
      positions.set(node.id, { x, y, width: nodeWidth, height: nodeHeight });
    });
  });

  graph.edges.forEach((edge) => {
    const from = positions.get(edge.from);
    const to = positions.get(edge.to);
    if (!from || !to) {
      return;
    }
    drawArrow(ctx, from.x + from.width, from.y + from.height / 2, to.x, to.y + to.height / 2);
  });

  graph.nodes.forEach((node) => {
    const pos = positions.get(node.id);
    if (pos) {
      drawTopologyNode(ctx, node, pos);
    }
  });
}

function drawTopologyNode(ctx, node, pos) {
  const colors = {
    Team: ["#8b1e16", "#fff7ed"],
    Agent: ["#2563eb", "#eff6ff"],
    Task: ["#7c3aed", "#f5f3ff"],
    Tool: ["#0f766e", "#ecfdf5"],
    Function: ["#c2410c", "#fff7ed"],
    Profile: ["#be185d", "#fdf2f8"],
    "Tool Type": ["#475569", "#f8fafc"],
    Note: ["#6b7280", "#f9fafb"]
  };
  const [border, fill] = colors[node.type] || ["#475569", "#f8fafc"];
  roundRect(ctx, pos.x, pos.y, pos.width, pos.height, 8, fill, border);
  ctx.fillStyle = border;
  ctx.font = "800 11px Oracle Sans, system-ui, sans-serif";
  ctx.fillText(node.type.toUpperCase(), pos.x + 12, pos.y + 18);
  ctx.fillStyle = "#171412";
  ctx.font = "800 14px Oracle Sans, system-ui, sans-serif";
  wrapText(ctx, node.label, pos.x + 12, pos.y + 40, pos.width - 24, 16, 2);
}

function drawArrow(ctx, x1, y1, x2, y2) {
  const midX = x1 + Math.max(24, (x2 - x1) / 2);
  ctx.strokeStyle = "#a8a29e";
  ctx.lineWidth = 2;
  ctx.beginPath();
  ctx.moveTo(x1, y1);
  ctx.bezierCurveTo(midX, y1, midX, y2, x2, y2);
  ctx.stroke();
  ctx.fillStyle = "#a8a29e";
  ctx.beginPath();
  ctx.moveTo(x2, y2);
  ctx.lineTo(x2 - 8, y2 - 5);
  ctx.lineTo(x2 - 8, y2 + 5);
  ctx.closePath();
  ctx.fill();
}

function roundRect(ctx, x, y, width, height, radius, fill, stroke) {
  ctx.beginPath();
  ctx.moveTo(x + radius, y);
  ctx.lineTo(x + width - radius, y);
  ctx.quadraticCurveTo(x + width, y, x + width, y + radius);
  ctx.lineTo(x + width, y + height - radius);
  ctx.quadraticCurveTo(x + width, y + height, x + width - radius, y + height);
  ctx.lineTo(x + radius, y + height);
  ctx.quadraticCurveTo(x, y + height, x, y + height - radius);
  ctx.lineTo(x, y + radius);
  ctx.quadraticCurveTo(x, y, x + radius, y);
  ctx.closePath();
  ctx.fillStyle = fill;
  ctx.fill();
  ctx.strokeStyle = stroke;
  ctx.lineWidth = 2;
  ctx.stroke();
}

function wrapText(ctx, text, x, y, maxWidth, lineHeight, maxLines) {
  const words = String(text || "").split(/\s+/);
  let line = "";
  let lines = 0;
  words.forEach((word) => {
    if (lines >= maxLines) {
      return;
    }
    const test = line ? `${line} ${word}` : word;
    if (ctx.measureText(test).width > maxWidth && line) {
      ctx.fillText(line, x, y);
      y += lineHeight;
      lines += 1;
      line = word;
    } else {
      line = test;
    }
  });
  if (line && lines < maxLines) {
    ctx.fillText(line, x, y);
  }
}

function clearTopologyCanvas(message) {
  const canvas = topologyCanvas;
  const ctx = canvas.getContext("2d");
  ctx.clearRect(0, 0, canvas.width, canvas.height);
  ctx.fillStyle = "#f7f3ee";
  ctx.fillRect(0, 0, canvas.width, canvas.height);
  ctx.fillStyle = "#6f6760";
  ctx.font = "700 18px Oracle Sans, system-ui, sans-serif";
  ctx.fillText(message || "No topology to render.", 40, 70);
  downloadTopologyButton.disabled = true;
}

function renderTopologyLegend(graph) {
  const counts = graph.nodes.reduce((summary, node) => {
    summary[node.type] = (summary[node.type] || 0) + 1;
    return summary;
  }, {});
  topologyLegend.innerHTML = Object.entries(counts).map(([type, count]) => {
    return `<span>${escapeHtml(type)}: ${count}</span>`;
  }).join("");
}

function downloadTopologyPng() {
  const link = document.createElement("a");
  const team = topologyTeamSelect.value || "ai-team";
  link.download = `${team.replace(/[^A-Za-z0-9_-]+/g, "_")}-topology.png`;
  link.href = topologyCanvas.toDataURL("image/png");
  link.click();
}

function getManagerTeamNameColumn(metadata) {
  const columns = metadata && metadata.columns || [];
  if (columns.includes("AGENT_TEAM_NAME")) {
    return "AGENT_TEAM_NAME";
  }
  return columns.includes("TEAM_NAME") ? "TEAM_NAME" : "";
}

async function loadUsers() {
  refreshUsersButton.disabled = true;
  usersStatus.textContent = "Loading...";

  try {
    const response = await fetch("/api/users");
    const payload = await response.json();
    if (!response.ok || !payload.ok) {
      throw new Error(payload.detail || payload.error || "Could not load users");
    }

    renderUsersTable(payload.users || []);
    usersCount.textContent = String((payload.users || []).length);
    usersStatus.textContent = "Loaded users from .auth.";
    usersLoaded = true;
  } catch (error) {
    usersTable.innerHTML = "";
    usersCount.textContent = "0";
    usersStatus.textContent = error.message;
  } finally {
    refreshUsersButton.disabled = false;
  }
}

async function saveUser(event) {
  event.preventDefault();
  saveUserButton.disabled = true;
  usersStatus.textContent = "Adding user...";

  try {
    const response = await fetch("/api/users", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        username: newUsername.value,
        displayName: newDisplayName.value,
        password: newPassword.value,
        role: newRole.value
      })
    });
    const payload = await response.json();
    if (!response.ok || !payload.ok) {
      throw new Error(payload.detail || payload.error || "Could not add user");
    }

    userForm.reset();
    renderUsersTable(payload.users || []);
    usersCount.textContent = String((payload.users || []).length);
    usersStatus.textContent = `${payload.user.displayName} added. Password stored base64 encoded in .auth.`;
    usersLoaded = true;
  } catch (error) {
    usersStatus.textContent = error.message;
  } finally {
    saveUserButton.disabled = false;
  }
}

function renderUsersTable(users) {
  if (!users.length) {
    usersTable.innerHTML = '<div class="empty-state">No users found.</div>';
    return;
  }

  const columns = ["displayName", "username", "role"];
  const header = columns.map((column) => `<th>${formatTableHeader(column)}</th>`).join("");
  const body = users.map((user) => {
    return `<tr>
      <td>${escapeHtml(user.displayName || "")}</td>
      <td>${escapeHtml(user.username || "")}</td>
      <td>${escapeHtml(user.role || "")}</td>
    </tr>`;
  }).join("");

	  usersTable.innerHTML = `
	    <table>
	      <thead><tr>${header}</tr></thead>
	      <tbody>${body}</tbody>
	    </table>`;
}

async function loadLinks() {
  refreshLinksButton.disabled = true;
  linksStatus.textContent = "Loading...";

  try {
    const response = await fetch("/api/links");
    const payload = await response.json();
    if (!response.ok || !payload.ok) {
      throw new Error(payload.detail || payload.error || "Could not load links");
    }

    renderLinksTable(payload.links || []);
    linksCount.textContent = String((payload.links || []).length);
    linksStatus.textContent = "Loaded links.";
    linksLoaded = true;
  } catch (error) {
    linksTable.innerHTML = "";
    linksCount.textContent = "0";
    linksStatus.textContent = error.message;
  } finally {
    refreshLinksButton.disabled = false;
  }
}

async function saveLink(event) {
  event.preventDefault();
  saveLinkButton.disabled = true;
  linksStatus.textContent = "Adding link...";

  try {
    const response = await fetch("/api/links", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        name: newLinkName.value,
        url: newLinkUrl.value
      })
    });
    const payload = await response.json();
    if (!response.ok || !payload.ok) {
      throw new Error(payload.detail || payload.error || "Could not add link");
    }

    linkForm.reset();
    renderLinksTable(payload.links || []);
    linksCount.textContent = String((payload.links || []).length);
    linksStatus.textContent = "Link added.";
    linksLoaded = true;
  } catch (error) {
    linksStatus.textContent = error.message;
  } finally {
    saveLinkButton.disabled = false;
  }
}

async function deleteLink(id) {
  linksStatus.textContent = "Deleting link...";

  try {
    const response = await fetch("/api/links/delete", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ id })
    });
    const payload = await response.json();
    if (!response.ok || !payload.ok) {
      throw new Error(payload.detail || payload.error || "Could not delete link");
    }

    renderLinksTable(payload.links || []);
    linksCount.textContent = String((payload.links || []).length);
    linksStatus.textContent = "Link deleted.";
  } catch (error) {
    linksStatus.textContent = error.message;
  }
}

function renderLinksTable(links) {
  if (!links.length) {
    linksTable.innerHTML = '<div class="empty-state">No links saved.</div>';
    return;
  }

  const body = links.map((link) => {
    const id = escapeHtml(link.id || "");
    const name = escapeHtml(link.name || "");
    const url = escapeHtml(link.url || "");
    return `<tr>
      <td><a class="external-link" href="${url}" target="_blank" rel="noopener noreferrer">${name}</a></td>
      <td><button type="button" class="link-delete-button" data-link-delete-id="${id}">Delete</button></td>
    </tr>`;
  }).join("");

  linksTable.innerHTML = `
    <table>
      <thead><tr><th>Link Name</th><th>Action</th></tr></thead>
      <tbody>${body}</tbody>
    </table>`;

  linksTable.querySelectorAll("[data-link-delete-id]").forEach((button) => {
    button.addEventListener("click", () => deleteLink(button.dataset.linkDeleteId));
  });
}

function updateMcpTesterDefaults() {
  const action = mcpAction.value;
  const isToolCall = action === "call_tool";
  const isNaturalLanguage = action === "natural_language";
  mcpNaturalPrompt.disabled = !isNaturalLanguage;
  mcpProfileName.disabled = !isNaturalLanguage;
  mcpToolName.disabled = !isToolCall;
  mcpArguments.disabled = action !== "call_tool";

  if (isNaturalLanguage && !mcpNaturalPrompt.value.trim()) {
    mcpNaturalPrompt.value = "Get details about program 779";
  }

  if (isNaturalLanguage && !mcpProfileName.value.trim()) {
    mcpProfileName.value = profileName.value || publicConfig.profileName || "";
  }

  if (!mcpArguments.value.trim()) {
    mcpArguments.value = JSON.stringify({
      offset: 0,
      limit: 25
    }, null, 2);
  }

  if (isToolCall && !mcpToolName.value.trim()) {
    mcpToolName.value = "LIST_SCHEMAS";
  }
}

async function runMcpTester(event) {
  event.preventDefault();
  const action = mcpAction.value;
  const argumentsJson = mcpArguments.value.trim() || "{}";

  if (action === "natural_language" && !mcpNaturalPrompt.value.trim()) {
    mcpTesterStatus.textContent = "Enter a natural language query.";
    mcpNaturalPrompt.focus();
    return;
  }

  if (action === "call_tool") {
    try {
      JSON.parse(argumentsJson);
    } catch (error) {
      mcpTesterStatus.textContent = `Arguments JSON is invalid: ${error.message}`;
      return;
    }
  }

  runMcpTesterButton.disabled = true;
  mcpTesterStatus.textContent = "Running MCP test...";
  mcpResponseOutput.textContent = "";

  try {
    const response = await fetch("/api/mcp/test", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        action,
        prompt: mcpNaturalPrompt.value,
        profileName: mcpProfileName.value,
        toolName: mcpToolName.value,
        argumentsJson
      })
    });
    const payload = await readJsonResponse(response);
    if (!response.ok || !payload.ok) {
      throw new Error(payload.detail || payload.error || "MCP test failed");
    }

    mcpResponseOutput.textContent = JSON.stringify(payload, null, 2);
    mcpTesterStatus.textContent = `MCP test completed in ${formatElapsedMs(payload.elapsedMs || 0)}.`;
  } catch (error) {
    mcpResponseOutput.textContent = "";
    mcpTesterStatus.textContent = error.message;
  } finally {
    runMcpTesterButton.disabled = false;
  }
}

async function runLatestTeamTaskExecution() {
  if (!selectedAgentTeamName) {
    latestTaskStatus.textContent = "Select an agent team.";
    return;
  }

  runLatestTaskButton.disabled = true;
  latestTaskStatus.textContent = `Executing for ${selectedAgentTeamName}...`;
  latestTaskTable.innerHTML = "";
  latestTaskRows = [];

  try {
    const response = await fetch("/api/latest-team-task-execution", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ teamName: selectedAgentTeamName })
    });
    const payload = await response.json();
    if (!response.ok || !payload.ok) {
      throw new Error(payload.detail || payload.error || "Latest team task execution failed");
    }

    latestTaskRows = payload.rows || [];
    renderLatestTaskExecutionTable(payload.columns || [], latestTaskRows);
    latestTaskStatus.textContent = `Loaded ${payload.rows.length} row${payload.rows.length === 1 ? "" : "s"} for ${payload.teamName} in ${payload.elapsedMs} ms.`;
  } catch (error) {
    latestTaskStatus.textContent = error.message;
  } finally {
    runLatestTaskButton.disabled = !selectedAgentTeamName;
  }
}

async function loadPrompts(offset = promptsOffset) {
  promptsOffset = Math.max(0, offset);
  refreshPromptsButton.disabled = true;
  previousPromptsButton.disabled = true;
  nextPromptsButton.disabled = true;
  promptsStatus.textContent = "Loading...";

  try {
    const response = await fetch(`/api/user-prompts?limit=${promptsPageSize}&offset=${promptsOffset}`);
    const payload = await response.json();
    if (!response.ok || !payload.ok) {
      throw new Error(payload.detail || payload.error || "Could not load user prompts");
    }

    renderMetadataTable(promptsTable, payload.prompts, {
      emptyText: "No user prompts found."
    });
    promptsTotal = Number(payload.prompts && payload.prompts.total || 0);
    promptsOffset = Number(payload.prompts && payload.prompts.offset || 0);
    const rows = payload.prompts && payload.prompts.rows || [];
    promptsCount.textContent = String(promptsTotal);
    updatePromptsPagination(rows.length);
    promptsStatus.textContent = payload.prompts && payload.prompts.available
      ? "Loaded latest prompts first."
      : "User prompt history view is not available for this user.";
    promptsLoaded = true;
  } catch (error) {
    promptsTable.innerHTML = "";
    promptsCount.textContent = "0";
    promptsTotal = 0;
    updatePromptsPagination(0);
    promptsStatus.textContent = error.message;
  } finally {
    refreshPromptsButton.disabled = false;
    previousPromptsButton.disabled = promptsOffset <= 0;
    nextPromptsButton.disabled = promptsOffset + promptsPageSize >= promptsTotal;
  }
}

function updatePromptsPagination(visibleCount) {
  if (!promptsTotal || !visibleCount) {
    promptsPageText.textContent = "Showing 0";
  } else {
    const start = promptsOffset + 1;
    const end = promptsOffset + visibleCount;
    promptsPageText.textContent = `Showing ${start}-${end} of ${promptsTotal}`;
  }
  previousPromptsButton.disabled = promptsOffset <= 0;
  nextPromptsButton.disabled = promptsOffset + promptsPageSize >= promptsTotal;
}

async function loadMemory(offset = memoryOffset) {
  memoryOffset = Math.max(0, offset);
  refreshMemoryButton.disabled = true;
  previousMemoryButton.disabled = true;
  nextMemoryButton.disabled = true;
  memoryStatus.textContent = "Loading...";

  try {
    const response = await fetch(`/api/memory-table?limit=${memoryPageSize}&offset=${memoryOffset}`);
    const payload = await response.json();
    if (!response.ok || !payload.ok) {
      throw new Error(payload.detail || payload.error || "Could not load memory table");
    }

    renderMetadataTable(memoryTable, payload.memory, {
      emptyText: "No memory records found."
    });
    memoryTotal = Number(payload.memory && payload.memory.total || 0);
    memoryOffset = Number(payload.memory && payload.memory.offset || 0);
    const rows = payload.memory && payload.memory.rows || [];
    memoryCount.textContent = String(memoryTotal);
    memoryTableName.textContent = payload.memory && payload.memory.viewName
      ? payload.memory.viewName
      : "Memory";
    updateMemoryPagination(rows.length);
    memoryStatus.textContent = payload.memory && payload.memory.available
      ? `Loaded latest records first by ${payload.memory.orderColumn || "latest order"}.`
      : "Configured memory table is not available for this user.";
    memoryLoaded = true;
  } catch (error) {
    memoryTable.innerHTML = "";
    memoryCount.textContent = "0";
    memoryTableName.textContent = "Memory";
    memoryTotal = 0;
    updateMemoryPagination(0);
    memoryStatus.textContent = error.message;
  } finally {
    refreshMemoryButton.disabled = false;
    previousMemoryButton.disabled = memoryOffset <= 0;
    nextMemoryButton.disabled = memoryOffset + memoryPageSize >= memoryTotal;
  }
}

function updateMemoryPagination(visibleCount) {
  if (!memoryTotal || !visibleCount) {
    memoryPageText.textContent = "Showing 0";
  } else {
    const start = memoryOffset + 1;
    const end = memoryOffset + visibleCount;
    memoryPageText.textContent = `Showing ${start}-${end} of ${memoryTotal}`;
  }
  previousMemoryButton.disabled = memoryOffset <= 0;
  nextMemoryButton.disabled = memoryOffset + memoryPageSize >= memoryTotal;
}

async function loadRag() {
  refreshRagButton.disabled = true;
  ragStatus.textContent = "Loading...";

  try {
    const response = await fetch("/api/rag");
    const payload = await response.json();
    if (!response.ok || !payload.ok) {
      throw new Error(payload.detail || payload.error || "Could not load RAG metadata");
    }

    renderMetadataTable(ragPipelinesTable, payload.pipelines, {
      emptyText: "No RAG pipelines found."
    });
    renderMetadataTable(ragAttributesTable, payload.attributes, {
      emptyText: "No pipeline attributes found."
    });
    renderMetadataTable(ragObjectsTable, payload.objects, {
      emptyText: "No cloud storage objects found."
    });
    renderMetadataTable(ragHistoryTable, payload.history, {
      emptyText: "No pipeline history found."
    });

    ragPipelinesCount.textContent = String((payload.pipelines && payload.pipelines.rows || []).length);
    ragAttributesCount.textContent = String((payload.attributes && payload.attributes.rows || []).length);
    ragObjectsCount.textContent = String((payload.objects && payload.objects.rows || []).length);
    ragHistoryCount.textContent = String((payload.history && payload.history.rows || []).length);
    ragStorageLocation.textContent = payload.storageLocation ? `Location: ${payload.storageLocation}` : "OCI_STORAGE_LOCATION is not configured.";

    const errors = [payload.pipelines, payload.attributes, payload.objects, payload.history]
      .filter((section) => section && section.error)
      .map((section) => `${section.viewName}: ${section.error}`);
    ragStatus.textContent = errors.length ? errors.join(" | ") : "Loaded RAG metadata.";
    ragLoaded = true;
  } catch (error) {
    ragPipelinesTable.innerHTML = "";
    ragAttributesTable.innerHTML = "";
    ragObjectsTable.innerHTML = "";
    ragHistoryTable.innerHTML = "";
    ragPipelinesCount.textContent = "0";
    ragAttributesCount.textContent = "0";
    ragObjectsCount.textContent = "0";
    ragHistoryCount.textContent = "0";
    ragStorageLocation.textContent = "";
    ragStatus.textContent = error.message;
  } finally {
    refreshRagButton.disabled = false;
  }
}

async function loadReports() {
  refreshReportsButton.disabled = true;
  reportsStatus.textContent = "Loading...";
  setReportsUploadConfirmation();

  try {
    const response = await fetch("/api/reports");
    const payload = await response.json();
    if (!response.ok || !payload.ok) {
      throw new Error(payload.detail || payload.error || "Could not load reports");
    }

    reportsFiles = payload.files || [];
    reportsFolders = payload.folders || [];
    if (reportsFiles.length && reportsLayout.classList.contains("is-browser-collapsed") && reportsSelectedName.textContent === "No report selected") {
      setReportsBrowserCollapsed(false);
    }
    if (selectedReportsFolder && !reportsFolders.some((folder) => folder.path === selectedReportsFolder)) {
      selectedReportsFolder = "";
      localStorage.setItem("dtc-selected-reports-folder", selectedReportsFolder);
    }
    renderReportsFileList(reportsFiles, reportsFolders);
    reportsCount.textContent = String(reportsFiles.length);
    reportsStatus.textContent = reportsFiles.length ? "Loaded reports." : "No PDF or HTML reports found.";
    reportsLoaded = true;
  } catch (error) {
    reportsFiles = [];
    reportsFolders = [];
    selectedReportFile = null;
    reportsFileList.innerHTML = "";
    reportsCount.textContent = "0";
    reportsSelectedName.textContent = "No report selected";
    reportsPdfFrame.removeAttribute("src");
    updateReportsRagUploadButton();
    setReportsUploadConfirmation();
    reportsStatus.textContent = error.message;
  } finally {
    refreshReportsButton.disabled = false;
  }
}

function renderReportsFileList(files, folders = []) {
  const tree = buildReportsTree(files, folders);
  reportsFileList.innerHTML = renderReportsTreeNode(tree);

  reportsFileList.querySelectorAll("[data-report-index]").forEach((button) => {
    button.addEventListener("click", () => {
      const file = files[Number(button.dataset.reportIndex)];
      selectReportFile(file, button.closest(".reports-tree-file"));
    });
  });
  reportsFileList.querySelectorAll("[data-report-rename-index]").forEach((button) => {
    button.addEventListener("click", () => {
      const file = files[Number(button.dataset.reportRenameIndex)];
      renameReportFile(file);
    });
  });
  reportsFileList.querySelectorAll("[data-report-delete-index]").forEach((button) => {
    button.addEventListener("click", () => {
      const file = files[Number(button.dataset.reportDeleteIndex)];
      deleteReportFile(file);
    });
  });
  reportsFileList.querySelectorAll("[data-report-folder-rename-path]").forEach((button) => {
    button.addEventListener("click", (event) => {
      event.preventDefault();
      event.stopPropagation();
      renameReportFolder(button.dataset.reportFolderRenamePath || "");
    });
  });
  reportsFileList.querySelectorAll("[data-report-folder-delete-path]").forEach((button) => {
    button.addEventListener("click", (event) => {
      event.preventDefault();
      event.stopPropagation();
      deleteReportFolder(button.dataset.reportFolderDeletePath || "");
    });
  });
  reportsFileList.querySelectorAll("[data-report-folder]").forEach((button) => {
    button.addEventListener("click", (event) => {
      event.preventDefault();
      event.stopPropagation();
      selectReportsFolder(button.dataset.reportFolder || "");
    });
    button.addEventListener("dragover", handleReportsFolderDragOver);
    button.addEventListener("dragleave", handleReportsFolderDragLeave);
    button.addEventListener("drop", handleReportsFolderDrop);
  });
  reportsFileList.querySelectorAll("[data-report-drag-index]").forEach((row) => {
    row.addEventListener("dragstart", handleReportDragStart);
    row.addEventListener("dragend", handleReportDragEnd);
  });

  updateSelectedReportsFolderLabel();

  const firstButton = reportsFileList.querySelector("[data-report-index]");
  if (firstButton) {
    const firstFile = files[Number(firstButton.dataset.reportIndex)];
    selectReportFile(firstFile, firstButton.closest(".reports-tree-file"));
  } else {
    selectedReportFile = null;
    reportsSelectedName.textContent = "No report selected";
    reportsPdfFrame.removeAttribute("src");
    updateReportsRagUploadButton();
    setReportsUploadConfirmation();
  }
}

function selectReportFile(file, button) {
  reportsFileList.querySelectorAll(".reports-tree-file").forEach((candidate) => {
    candidate.classList.toggle("active", candidate === button);
  });
  selectedReportFile = file || null;
  reportsSelectedName.textContent = file.path;
  reportsPdfFrame.src = file.url;
  updateReportsRagUploadButton();
  setReportsUploadConfirmation();
}

function updateReportsRagUploadButton() {
  uploadReportsKnowledgeButton.disabled = !selectedReportFile;
}

function setReportsUploadConfirmation(message = "", title = "") {
  if (!reportsUploadConfirmation) {
    return;
  }
  reportsUploadConfirmation.textContent = message;
  reportsUploadConfirmation.title = title || message;
  reportsUploadConfirmation.hidden = !message;
}

function setReportsBrowserCollapsed(isCollapsed) {
  reportsLayout.classList.toggle("is-browser-collapsed", isCollapsed);
  const label = toggleReportsBrowserButton.querySelector(".reports-action-label");
  if (label) {
    label.textContent = isCollapsed ? "Show Browser" : "Hide Browser";
  } else {
    toggleReportsBrowserButton.textContent = isCollapsed ? "Show Browser" : "Hide Browser";
  }
  toggleReportsBrowserButton.title = isCollapsed ? "Show folder browser" : "Collapse folder browser";
  toggleReportsBrowserButton.setAttribute("aria-expanded", String(!isCollapsed));
  localStorage.setItem("dtc-reports-browser-collapsed", String(isCollapsed));
}

function buildReportsTree(files, folders = []) {
  const root = {
    name: "Reports",
    path: "",
    folders: new Map(),
    files: []
  };

  folders.forEach((folder) => {
    let current = root;
    const segments = folder.path.split("/").filter(Boolean);
    segments.forEach((segment, index) => {
      const folderPath = segments.slice(0, index + 1).join("/");
      if (!current.folders.has(segment)) {
        current.folders.set(segment, {
          name: segment,
          path: folderPath,
          folders: new Map(),
          files: []
        });
      }
      current = current.folders.get(segment);
    });
  });

  files.forEach((file, index) => {
    let current = root;
    const segments = file.path.split("/").filter(Boolean);
    const fileName = segments.pop() || file.name;
    segments.forEach((segment, folderIndex) => {
      const folderPath = segments.slice(0, folderIndex + 1).join("/");
      if (!current.folders.has(segment)) {
        current.folders.set(segment, {
          name: segment,
          path: folderPath,
          folders: new Map(),
          files: []
        });
      }
      current = current.folders.get(segment);
    });
    current.files.push({ ...file, name: fileName, index });
  });

  return root;
}

function renderReportsTreeNode(node, depth = 0) {
  const folders = Array.from(node.folders.values()).sort((left, right) => left.name.localeCompare(right.name));
  const files = node.files.slice().sort((left, right) => left.name.localeCompare(right.name));
  const children = [
    ...folders.map((folder) => renderReportsTreeNode(folder, depth + 1)),
    ...files.map((file) => renderReportsTreeFile(file, depth + 1))
  ].join("") || `<div class="reports-tree-empty" style="--tree-depth: ${depth + 1}">Empty folder</div>`;

  if (depth === 0) {
    const selectedClass = selectedReportsFolder === "" ? " selected" : "";
    return `
      <div class="reports-tree-root">
        <button class="reports-tree-folder-label${selectedClass}" type="button" style="--tree-depth: 0" data-report-folder="" draggable="false">
          ${reportIcon("folder-open")}
          <span>Reports</span>
        </button>
        <div class="reports-tree-children">${children}</div>
      </div>`;
  }

  const selectedClass = selectedReportsFolder === node.path ? " selected" : "";
  return `
    <details class="reports-tree-folder" open>
      <summary style="--tree-depth: ${depth}">
        <span class="reports-folder-toggle-icons" aria-hidden="true">${reportIcon("folder-closed")}${reportIcon("folder-open")}</span>
        <button class="reports-folder-name${selectedClass}" type="button" data-report-folder="${escapeHtml(node.path)}">${escapeHtml(node.name)}</button>
        <button class="reports-folder-rename" type="button" data-report-folder-rename-path="${escapeHtml(node.path)}" title="Rename folder" aria-label="Rename ${escapeHtml(node.name)}">
          ${reportIcon("rename")}
        </button>
        <button class="reports-folder-delete" type="button" data-report-folder-delete-path="${escapeHtml(node.path)}" title="Delete folder" aria-label="Delete ${escapeHtml(node.name)}">
          ${reportIcon("delete")}
        </button>
      </summary>
      <div class="reports-tree-children">${children}</div>
    </details>`;
}

function renderReportsTreeFile(file, depth) {
  return `
    <div class="reports-tree-file" style="--tree-depth: ${depth}" draggable="true" data-report-drag-index="${file.index}">
      <button class="reports-file-open" type="button" data-report-index="${file.index}">
        ${reportIcon(file.type === "pdf" ? "pdf" : "html")}
        <span class="reports-file-text">
          <span class="reports-file-name">${escapeHtml(file.name)}</span>
          <span class="reports-file-meta">${escapeHtml(formatReportMeta(file))}</span>
        </span>
      </button>
      <button class="reports-file-rename" type="button" data-report-rename-index="${file.index}" title="Rename file" aria-label="Rename ${escapeHtml(file.name)}">
        ${reportIcon("rename")}
      </button>
      <button class="reports-file-delete" type="button" data-report-delete-index="${file.index}" title="Delete file" aria-label="Delete ${escapeHtml(file.name)}">
        ${reportIcon("delete")}
      </button>
    </div>`;
}

function reportIcon(type) {
  if (type === "folder" || type === "folder-closed") {
    return `<svg class="reports-tree-icon reports-folder-icon" viewBox="0 0 24 24" aria-hidden="true"><path d="M3 6.5h6l2 2h10v9.5H3z"></path><path d="M3 6.5v11.5"></path></svg>`;
  }
  if (type === "folder-open") {
    return `<svg class="reports-tree-icon reports-folder-icon reports-folder-open-icon" viewBox="0 0 24 24" aria-hidden="true"><path d="M3 8h6l2 2h10l-2 8H4z"></path><path d="M3 8v10h16"></path></svg>`;
  }
  if (type === "html") {
    return `<svg class="reports-tree-icon reports-html-icon" viewBox="0 0 24 24" aria-hidden="true"><path d="M6 4h9l3 3v13H6z"></path><path d="M15 4v4h4"></path><path d="M10 12l-2 2 2 2M14 12l2 2-2 2"></path></svg>`;
  }
  if (type === "rename") {
    return `<svg class="reports-tree-icon" viewBox="0 0 24 24" aria-hidden="true"><path d="M4 20h4l10-10-4-4L4 16z"></path><path d="M13 7l4 4"></path></svg>`;
  }
  if (type === "delete") {
    return `<svg class="reports-tree-icon" viewBox="0 0 24 24" aria-hidden="true"><path d="M5 7h14"></path><path d="M9 7V5h6v2"></path><path d="M8 10v9h8v-9"></path><path d="M10.5 12.5v4M13.5 12.5v4"></path></svg>`;
  }
  return `<svg class="reports-tree-icon reports-pdf-icon" viewBox="0 0 24 24" aria-hidden="true"><path d="M6 4h9l3 3v13H6z"></path><path d="M15 4v4h4"></path><path d="M8 16h8M8 12h3M8 8h3"></path></svg>`;
}

async function renameReportFile(file) {
  const newName = window.prompt("Rename file", file.name);
  if (newName === null) {
    return;
  }
  const trimmedName = newName.trim();
  if (!trimmedName || trimmedName === file.name) {
    return;
  }

  reportsStatus.textContent = "Renaming report...";
  try {
    const response = await fetch("/api/reports/rename", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        path: file.path,
        newName: trimmedName
      })
    });
    const payload = await response.json();
    if (!response.ok || !payload.ok) {
      throw new Error(payload.error || payload.detail || "Could not rename report");
    }
    reportsStatus.textContent = payload.message || "Report renamed.";
    reportsLoaded = false;
    await loadReports();
  } catch (error) {
    reportsStatus.textContent = error.message;
  }
}

async function deleteReportFile(file) {
  const confirmed = window.confirm(`Delete ${file.name}?`);
  if (!confirmed) {
    return;
  }

  reportsStatus.textContent = "Deleting report...";
  try {
    const response = await fetch("/api/reports/delete", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        path: file.path
      })
    });
    const payload = await response.json();
    if (!response.ok || !payload.ok) {
      throw new Error(payload.error || payload.detail || "Could not delete report");
    }
    reportsStatus.textContent = payload.message || "Report deleted.";
    if (reportsSelectedName.textContent === file.path) {
      reportsSelectedName.textContent = "No report selected";
      reportsPdfFrame.removeAttribute("src");
    }
    reportsLoaded = false;
    await loadReports();
  } catch (error) {
    reportsStatus.textContent = error.message;
  }
}

async function renameReportFolder(folderPath) {
  const normalizedPath = normalizeClientFolderPath(folderPath);
  if (!normalizedPath) {
    reportsStatus.textContent = "Select a folder under Reports to rename.";
    return;
  }

  const currentName = normalizedPath.split("/").pop() || normalizedPath;
  const newName = window.prompt("Rename folder", currentName);
  if (newName === null) {
    return;
  }
  const trimmedName = newName.trim();
  if (!trimmedName || trimmedName === currentName) {
    return;
  }

  reportsStatus.textContent = "Renaming folder...";
  try {
    const response = await fetch("/api/reports/folder/rename", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        path: normalizedPath,
        newName: trimmedName
      })
    });
    const payload = await response.json();
    if (!response.ok || !payload.ok) {
      throw new Error(payload.error || payload.detail || "Could not rename folder");
    }

    const oldPath = normalizeClientFolderPath(payload.oldPath || normalizedPath);
    const renamedPath = normalizeClientFolderPath(payload.path || "");
    if (selectedReportsFolder === oldPath || selectedReportsFolder.startsWith(`${oldPath}/`)) {
      selectedReportsFolder = selectedReportsFolder === oldPath
        ? renamedPath
        : `${renamedPath}/${selectedReportsFolder.slice(oldPath.length + 1)}`;
      localStorage.setItem("dtc-selected-reports-folder", selectedReportsFolder);
    }

    reportsStatus.textContent = payload.message || "Folder renamed.";
    reportsLoaded = false;
    await loadReports();
  } catch (error) {
    reportsStatus.textContent = error.message;
  }
}

async function deleteReportFolder(folderPath) {
  const normalizedPath = normalizeClientFolderPath(folderPath);
  if (!normalizedPath) {
    reportsStatus.textContent = "Select a folder under Reports to delete.";
    return;
  }

  const folderLabel = `Reports/${normalizedPath}`;
  const confirmed = window.confirm(`Delete ${folderLabel} and all reports inside it?`);
  if (!confirmed) {
    return;
  }

  reportsStatus.textContent = "Deleting folder...";
  try {
    const response = await fetch("/api/reports/folder/delete", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        path: normalizedPath
      })
    });
    const payload = await response.json();
    if (!response.ok || !payload.ok) {
      throw new Error(payload.error || payload.detail || "Could not delete folder");
    }

    if (selectedReportsFolder === normalizedPath || selectedReportsFolder.startsWith(`${normalizedPath}/`)) {
      selectedReportsFolder = "";
      localStorage.setItem("dtc-selected-reports-folder", selectedReportsFolder);
    }
    if (reportsSelectedName.textContent === normalizedPath || reportsSelectedName.textContent.startsWith(`${normalizedPath}/`)) {
      reportsSelectedName.textContent = "No report selected";
      reportsPdfFrame.removeAttribute("src");
    }

    reportsStatus.textContent = payload.message || "Folder deleted.";
    reportsLoaded = false;
    await loadReports();
  } catch (error) {
    reportsStatus.textContent = error.message;
  }
}

function selectReportsFolder(folderPath) {
  selectedReportsFolder = normalizeClientFolderPath(folderPath);
  localStorage.setItem("dtc-selected-reports-folder", selectedReportsFolder);
  updateSelectedReportsFolderLabel();
  reportsFileList.querySelectorAll("[data-report-folder]").forEach((button) => {
    button.classList.toggle("selected", normalizeClientFolderPath(button.dataset.reportFolder || "") === selectedReportsFolder);
  });
}

function updateSelectedReportsFolderLabel() {
  if (!selectedReportsFolderLabel) {
    return;
  }
  selectedReportsFolderLabel.textContent = selectedReportsFolder ? `Reports/${selectedReportsFolder}` : "Reports";
  selectedReportsFolderLabel.title = selectedReportsFolderLabel.textContent;
}

async function createReportsFolder() {
  const parentLabel = selectedReportsFolder ? `Reports/${selectedReportsFolder}` : "Reports";
  const folderName = window.prompt(`Create folder under ${parentLabel}`, "New Folder");
  if (folderName === null) {
    return;
  }
  const trimmedName = folderName.trim();
  if (!trimmedName) {
    reportsStatus.textContent = "Enter a folder name.";
    return;
  }

  reportsStatus.textContent = "Creating folder...";
  try {
    const response = await fetch("/api/reports/folder", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        parent: selectedReportsFolder,
        name: trimmedName
      })
    });
    const payload = await response.json();
    if (!response.ok || !payload.ok) {
      throw new Error(payload.error || payload.detail || "Could not create folder");
    }
    selectedReportsFolder = payload.path || selectedReportsFolder;
    localStorage.setItem("dtc-selected-reports-folder", selectedReportsFolder);
    reportsStatus.textContent = `${payload.message || "Folder created."} Refreshing Reports folder...`;
    reportsLoaded = false;
    await loadReports();
  } catch (error) {
    reportsStatus.textContent = error.message;
  }
}

function handleReportDragStart(event) {
  const row = event.currentTarget;
  const file = reportsFiles[Number(row.dataset.reportDragIndex)];
  if (!file) {
    return;
  }
  event.dataTransfer.effectAllowed = "move";
  event.dataTransfer.setData("text/plain", file.path);
  row.classList.add("is-dragging");
}

function handleReportDragEnd(event) {
  event.currentTarget.classList.remove("is-dragging");
  reportsFileList.querySelectorAll(".is-drop-target").forEach((target) => target.classList.remove("is-drop-target"));
}

function handleReportsFolderDragOver(event) {
  event.preventDefault();
  event.dataTransfer.dropEffect = "move";
  event.currentTarget.classList.add("is-drop-target");
}

function handleReportsFolderDragLeave(event) {
  event.currentTarget.classList.remove("is-drop-target");
}

async function handleReportsFolderDrop(event) {
  event.preventDefault();
  const target = event.currentTarget;
  target.classList.remove("is-drop-target");
  const filePath = event.dataTransfer.getData("text/plain");
  const targetFolder = normalizeClientFolderPath(target.dataset.reportFolder || "");
  if (!filePath) {
    return;
  }
  await moveReportFile(filePath, targetFolder);
}

async function moveReportFile(filePath, targetFolder) {
  reportsStatus.textContent = "Moving report...";
  try {
    const response = await fetch("/api/reports/move", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        path: filePath,
        targetFolder
      })
    });
    const payload = await response.json();
    if (!response.ok || !payload.ok) {
      throw new Error(payload.error || payload.detail || "Could not move report");
    }
    selectedReportsFolder = targetFolder;
    localStorage.setItem("dtc-selected-reports-folder", selectedReportsFolder);
    reportsStatus.textContent = payload.message || "Report moved.";
    reportsLoaded = false;
    await loadReports();
    if (payload.path) {
      const movedFile = reportsFiles.find((file) => file.path === payload.path);
      if (movedFile) {
        const row = reportsFileList.querySelector(`[data-report-drag-index="${reportsFiles.indexOf(movedFile)}"]`);
        selectReportFile(movedFile, row);
      }
    }
  } catch (error) {
    reportsStatus.textContent = error.message;
  }
}

function normalizeClientFolderPath(value) {
  return String(value || "").replaceAll("\\", "/").replace(/^\/+|\/+$/g, "");
}

function formatReportMeta(file) {
  const folder = file.folder || "Reports";
  const size = formatBytes(file.size);
  const type = String(file.type || "").toUpperCase();
  const modified = file.modifiedAt ? new Date(file.modifiedAt).toLocaleString() : "";
  return [type, folder, size, modified].filter(Boolean).join(" | ");
}

function formatBytes(value) {
  const bytes = Number(value);
  if (!Number.isFinite(bytes) || bytes < 0) {
    return "";
  }
  if (bytes < 1024) {
    return `${bytes} B`;
  }
  if (bytes < 1024 * 1024) {
    return `${(bytes / 1024).toFixed(1)} KB`;
  }
  return `${(bytes / (1024 * 1024)).toFixed(1)} MB`;
}

async function loadMarkdownUploadConfig() {
  refreshMarkdownUploadButton.disabled = true;
  markdownUploadStatus.textContent = "Loading...";

  try {
    const response = await fetch("/api/markdown-upload");
    const payload = await response.json();
    if (!response.ok || !payload.ok) {
      throw new Error(payload.detail || payload.error || "Could not load markdown upload settings");
    }

    const target = payload.target;
    markdownUploadLocation.textContent = target
      ? `Target: ${payload.storageLocation} | Upload prefix: ${target.objectPrefix || "(bucket root)"} | Pattern: ${target.objectPattern || "*"}`
      : payload.error || "OCI_STORAGE_LOCATION is not configured.";
    uploadMarkdownButton.disabled = Boolean(payload.error);
    markdownUploadStatus.textContent = payload.error ? payload.error : "Ready to upload markdown files.";
    markdownUploadLoaded = true;
  } catch (error) {
    markdownUploadLocation.textContent = "";
    uploadMarkdownButton.disabled = true;
    markdownUploadStatus.textContent = error.message;
  } finally {
    refreshMarkdownUploadButton.disabled = false;
  }
}

async function uploadMarkdownFile(event) {
  event.preventDefault();

  const file = markdownFile.files && markdownFile.files[0];
  if (!file) {
    markdownUploadStatus.textContent = "Select a markdown file to upload.";
    return;
  }

  if (!/\.(md|markdown)$/i.test(file.name)) {
    markdownUploadStatus.textContent = "Only .md or .markdown files can be uploaded.";
    markdownFile.value = "";
    return;
  }

  uploadMarkdownButton.disabled = true;
  refreshMarkdownUploadButton.disabled = true;
  markdownUploadStatus.textContent = "Uploading markdown file, then rebuilding the RAG vector index. This can take a few minutes...";
  setConsoleActionStatus("Uploading document and rebuilding RAG index", "running");

  try {
    const formData = new FormData();
    formData.append("file", file);
    const response = await fetch("/api/markdown-upload", {
      method: "POST",
      body: formData
    });
    const payload = await response.json();
    if (!response.ok || !payload.ok) {
      throw new Error(payload.detail || payload.error || "Could not upload markdown file");
    }

    const vectorization = payload.vectorization || {};
    const chunkSummary = Number.isFinite(Number(vectorization.chunkCountAfter))
      ? ` Vector table ${vectorization.vectorTable} now has ${vectorization.chunkCountAfter} chunks.`
      : "";
    const elapsedSummary = Number.isFinite(Number(vectorization.elapsedMs))
      ? ` Completed in ${formatElapsedMs(Number(vectorization.elapsedMs))}.`
      : "";
    const summary = `${payload.message} Object: ${payload.objectName}.${chunkSummary}${elapsedSummary}`;
    markdownUploadStatus.textContent = summary;
    setConsoleActionStatus(formatRagIndexStatus(payload), "done", summary);
    markdownFile.value = "";
    ragLoaded = false;
    loadRag().catch(() => undefined);
  } catch (error) {
    markdownUploadStatus.textContent = error.message;
    setConsoleActionStatus("RAG upload failed", "error", error.message);
  } finally {
    uploadMarkdownButton.disabled = false;
    refreshMarkdownUploadButton.disabled = false;
  }
}

async function uploadSelectedReportToRag() {
  if (!selectedReportFile) {
    reportsStatus.textContent = "Select a report in the file browser first.";
    setReportsUploadConfirmation();
    return;
  }

  uploadReportsKnowledgeButton.disabled = true;
  refreshReportsButton.disabled = true;
  setReportsUploadConfirmation();
  reportsStatus.textContent = `Uploading ${selectedReportFile.path} to OCI Object Storage, then rebuilding the RAG vector index. This can take a few minutes...`;
  setConsoleActionStatus("Uploading report and rebuilding RAG index", "running");

  try {
    const response = await fetch("/api/reports/upload-rag", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        path: selectedReportFile.path
      })
    });
    const payload = await response.json();
    if (!response.ok || !payload.ok) {
      throw new Error(payload.detail || payload.error || "Could not upload selected report for RAG indexing");
    }

    const summary = formatMarkdownUploadSummary(payload);
    reportsStatus.textContent = summary;
    setReportsUploadConfirmation("Upload and vectorization completed.", summary);
    setConsoleActionStatus(formatRagIndexStatus(payload), "done", summary);
    ragLoaded = false;
    loadRag().catch(() => undefined);
  } catch (error) {
    setReportsUploadConfirmation();
    reportsStatus.textContent = error.message;
    setConsoleActionStatus("RAG upload failed", "error", error.message);
  } finally {
    updateReportsRagUploadButton();
    refreshReportsButton.disabled = false;
  }
}

async function loadProfiles() {
  refreshProfilesButton.disabled = true;
  profilesStatus.textContent = "Loading...";

  try {
    const response = await fetch("/api/select-ai-profiles");
    const payload = await response.json();
    if (!response.ok || !payload.ok) {
      throw new Error(payload.detail || payload.error || "Could not load Select AI profiles");
    }

    renderMetadataTable(profilesTable, payload.profiles, {
      emptyText: "No Select AI profiles found.",
      defaultName: payload.defaultProfile
    });
    profilesCount.textContent = String((payload.profiles && payload.profiles.rows || []).length);
    profilesStatus.textContent = payload.profiles && payload.profiles.available
      ? "Loaded"
      : "Select AI profile metadata view is not available for this user.";
    profilesLoaded = true;
  } catch (error) {
    profilesTable.innerHTML = "";
    profilesCount.textContent = "0";
    profilesStatus.textContent = error.message;
  } finally {
    refreshProfilesButton.disabled = false;
  }
}

function renderMetadataTable(container, metadata, options = {}) {
  const rows = metadata && metadata.rows || [];
  const columns = metadata && metadata.columns || [];

  if (!metadata || !metadata.available) {
    container.innerHTML = `<div class="empty-state">${escapeHtml(metadata && metadata.viewName || "Metadata view")} is not available.</div>`;
    return;
  }

  if (!rows.length) {
    container.innerHTML = `<div class="empty-state">${escapeHtml(options.emptyText || "No rows found.")}</div>`;
    return;
  }

  const effectiveSelectedName = options.radioName
    ? getEffectiveSelectedName(rows, options.selectedName || options.defaultName)
    : "";
  if (options.radioName && effectiveSelectedName) {
    selectedAgentTeamName = effectiveSelectedName;
  }

  const header = [
    options.radioName ? `<th>${formatTableHeader("Select")}</th>` : "",
    ...columns.map((column) => `<th>${formatTableHeader(column)}</th>`)
  ].join("");
  const body = rows.map((row) => {
    const nameValue = getMetadataName(row);
    const isDefault = options.defaultName && nameValue.toLowerCase() === String(options.defaultName).toLowerCase();
    const isSelected = effectiveSelectedName && nameValue.toLowerCase() === effectiveSelectedName.toLowerCase();
    const radioCell = options.radioName
      ? `<td><input type="radio" name="${escapeHtml(options.radioName)}" value="${escapeHtml(nameValue)}"${isSelected ? " checked" : ""}></td>`
      : "";
    const cells = columns.map((column) => {
      const value = row[column] || "";
      const label = isDefault && column === getNameColumn(row)
        ? `${escapeHtml(value)} <span class="inline-pill">Default</span>`
        : escapeHtml(value);
      return `<td>${label}</td>`;
    }).join("");
    return `<tr>${radioCell}${cells}</tr>`;
  }).join("");

  container.innerHTML = `
    <table>
      <thead><tr>${header}</tr></thead>
      <tbody>${body}</tbody>
    </table>`;

  if (options.radioName && typeof options.onSelect === "function") {
    container.querySelectorAll(`input[name="${options.radioName}"]`).forEach((input) => {
      input.addEventListener("change", () => options.onSelect(input.value));
    });
  }
}

function renderRowsTable(container, columns, rows, emptyText) {
  if (!rows.length) {
    container.innerHTML = `<div class="empty-state">${escapeHtml(emptyText)}</div>`;
    return;
  }

  const header = columns.map((column) => `<th>${formatTableHeader(column)}</th>`).join("");
  const body = rows.map((row) => {
    const cells = columns.map((column) => `<td>${escapeHtml(row[column] || "")}</td>`).join("");
    return `<tr>${cells}</tr>`;
  }).join("");

  container.innerHTML = `
    <table>
      <thead><tr>${header}</tr></thead>
      <tbody>${body}</tbody>
    </table>`;
}

function renderLatestTaskExecutionTable(columns, rows) {
  if (!rows.length) {
    latestTaskTable.innerHTML = '<div class="empty-state">No latest task execution rows found for this team.</div>';
    return;
  }

  const displayColumns = columns.length ? columns : Object.keys(rows[0]);
  const header = [
    ...displayColumns.map((column) => `<th>${formatTableHeader(column)}</th>`),
    `<th>${formatTableHeader("More Info")}</th>`
  ].join("");
  const body = rows.map((row, index) => {
    const cells = displayColumns.map((column) => {
      const value = row[column] || "";
      const displayValue = column === "PROMPT_RESPONSE" ? truncateText(value, 360) : value;
      const className = column === "PROMPT_RESPONSE" ? ' class="prompt-response-preview"' : "";
      return `<td${className}>${escapeHtml(displayValue)}</td>`;
    }).join("");

    return `
      <tr class="task-result-row" data-latest-task-index="${index}" tabindex="0">
        ${cells}
        <td><button type="button" class="more-link" data-latest-task-index="${index}">More info</button></td>
      </tr>`;
  }).join("");

  latestTaskTable.innerHTML = `
    <table>
      <thead><tr>${header}</tr></thead>
      <tbody>${body}</tbody>
    </table>`;
}

function selectAgentTeam(team) {
  selectedAgentTeamName = team;
  latestTaskTable.innerHTML = "";
  latestTaskRows = [];
  updateLatestTaskControls();
}

function updateLatestTaskControls() {
  runLatestTaskButton.disabled = !selectedAgentTeamName;
  changeDefaultTeamButton.disabled = !selectedAgentTeamName
    || selectedAgentTeamName.toLowerCase() === String(currentDefaultTeamName || "").toLowerCase();
  if (selectedAgentTeamName) {
    const defaultText = selectedAgentTeamName.toLowerCase() === String(currentDefaultTeamName || "").toLowerCase()
      ? " This is the default team."
      : "";
    latestTaskStatus.textContent = `Selected ${selectedAgentTeamName}.${defaultText}`;
  }
}

async function changeDefaultAgentTeam() {
  if (!selectedAgentTeamName) {
    agentsStatus.textContent = "Select an agent team first.";
    return;
  }

  changeDefaultTeamButton.disabled = true;
  agentsStatus.textContent = `Saving ${selectedAgentTeamName} as the default team...`;

  try {
    const response = await fetch("/api/config", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ values: { AI_AGENT_TEAM: selectedAgentTeamName } })
    });
    const payload = await response.json();
    if (!response.ok || !payload.ok) {
      throw new Error(payload.detail || payload.error || "Could not change default team");
    }

    publicConfig = payload.config || publicConfig;
    currentDefaultTeamName = publicConfig.teamName || selectedAgentTeamName;
    teamName.value = currentDefaultTeamName;
    agentsLoaded = false;
    await loadAgents();
    agentsStatus.textContent = `${currentDefaultTeamName} saved as default team in .env. Restarting application server...`;
    await restartApplicationServer();
    agentsStatus.textContent = `${currentDefaultTeamName} is now the default team. Application server restarted.`;
  } catch (error) {
    agentsStatus.textContent = error.message;
    updateLatestTaskControls();
  }
}

async function restartApplicationServer() {
  await fetch("/api/restart", { method: "POST" }).catch(() => undefined);
  await waitForServerHealth();
}

async function waitForServerHealth() {
  const startedAt = Date.now();
  while (Date.now() - startedAt < 15000) {
    await sleep(800);
    try {
      const response = await fetch("/api/health", { cache: "no-store" });
      if (response.ok) {
        await checkHealth();
        return;
      }
    } catch {
      // Server is still restarting.
    }
  }
  throw new Error("Default team saved, but the server did not respond after restart.");
}

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function getEffectiveSelectedName(rows, preferredName) {
  const preferred = String(preferredName || "");
  const preferredRow = rows.find((row) => {
    return getMetadataName(row).toLowerCase() === preferred.toLowerCase();
  });
  return getMetadataName(preferredRow || rows[0] || {});
}

function handleLatestTaskRowClick(event) {
  const target = event.target.closest("[data-latest-task-index]");
  if (!target) {
    return;
  }
  openLatestTaskPromptResponse(Number(target.dataset.latestTaskIndex));
}

function openLatestTaskPromptResponse(index) {
  const row = latestTaskRows[index];
  if (!row) {
    return;
  }

  const html = renderPromptResponsePopup(row);
  openHtmlPopup(html, "Allow pop-ups to open prompt response");
}

function openHtmlPopup(html, blockedMessage) {
  const blob = new Blob([injectResizeScript(html)], { type: "text/html" });
  const url = URL.createObjectURL(blob);
  const width = Math.min(1120, Math.max(720, window.screen.availWidth - 120));
  const height = Math.min(820, Math.max(560, window.screen.availHeight - 120));
  const screenLeft = window.screen.availLeft || window.screenLeft || 0;
  const screenTop = window.screen.availTop || window.screenTop || 0;
  const left = Math.max(0, Math.round((window.screen.availWidth - width) / 2 + screenLeft));
  const top = Math.max(0, Math.round((window.screen.availHeight - height) / 2 + screenTop));
  const features = `popup=yes,width=${width},height=${height},left=${left},top=${top}`;
  const opened = window.open(url, "_blank", features);
  if (!opened) {
    latestTaskStatus.textContent = blockedMessage;
  }
  setTimeout(() => URL.revokeObjectURL(url), 60000);
}

function renderPromptResponsePopup(row) {
  const response = stripWrappingCodeFence(row.PROMPT_RESPONSE || "");
  const prompt = stripWrappingCodeFence(row.PROMPT || "");
  const content = renderFriendlyPromptResponse(response || "No prompt response returned.");
  const promptBlock = prompt
    ? `<section><h2>Prompt</h2><div class="plain-text">${formatFriendlyText(prompt)}</div></section>`
    : "";

  return `<!doctype html>
<html>
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Prompt Response</title>
    <style>
      body {
        margin: 0;
        padding: 28px;
        color: #182333;
        background: #f7f8fb;
        font: 14px/1.55 "Oracle Sans", "OracleSans", "Redwood", system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
      }
      main {
        max-width: 1080px;
        margin: 0 auto;
      }
      header,
      section {
        margin-bottom: 16px;
        border: 1px solid #d9e0ea;
        border-radius: 8px;
        background: #fff;
        box-shadow: 0 10px 28px rgba(15, 23, 42, 0.08);
      }
      header {
        padding: 18px 20px;
      }
      section {
        padding: 18px 20px;
      }
      h1,
      h2,
      h3 {
        margin: 0 0 10px;
        line-height: 1.25;
      }
      h1 {
        font-size: 22px;
      }
      h2 {
        font-size: 16px;
      }
      h3 {
        font-size: 14px;
      }
      .meta {
        display: flex;
        flex-wrap: wrap;
        gap: 8px;
        margin-top: 10px;
      }
      .pill {
        display: inline-flex;
        min-height: 24px;
        align-items: center;
        border: 1px solid #d9e0ea;
        border-radius: 999px;
        padding: 0 9px;
        background: #f8fafc;
        color: #475569;
        font-size: 12px;
        font-weight: 700;
      }
      .plain-text {
        white-space: pre-wrap;
        word-break: break-word;
      }
      pre {
        overflow: auto;
        margin: 10px 0 0;
        padding: 13px 14px;
        border: 1px solid #d9e0ea;
        border-radius: 8px;
        background: #101827;
        color: #e5edf7;
        white-space: pre-wrap;
        word-break: break-word;
        font: 12px/1.55 ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", monospace;
      }
      table {
        width: 100%;
        border-collapse: collapse;
        margin-top: 10px;
        font-size: 13px;
      }
      th,
      td {
        padding: 9px 10px;
        border: 1px solid #d9e0ea;
        text-align: left;
        vertical-align: top;
      }
      th {
        background: #eef3f8;
      }
      .table-heading {
        display: inline-flex;
        align-items: center;
        gap: 7px;
      }
      .table-icon {
        width: 14px;
        height: 14px;
        flex: 0 0 auto;
        fill: none;
        stroke: currentColor;
        stroke-width: 2;
        stroke-linecap: round;
        stroke-linejoin: round;
      }
      .icon-action { color: #f97316; }
      .icon-select { color: #22c55e; }
      .icon-info { color: #38bdf8; }
      .icon-identity { color: #a78bfa; }
      .icon-workflow { color: #14b8a6; }
      .icon-message { color: #fb7185; }
      .icon-time { color: #f59e0b; }
      .icon-status { color: #84cc16; }
      .icon-setting { color: #eab308; }
      .icon-key { color: #c084fc; }
      .icon-link { color: #06b6d4; }
      .icon-metric { color: #60a5fa; }
      .icon-table { color: #64748b; }
    </style>
  </head>
  <body>
    <main>
      <header>
        <h1>Latest Team Task Execution Response</h1>
        <div class="meta">
          <span class="pill">Team: ${escapeHtml(row.TEAM_NAME || "")}</span>
          <span class="pill">Task: ${escapeHtml(row.TASK_NAME || "")}</span>
          <span class="pill">Agent: ${escapeHtml(row.AGENT_NAME || "")}</span>
        </div>
      </header>
      ${promptBlock}
      ${content}
    </main>
  </body>
</html>`;
}

function renderFriendlyPromptResponse(text) {
  const segments = splitPromptResponseSegments(text);
  return segments.map((segment) => {
    if (segment.type === "json") {
      return renderJsonSection(segment.title, segment.value);
    }
    return renderTextSections(segment.value);
  }).join("");
}

function splitPromptResponseSegments(text) {
  const segments = [];
  const jsonFencePattern = /```json\s*([\s\S]*?)```/gi;
  let index = 0;

  while (index < text.length) {
    jsonFencePattern.lastIndex = index;
    const fenceMatch = jsonFencePattern.exec(text);
    const observationIndex = text.indexOf("Observation:", index);
    const hasFence = Boolean(fenceMatch);
    const nextFenceIndex = hasFence ? fenceMatch.index : -1;
    const useObservation = observationIndex >= 0 && (!hasFence || observationIndex < nextFenceIndex);

    if (useObservation) {
      pushTextSegment(segments, text.slice(index, observationIndex));
      const jsonStart = text.indexOf("{", observationIndex);
      if (jsonStart < 0) {
        pushTextSegment(segments, text.slice(observationIndex));
        break;
      }
      const jsonEnd = findBalancedJsonEnd(text, jsonStart);
      if (jsonEnd < 0) {
        pushTextSegment(segments, text.slice(observationIndex));
        break;
      }
      segments.push({ type: "json", title: "Observation", value: text.slice(jsonStart, jsonEnd + 1) });
      index = jsonEnd + 1;
      continue;
    }

    if (hasFence) {
      pushTextSegment(segments, text.slice(index, fenceMatch.index));
      segments.push({ type: "json", title: "Action Input", value: fenceMatch[1] });
      index = jsonFencePattern.lastIndex;
      continue;
    }

    pushTextSegment(segments, text.slice(index));
    break;
  }

  return segments;
}

function pushTextSegment(segments, value) {
  const text = value.trim();
  if (text) {
    segments.push({ type: "text", value: text });
  }
}

function renderTextSections(text) {
  const normalized = text
    .replace(/^Thought:/gm, "\nThought:")
    .replace(/^Action:/gm, "\nAction:")
    .replace(/^Final Answer:/gm, "\nFinal Answer:");
  const sectionPattern = /(?:^|\n)(Thought|Action|Final Answer):\s*([\s\S]*?)(?=\n(?:Thought|Action|Final Answer):|$)/g;
  const sections = [];
  let match;

  while ((match = sectionPattern.exec(normalized)) !== null) {
    sections.push(`<section><h2>${escapeHtml(match[1])}</h2><div class="plain-text">${formatFriendlyText(match[2].trim())}</div></section>`);
  }

  if (sections.length) {
    return sections.join("");
  }

  return `<section><div class="plain-text">${formatFriendlyText(normalized.trim())}</div></section>`;
}

function renderJsonSection(title, rawJson) {
  const parsed = parseJson(rawJson);
  if (parsed == null) {
    return `<section><h2>${escapeHtml(title)}</h2><pre>${escapeHtml(rawJson.trim())}</pre></section>`;
  }

  const nestedResult = typeof parsed.result === "string" ? parseJson(parsed.result) : null;
  const resultTable = Array.isArray(nestedResult) ? renderJsonArrayTable(nestedResult) : "";
  const payload = nestedResult ? { ...parsed, result: nestedResult } : parsed;

  return `<section>
    <h2>${escapeHtml(title)}</h2>
    ${resultTable}
    <pre>${escapeHtml(JSON.stringify(payload, null, 2))}</pre>
  </section>`;
}

function renderJsonArrayTable(rows) {
  if (!rows.length || !rows.every((row) => row && typeof row === "object" && !Array.isArray(row))) {
    return "";
  }

  const columns = [...rows.reduce((keys, row) => {
    Object.keys(row).forEach((key) => keys.add(key));
    return keys;
  }, new Set())];
  const header = columns.map((column) => `<th>${formatTableHeader(column)}</th>`).join("");
  const body = rows.map((row) => {
    const cells = columns.map((column) => `<td>${escapeHtml(formatJsonValue(row[column]))}</td>`).join("");
    return `<tr>${cells}</tr>`;
  }).join("");

  return `<table><thead><tr>${header}</tr></thead><tbody>${body}</tbody></table>`;
}

function formatJsonValue(value) {
  if (value == null) {
    return "";
  }
  if (typeof value === "object") {
    return JSON.stringify(value, null, 2);
  }
  return String(value);
}

function parseJson(value) {
  try {
    return JSON.parse(String(value || "").trim());
  } catch {
    return null;
  }
}

function findBalancedJsonEnd(text, startIndex) {
  let depth = 0;
  let inString = false;
  let escaped = false;

  for (let index = startIndex; index < text.length; index += 1) {
    const char = text[index];
    if (inString) {
      if (escaped) {
        escaped = false;
      } else if (char === "\\") {
        escaped = true;
      } else if (char === '"') {
        inString = false;
      }
      continue;
    }

    if (char === '"') {
      inString = true;
    } else if (char === "{") {
      depth += 1;
    } else if (char === "}") {
      depth -= 1;
      if (depth === 0) {
        return index;
      }
    }
  }

  return -1;
}

function stripWrappingCodeFence(value) {
  const text = String(value || "").trim();
  const match = text.match(/^```(?:\w+)?\s*([\s\S]*?)```$/);
  return match ? match[1].trim() : text;
}

function formatFriendlyText(text) {
  return escapeHtml(text)
    .replace(/\*\*(.*?)\*\*/g, "<strong>$1</strong>")
    .replace(/^- (.*)$/gm, "&bull; $1");
}

function truncateText(value, maxLength) {
  const text = String(value || "").trim();
  if (text.length <= maxLength) {
    return text;
  }
  return `${text.slice(0, maxLength).trimEnd()}...`;
}

function renderConfig(config) {
  const runtime = config.runtimeConfig || {};
  const databaseConfigs = runtime.databaseConfigs || [];
  const llmConfigs = runtime.llmConfigs || [];
  const databaseFields = runtime.databaseFields || [];
  const llmFields = runtime.llmFields || [];

  if (!selectedDatabaseConfigName || !databaseConfigs.some((item) => item.name === selectedDatabaseConfigName)) {
    selectedDatabaseConfigName = runtime.defaultDatabase || databaseConfigs[0] && databaseConfigs[0].name || "__new";
  }
  if (!selectedLlmConfigName || !llmConfigs.some((item) => item.name === selectedLlmConfigName)) {
    selectedLlmConfigName = runtime.defaultLlm || llmConfigs[0] && llmConfigs[0].name || "__new";
  }

  const selectedDatabase = selectedDatabaseConfigName === "__new"
    ? { name: getNextConfigName(databaseConfigs, "database"), values: {}, configured: {} }
    : databaseConfigs.find((item) => item.name === selectedDatabaseConfigName) || { name: "", values: {}, configured: {} };
  const selectedLlm = selectedLlmConfigName === "__new"
    ? { name: getNextConfigName(llmConfigs, "llm"), values: {}, configured: {} }
    : llmConfigs.find((item) => item.name === selectedLlmConfigName) || { name: "", values: {}, configured: {} };

  configTable.innerHTML = `
    <div class="config-json-shell">
      <section class="metadata-section">
        <div class="section-title-row">
          <h3>Default Configurations</h3>
        </div>
        <form id="configDefaultsForm" class="config-form config-editor-form">
          <div class="builder-fields">
            <div class="field">
              <label for="defaultDatabaseConfig">Default database</label>
              <select id="defaultDatabaseConfig" name="defaultDatabase">
                ${databaseConfigs.map((item) => `<option value="${escapeHtml(item.name)}"${item.name === runtime.defaultDatabase ? " selected" : ""}>${escapeHtml(item.name)}</option>`).join("")}
              </select>
            </div>
            <div class="field">
              <label for="defaultLlmConfig">Default LLM</label>
              <select id="defaultLlmConfig" name="defaultLlm">
                ${llmConfigs.map((item) => `<option value="${escapeHtml(item.name)}"${item.name === runtime.defaultLlm ? " selected" : ""}>${escapeHtml(item.name)}</option>`).join("")}
              </select>
            </div>
          </div>
          <div class="config-actions">
            <span id="configSaveStatus" class="metadata-status">Saving updates writes to ${escapeHtml(runtime.path || config.configPath || "config/runtime-config.json")}.</span>
            <button type="submit">Set Defaults</button>
          </div>
        </form>
      </section>

      <section class="metadata-section">
        <div class="section-title-row">
          <h3>Database Configuration</h3>
          <button type="button" id="addDatabaseConfigButton">Add New Database</button>
        </div>
        <form id="databaseConfigForm" class="config-form config-editor-form">
          <div class="builder-fields">
            <div class="field">
              <label for="databaseConfigSelect">Edit database</label>
              <select id="databaseConfigSelect">
                ${databaseConfigs.map((item) => `<option value="${escapeHtml(item.name)}"${item.name === selectedDatabaseConfigName ? " selected" : ""}>${escapeHtml(item.name)}${item.isDefault ? " (default)" : ""}</option>`).join("")}
                <option value="__new"${selectedDatabaseConfigName === "__new" ? " selected" : ""}>Add new database</option>
              </select>
            </div>
            <div class="field">
              <label for="databaseConfigName">Configuration name</label>
              <input id="databaseConfigName" name="configName" value="${escapeHtml(selectedDatabase.name || "")}" autocomplete="off" required>
            </div>
          </div>
          <div class="config-field-grid">
            ${renderConfigFieldInputs(databaseFields, selectedDatabase, "database")}
          </div>
          <div class="config-actions">
            <span class="metadata-status">Add or update a database node in the JSON file.</span>
            <button type="submit">Save Database</button>
          </div>
        </form>
      </section>

      <section class="metadata-section">
        <div class="section-title-row">
          <h3>LLM Configuration</h3>
          <button type="button" id="addLlmConfigButton">Add New LLM</button>
        </div>
        <form id="llmConfigForm" class="config-form config-editor-form">
          <div class="builder-fields">
            <div class="field">
              <label for="llmConfigSelect">Edit LLM</label>
              <select id="llmConfigSelect">
                ${llmConfigs.map((item) => `<option value="${escapeHtml(item.name)}"${item.name === selectedLlmConfigName ? " selected" : ""}>${escapeHtml(item.name)}${item.isDefault ? " (default)" : ""}</option>`).join("")}
                <option value="__new"${selectedLlmConfigName === "__new" ? " selected" : ""}>Add new LLM</option>
              </select>
            </div>
            <div class="field">
              <label for="llmConfigName">Configuration name</label>
              <input id="llmConfigName" name="configName" value="${escapeHtml(selectedLlm.name || "")}" autocomplete="off" required>
            </div>
          </div>
          <div class="config-field-grid">
            ${renderConfigFieldInputs(llmFields, selectedLlm, "llm")}
          </div>
          <div class="config-actions">
            <span class="metadata-status">Add or update an LLM node in the JSON file.</span>
            <button type="submit">Save LLM</button>
          </div>
        </form>
      </section>
    </div>`;

  configTable.querySelector("#configDefaultsForm").addEventListener("submit", saveConfigDefaults);
  configTable.querySelector("#databaseConfigForm").addEventListener("submit", saveDatabaseConfig);
  configTable.querySelector("#llmConfigForm").addEventListener("submit", saveLlmConfig);
  configTable.querySelector("#addDatabaseConfigButton").addEventListener("click", () => {
    selectedDatabaseConfigName = "__new";
    renderConfig(publicConfig);
    configTable.querySelector("#databaseConfigName").focus();
  });
  configTable.querySelector("#addLlmConfigButton").addEventListener("click", () => {
    selectedLlmConfigName = "__new";
    renderConfig(publicConfig);
    configTable.querySelector("#llmConfigName").focus();
  });
  configTable.querySelector("#databaseConfigSelect").addEventListener("change", (event) => {
    selectedDatabaseConfigName = event.target.value;
    renderConfig(publicConfig);
  });
  configTable.querySelector("#llmConfigSelect").addEventListener("change", (event) => {
    selectedLlmConfigName = event.target.value;
    renderConfig(publicConfig);
  });
}

function getNextConfigName(configs, prefix) {
  const names = new Set((configs || []).map((item) => String(item.name || "").toLowerCase()));
  let index = (configs || []).length + 1;
  let name = `${prefix}_${index}`;
  while (names.has(name.toLowerCase())) {
    index += 1;
    name = `${prefix}_${index}`;
  }
  return name;
}

function renderConfigFieldInputs(fields, configNode, prefix) {
  return fields.map((field) => {
    const value = configNode.values && configNode.values[field.key] || "";
    const configured = configNode.configured && configNode.configured[field.key];
    const input = field.type === "boolean"
      ? `<select name="${escapeHtml(field.key)}">
          <option value="true"${String(value || "true").toLowerCase() !== "false" ? " selected" : ""}>Enabled</option>
          <option value="false"${String(value || "").toLowerCase() === "false" ? " selected" : ""}>Disabled</option>
        </select>`
      : `<input type="${field.type === "password" ? "password" : "text"}" name="${escapeHtml(field.key)}" value="${escapeHtml(value)}" placeholder="${field.secret && configured ? "Configured; leave blank to keep existing" : ""}" autocomplete="off" spellcheck="false">`;
    return `
      <div class="field">
        <label for="${escapeHtml(prefix)}-${escapeHtml(field.key)}">${escapeHtml(field.label)}</label>
        ${input.replace("<input ", `<input id="${escapeHtml(prefix)}-${escapeHtml(field.key)}" `).replace("<select ", `<select id="${escapeHtml(prefix)}-${escapeHtml(field.key)}" `)}
        <span class="config-key">${escapeHtml(field.key)}</span>
      </div>`;
  }).join("");
}

async function saveConfigDefaults(event) {
  event.preventDefault();
  const form = event.currentTarget;
  const status = form.querySelector("#configSaveStatus");
  const button = form.querySelector('button[type="submit"]');
  button.disabled = true;
  status.textContent = "Saving default selections...";

  const runtimeConfig = buildRuntimeConfigPayload();
  runtimeConfig.defaultDatabase = form.querySelector('[name="defaultDatabase"]').value;
  runtimeConfig.defaultLlm = form.querySelector('[name="defaultLlm"]').value;

  await saveRuntimeConfigPayload(runtimeConfig, status, button, "Default configuration updated.");
}

async function saveDatabaseConfig(event) {
  event.preventDefault();
  const form = event.currentTarget;
  const status = form.querySelector(".metadata-status");
  const button = form.querySelector('button[type="submit"]');
  const name = normalizeConfigNameInput(form.querySelector('[name="configName"]').value);

  if (!name) {
    status.textContent = "Enter a database configuration name.";
    return;
  }

  button.disabled = true;
  status.textContent = "Saving database configuration...";

  const runtimeConfig = buildRuntimeConfigPayload();
  runtimeConfig.databases[name] = readConfigFormValues(form);
  if (!runtimeConfig.defaultDatabase || selectedDatabaseConfigName === runtimeConfig.defaultDatabase || !Object.keys(runtimeConfig.databases).includes(runtimeConfig.defaultDatabase)) {
    runtimeConfig.defaultDatabase = name;
  }
  selectedDatabaseConfigName = name;

  await saveRuntimeConfigPayload(runtimeConfig, status, button, `Database configuration "${name}" saved.`);
}

async function saveLlmConfig(event) {
  event.preventDefault();
  const form = event.currentTarget;
  const status = form.querySelector(".metadata-status");
  const button = form.querySelector('button[type="submit"]');
  const name = normalizeConfigNameInput(form.querySelector('[name="configName"]').value);

  if (!name) {
    status.textContent = "Enter an LLM configuration name.";
    return;
  }

  button.disabled = true;
  status.textContent = "Saving LLM configuration...";

  const runtimeConfig = buildRuntimeConfigPayload();
  runtimeConfig.llms[name] = readConfigFormValues(form);
  if (!runtimeConfig.defaultLlm || selectedLlmConfigName === runtimeConfig.defaultLlm || !Object.keys(runtimeConfig.llms).includes(runtimeConfig.defaultLlm)) {
    runtimeConfig.defaultLlm = name;
  }
  selectedLlmConfigName = name;

  await saveRuntimeConfigPayload(runtimeConfig, status, button, `LLM configuration "${name}" saved.`);
}

function buildRuntimeConfigPayload() {
  const runtime = publicConfig.runtimeConfig || {};
  return {
    defaultDatabase: runtime.defaultDatabase || "",
    defaultLlm: runtime.defaultLlm || "",
    databases: Object.fromEntries((runtime.databaseConfigs || []).map((item) => [item.name, { ...(item.values || {}) }])),
    llms: Object.fromEntries((runtime.llmConfigs || []).map((item) => [item.name, { ...(item.values || {}) }]))
  };
}

function readConfigFormValues(form) {
  const values = {};
  form.querySelectorAll("[name]").forEach((input) => {
    if (input.name !== "configName") {
      values[input.name] = input.value;
    }
  });
  return values;
}

function normalizeConfigNameInput(value) {
  return String(value || "").trim().replace(/\s+/g, "_");
}

async function saveRuntimeConfigPayload(runtimeConfig, status, button, successMessage) {
  try {
    const response = await fetch("/api/config", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ runtimeConfig })
    });
    const payload = await response.json();
    if (!response.ok || !payload.ok) {
      throw new Error(payload.detail || payload.error || "Could not save settings");
    }

    publicConfig = payload.config || {};
    teamName.value = publicConfig.teamName || "";
    profileName.value = publicConfig.profileName || "";
    renderRuntimeLlmOptions(publicConfig);
    renderConfig(publicConfig);
    const nextStatus = configTable.querySelector("#configSaveStatus") || configTable.querySelector(".metadata-status");
    if (nextStatus) {
      nextStatus.textContent = successMessage || (payload.changedKeys && payload.changedKeys.length
        ? `Saved ${payload.changedKeys.join(", ")}.`
        : "No setting changes to save.");
      if (payload.restartRequired) {
        nextStatus.textContent += " Restarting server to apply default database connection...";
      }
    }
    if (payload.restartRequired) {
      window.setTimeout(checkHealth, 2500);
    } else {
      await checkHealth();
    }
  } catch (error) {
    status.textContent = error.message;
  } finally {
    button.disabled = false;
  }
}

function getMetadataName(row) {
  const nameColumn = getNameColumn(row);
  return nameColumn ? String(row[nameColumn] || "") : "";
}

function getNameColumn(row) {
  return Object.keys(row).find((key) => /(^|_)NAME$/.test(key)) || "";
}

function formatColumnName(column) {
  return escapeHtml(String(column).toLowerCase().replaceAll("_", " ").replace(/\b\w/g, (letter) => letter.toUpperCase()));
}

function formatTableHeader(column) {
  return `<span class="table-heading">${tableHeaderIcon(column)}<span>${formatColumnName(column)}</span></span>`;
}

function tableHeaderIcon(column) {
  const key = String(column || "").toLowerCase();
  if (key.includes("action") || key.includes("delete")) {
    return tableSvg('<path d="M5 12h14"></path><path d="M12 5v14"></path>', "icon-action");
  }
  if (key.includes("select")) {
    return tableSvg('<circle cx="12" cy="12" r="7"></circle><circle cx="12" cy="12" r="2"></circle>', "icon-select");
  }
  if (key.includes("more") || key.includes("info") || key.includes("detail")) {
    return tableSvg('<circle cx="12" cy="12" r="9"></circle><path d="M12 16v-4"></path><path d="M12 8h.01"></path>', "icon-info");
  }
  if (key.includes("name") || key.includes("profile") || key.includes("agent") || key.includes("team")) {
    return tableSvg('<circle cx="12" cy="8" r="3"></circle><path d="M5 20c1.4-4 12.6-4 14 0"></path>', "icon-identity");
  }
  if (key.includes("task") || key.includes("tool") || key.includes("pipeline")) {
    return tableSvg('<path d="M4 7h16"></path><path d="M7 7v12"></path><path d="M17 7v12"></path><path d="M4 19h16"></path>', "icon-workflow");
  }
  if (key.includes("prompt") || key.includes("response") || key.includes("description")) {
    return tableSvg('<path d="M4 5h16v11H8l-4 4z"></path><path d="M8 9h8"></path><path d="M8 13h5"></path>', "icon-message");
  }
  if (key.includes("date") || key.includes("time") || key.includes("created") || key.includes("updated") || key.includes("execution")) {
    return tableSvg('<rect x="4" y="5" width="16" height="15" rx="2"></rect><path d="M8 3v4"></path><path d="M16 3v4"></path><path d="M4 10h16"></path>', "icon-time");
  }
  if (key.includes("status") || key.includes("state") || key.includes("enabled")) {
    return tableSvg('<path d="M20 6 9 17l-5-5"></path>', "icon-status");
  }
  if (key.includes("value") || key.includes("attribute") || key.includes("setting")) {
    return tableSvg('<path d="M12 3v18"></path><path d="M5 7h14"></path><path d="M7 7v5a3 3 0 0 0 6 0V7"></path><path d="M17 7v5a3 3 0 0 1-6 0V7"></path>', "icon-setting");
  }
  if (key.includes("id") || key.includes("key")) {
    return tableSvg('<path d="M15 7a4 4 0 1 0-2.9 6.8L12 14h3v3h3v3h3v-4.2l-5.2-5.2"></path>', "icon-key");
  }
  if (key.includes("url") || key.includes("location") || key.includes("object") || key.includes("file")) {
    return tableSvg('<path d="M10 13a5 5 0 0 0 7.1 0l2-2a5 5 0 0 0-7.1-7.1l-1.2 1.2"></path><path d="M14 11a5 5 0 0 0-7.1 0l-2 2A5 5 0 0 0 12 20.1l1.2-1.2"></path>', "icon-link");
  }
  if (key.includes("count") || key.includes("size") || key.includes("cpu") || key.includes("duration")) {
    return tableSvg('<path d="M4 19V5"></path><path d="M4 19h16"></path><path d="M8 16v-5"></path><path d="M12 16V8"></path><path d="M16 16v-3"></path>', "icon-metric");
  }
  return tableSvg('<rect x="4" y="5" width="16" height="14" rx="2"></rect><path d="M4 10h16"></path><path d="M9 5v14"></path>', "icon-table");
}

function tableSvg(paths, tone) {
  return `<svg class="table-icon ${tone}" viewBox="0 0 24 24" aria-hidden="true">${paths}</svg>`;
}

async function saveInstructions(event) {
  if (event) {
    event.preventDefault();
  }
  saveInstructionsButton.disabled = true;
  instructionStatus.textContent = "Saving...";
  const instructionName = llmInstructionName.value.trim();

  if (!instructionName) {
    instructionStatus.textContent = "Name the instruction before saving.";
    llmInstructionName.focus();
    saveInstructionsButton.disabled = false;
    return;
  }

  try {
    const response = await fetch("/api/llm-instructions", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        name: instructionName,
        instructions: llmInstructions.value
      })
    });
    const payload = await response.json();
    if (!response.ok || !payload.ok) {
      throw new Error(payload.detail || payload.error || "Save failed");
    }

    llmInstructionProfiles = Array.isArray(payload.profiles) ? payload.profiles : [];
    selectedLlmInstructionName = payload.instructionName || instructionName;
    localStorage.setItem("dtc-llm-instruction-name", selectedLlmInstructionName);
    localStorage.setItem("dtc-llm-instructions", payload.instructions || "");
    renderInstructionProfileOptions(selectedLlmInstructionName);
    llmInstructions.value = payload.instructions || "";
    llmInstructionName.value = selectedLlmInstructionName;
    updateInstructionDisplay(llmInstructions.value, selectedLlmInstructionName);
    instructionStatus.textContent = "Saved";
    window.setTimeout(closeInstructionsDialog, 350);
  } catch (error) {
    instructionStatus.textContent = error.message;
  } finally {
    saveInstructionsButton.disabled = false;
  }
}

async function runPrompt(event) {
  event.preventDefault();
  const prompt = promptInput.value.trim();
  if (!prompt) {
    promptInput.focus();
    return;
  }

  const htmlStartedAt = performance.now();
  const requestId = createClientRequestId();
  setBusy(true);
  startRunStatusPolling(requestId);
  setResponseCollapsed(false);
  resultTitle.textContent = "Running";
  elapsed.textContent = "";
  htmlResponseTime.textContent = "";
  rawOutput.textContent = "";
  setRenderedHtml(loadingHtml());

  try {
    const response = await fetch("/api/ask", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        mode: mode.value,
        prompt,
        llmInstructionName: llmInstructionName.value.trim() || selectedLlmInstructionName,
        llmInstructions: llmInstructions.value,
        teamName: teamName.value,
        profileName: profileName.value,
        llmName: mode.value === "select-ai" ? runtimeLlmConfigSelect.value : "",
        requestId
      })
    });

    const payload = await response.json();
    if (!response.ok || !payload.ok) {
      throw new Error(payload.detail || payload.error || "AI query failed");
    }
    lastPromptPayload = payload;

    rawOutput.textContent = formatRawOutput(payload);

    const databaseResponse = payload.response || "";
    const renderedHtml = renderResponse(
      payload.llmResponse || payload.html || databaseResponse,
      payload.html || ""
    );
    const htmlWithSource = appendSourceResponseWhenUseful(renderedHtml, databaseResponse, payload.llm);
    setRenderedHtml(appendRagSearchWhenUseful(htmlWithSource, payload.ragSearch));
    htmlResponseTime.textContent = `Response time: ${formatSeconds(performance.now() - htmlStartedAt)}`;

    resultTitle.textContent = payload.llm && payload.llm.ok
      ? `${mode.value === "agent" ? "AI Agent" : "Select AI"} result rendered by Grok`
      : `${mode.value === "agent" ? "AI Agent" : "Select AI"} result`;
    elapsed.textContent = formatElapsedMs(payload.elapsedMs);
    setConsoleActionStatus(`Completed: ${resultTitle.textContent}`, "done", formatElapsedMs(payload.elapsedMs));
    uploadResponseMarkdownButton.disabled = !isCurrentUserAdmin();
  } catch (error) {
    lastPromptPayload = null;
    resultTitle.textContent = "Query failed";
    elapsed.textContent = "";
    htmlResponseTime.textContent = "";
    rawOutput.textContent = error.message;
    setRenderedHtml(textAsHtml(error.message, true));
    setView("raw");
    setConsoleActionStatus("Run failed", "error", error.message);
    uploadResponseMarkdownButton.disabled = true;
  } finally {
    stopRunStatusPolling();
    setBusy(false);
  }
}

function setBusy(isBusy) {
  runButton.disabled = isBusy;
  if (isBusy) {
    startRunProgress();
  } else {
    completeRunProgress();
  }
}

function createClientRequestId() {
  if (window.crypto && typeof window.crypto.randomUUID === "function") {
    return window.crypto.randomUUID();
  }
  return `ask-${Date.now().toString(36)}-${Math.random().toString(36).slice(2)}`;
}

function setConsoleActionStatus(message = "", variant = "running", title = "") {
  if (!consoleActionStatus) {
    return;
  }
  const text = String(message || "").trim();
  consoleActionStatus.textContent = text;
  consoleActionStatus.title = title || text;
  consoleActionStatus.hidden = !text;
  if (text) {
    consoleActionStatus.dataset.variant = variant;
  } else {
    delete consoleActionStatus.dataset.variant;
  }
}

function startRunStatusPolling(requestId) {
  stopRunStatusPolling();
  runStatusPollInFlight = false;
  activeRunStatusRequestId = requestId;
  setConsoleActionStatus("Preparing AI request", "running");
  const poll = async () => {
    if (activeRunStatusRequestId !== requestId) {
      return;
    }
    if (runStatusPollInFlight) {
      return;
    }
    runStatusPollInFlight = true;
    try {
      const response = await fetch(`/api/ask/status?requestId=${encodeURIComponent(requestId)}`);
      const payload = await response.json();
      if (activeRunStatusRequestId === requestId && response.ok && payload.ok && payload.status) {
        setConsoleActionStatus(
          payload.status,
          payload.error ? "error" : payload.completed ? "done" : "running",
          payload.stage || payload.status
        );
      }
    } catch {
      // The main /api/ask request remains the source of truth for failures.
    } finally {
      runStatusPollInFlight = false;
    }
  };

  runStatusTimer = window.setInterval(poll, 700);
  window.setTimeout(poll, 250);
}

function stopRunStatusPolling() {
  window.clearInterval(runStatusTimer);
  runStatusTimer = 0;
  runStatusPollInFlight = false;
  activeRunStatusRequestId = "";
}

function startRunProgress() {
  window.clearInterval(progressTimer);
  window.clearTimeout(progressHideTimer);
  runButton.hidden = true;
  runProgress.hidden = false;
  setRunProgress(0, 0);
  const startedAt = performance.now();

  progressTimer = window.setInterval(() => {
    const elapsedMs = performance.now() - startedAt;
    const percent = Math.min(100, elapsedMs / 1000);
    setRunProgress(percent, elapsedMs);
  }, 250);
}

function completeRunProgress() {
  window.clearInterval(progressTimer);
  setRunProgress(100);
  progressHideTimer = window.setTimeout(() => {
    runProgress.hidden = true;
    runButton.hidden = false;
    runButton.disabled = false;
    runButton.textContent = "Run";
  }, 450);
}

function setRunProgress(percent, elapsedMs) {
  const value = Math.max(0, Math.min(100, Number(percent) || 0));
  const rounded = Math.round(value);
  runProgressFill.style.width = `${value}%`;
  runProgressText.textContent = `${rounded}%`;
  if (Number.isFinite(elapsedMs) && runProgressElapsed) {
    runProgressElapsed.textContent = `${(elapsedMs / 1000).toFixed(1)} sec`;
  }
  runProgress.setAttribute("aria-valuenow", String(rounded));
}

function formatSeconds(ms) {
  const seconds = Number(ms || 0) / 1000;
  return `${seconds.toFixed(seconds >= 10 ? 1 : 2)} seconds`;
}

function formatElapsedMs(ms) {
  const value = Number(ms || 0);
  return value >= 1000 ? formatSeconds(value) : `${value} ms`;
}

function setAskCollapsed(isCollapsed) {
  askSection.classList.toggle("is-collapsed", isCollapsed);
  askToggle.setAttribute("aria-expanded", String(!isCollapsed));
  askToggle.title = isCollapsed ? "Expand ask section" : "Collapse ask section";
  localStorage.setItem("dtc-ask-collapsed", String(isCollapsed));
}

function setResponseCollapsed(isCollapsed) {
  responseSection.classList.toggle("is-collapsed", isCollapsed);
  responseToggle.setAttribute("aria-expanded", String(!isCollapsed));
  responseToggle.title = isCollapsed ? "Expand response" : "Collapse response";
  localStorage.setItem("dtc-response-collapsed", String(isCollapsed));
}

function openRenderedHtml() {
  if (!currentRenderedHtml) {
    return;
  }

  const blob = new Blob([currentRenderedHtml], { type: "text/html" });
  const url = URL.createObjectURL(blob);
  const opened = window.open(url, "_blank", "noopener,noreferrer");
  if (!opened) {
    rawOutput.textContent = "Allow pop-ups to open HTML";
  }
  setTimeout(() => URL.revokeObjectURL(url), 60000);
}

async function saveRenderedHtmlReport() {
  if (!currentRenderedHtml || currentRenderedHtml === injectResizeScript(emptyHtml)) {
    rawOutput.textContent = "Run a prompt before saving an HTML report.";
    return;
  }

  const defaultName = buildDefaultReportFilename();
  try {
    await refreshReportsCache();
    openHtmlSaveDialog(defaultName);
  } catch (error) {
    rawOutput.textContent = error.message;
  }
}

async function saveHtmlReportToFolder(saveTarget) {
  const trimmedFilename = saveTarget.filename.trim();
  if (!trimmedFilename) {
    htmlSaveStatus.textContent = "Enter a filename to save the report.";
    return;
  }
  const targetFolder = normalizeClientFolderPath(saveTarget.folder);

  saveHtmlButton.disabled = true;
  confirmSaveHtmlButton.disabled = true;
  rawOutput.textContent = `Saving HTML report to ${targetFolder ? `Reports/${targetFolder}` : "Reports"}...`;

  try {
    const response = await fetch("/api/reports/save-html", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        filename: trimmedFilename,
        folder: targetFolder,
        html: currentRenderedHtml
      })
    });
    const payload = await response.json();
    if (!response.ok || !payload.ok) {
      throw new Error(payload.error || payload.detail || "Could not save HTML report");
    }

    reportsLoaded = false;
    selectedReportsFolder = payload.path && payload.path.includes("/")
      ? payload.path.split("/").slice(0, -1).join("/")
      : targetFolder;
    localStorage.setItem("dtc-selected-reports-folder", selectedReportsFolder);
    rawOutput.textContent = `Saved HTML report: Reports/${payload.path}`;
    closeHtmlSaveDialog(null);
    if (reportsLoaded) {
      await loadReports();
    }
  } catch (error) {
    htmlSaveStatus.textContent = error.message;
    rawOutput.textContent = error.message;
  } finally {
    saveHtmlButton.disabled = false;
    confirmSaveHtmlButton.disabled = false;
  }
}

async function refreshReportsCache() {
  const response = await fetch("/api/reports");
  const payload = await response.json();
  if (!response.ok || !payload.ok) {
    throw new Error(payload.detail || payload.error || "Could not load report folders");
  }
  reportsFiles = payload.files || [];
  reportsFolders = payload.folders || [];
}

function openHtmlSaveDialog(defaultFilename) {
  renderHtmlSaveFolderOptions();
  htmlReportFilename.value = defaultFilename;
  htmlReportNewFolder.value = "";
  htmlReportFolderSelect.disabled = false;
  htmlSaveStatus.textContent = "";
  confirmSaveHtmlButton.disabled = false;
  htmlSaveModal.hidden = false;
  htmlReportFilename.focus();
  htmlReportFilename.select();
}

function renderHtmlSaveFolderOptions() {
  const folders = [
    { path: "", label: "Reports" },
    ...reportsFolders.map((folder) => ({
      path: folder.path,
      label: `Reports/${folder.path}`
    }))
  ];
  htmlReportFolderSelect.innerHTML = folders
    .map((folder) => `<option value="${escapeHtml(folder.path)}">${escapeHtml(folder.label)}</option>`)
    .join("");
  htmlReportFolderSelect.value = folders.some((folder) => folder.path === selectedReportsFolder)
    ? selectedReportsFolder
    : "";
}

function submitHtmlSaveDialog(event) {
  event.preventDefault();
  const filename = htmlReportFilename.value.trim();
  const newFolder = normalizeClientFolderPath(htmlReportNewFolder.value);
  const folder = newFolder || htmlReportFolderSelect.value;
  if (!filename) {
    htmlSaveStatus.textContent = "Enter a filename.";
    return;
  }
  htmlSaveStatus.textContent = "Saving...";
  saveHtmlReportToFolder({ filename, folder });
}

function closeHtmlSaveDialog() {
  htmlSaveModal.hidden = true;
  htmlReportFolderSelect.disabled = false;
}

function openResponseMarkdownDialog() {
  if (!lastPromptPayload) {
    rawOutput.textContent = "Run a prompt before uploading response markdown.";
    return;
  }
  markdownResponseFilename.value = buildDefaultMarkdownFilename();
  markdownResponseStatus.textContent = "";
  confirmUploadResponseMarkdownButton.disabled = false;
  markdownResponseModal.hidden = false;
  markdownResponseFilename.focus();
  markdownResponseFilename.select();
}

function closeResponseMarkdownDialog() {
  markdownResponseModal.hidden = true;
  markdownResponseStatus.textContent = "";
}

async function uploadResponseMarkdown(event) {
  event.preventDefault();
  if (!lastPromptPayload) {
    markdownResponseStatus.textContent = "Run a prompt before uploading response markdown.";
    return;
  }

  const filename = normalizeMarkdownFilename(markdownResponseFilename.value);
  if (!filename) {
    markdownResponseStatus.textContent = "Enter a markdown filename.";
    markdownResponseFilename.focus();
    return;
  }

  const markdown = buildPromptResponseMarkdown(lastPromptPayload);
  const file = new File([markdown], filename, { type: "text/markdown" });
  const formData = new FormData();
  formData.append("file", file);

  uploadResponseMarkdownButton.disabled = true;
  confirmUploadResponseMarkdownButton.disabled = true;
  markdownResponseStatus.textContent = "Uploading response markdown, then rebuilding the RAG vector index...";
  setConsoleActionStatus("Uploading response markdown and rebuilding RAG index", "running");

  try {
    const response = await fetch("/api/markdown-upload", {
      method: "POST",
      body: formData
    });
    const payload = await response.json();
    if (!response.ok || !payload.ok) {
      throw new Error(payload.detail || payload.error || "Could not upload response markdown");
    }

    const summary = formatMarkdownUploadSummary(payload);
    markdownResponseStatus.textContent = summary;
    rawOutput.textContent = summary;
    setConsoleActionStatus(formatRagIndexStatus(payload), "done", summary);
    ragLoaded = false;
    loadRag().catch(() => undefined);
    window.setTimeout(closeResponseMarkdownDialog, 900);
  } catch (error) {
    markdownResponseStatus.textContent = error.message;
    setConsoleActionStatus("RAG upload failed", "error", error.message);
  } finally {
    uploadResponseMarkdownButton.disabled = !lastPromptPayload || !isCurrentUserAdmin();
    confirmUploadResponseMarkdownButton.disabled = false;
  }
}

function buildPromptResponseMarkdown(payload) {
  const timestamp = new Date().toISOString();
  const parts = [
    "# Chat Prompt Response",
    "",
    `- Generated: ${timestamp}`,
    `- Runtime: ${payload.mode === "select-ai" ? "Select AI Profile" : "AI Agent Team"}`,
    payload.teamName ? `- Agent team: ${payload.teamName}` : null,
    payload.profileName ? `- Select AI profile: ${payload.profileName}` : null,
    payload.llm && payload.llm.modelId ? `- Grok model: ${payload.llm.modelId}` : null,
    payload.llm && payload.llm.instructionName ? `- LLM instruction: ${payload.llm.instructionName}` : null,
    "",
    "## Prompt",
    "",
    payload.prompt || promptInput.value.trim(),
    "",
    "## Response",
    "",
    markdownResponseText(payload),
    "",
    "## Source Database AI Response",
    "",
    payload.response || ""
  ].filter((part) => part !== null && part !== undefined);
  return `${parts.join("\n").trim()}\n`;
}

function markdownResponseText(payload) {
  const renderedText = htmlToPlainText(payload.html || payload.llmResponse || "");
  return renderedText || payload.llmResponse || payload.response || "";
}

function htmlToPlainText(html) {
  const text = String(html || "").trim();
  if (!text) {
    return "";
  }
  if (!/<[a-z][\s\S]*>/i.test(text)) {
    return text;
  }
  const doc = new DOMParser().parseFromString(text, "text/html");
  doc.querySelectorAll("script, style").forEach((node) => node.remove());
  return (doc.body && doc.body.innerText || doc.documentElement.textContent || "")
    .replace(/\n{3,}/g, "\n\n")
    .trim();
}

function buildDefaultMarkdownFilename() {
  const prompt = lastPromptPayload && lastPromptPayload.prompt || promptInput.value || "chat prompt response";
  const timestamp = new Date().toISOString().slice(0, 19).replace(/[T:]/g, "-");
  const baseName = prompt
    .replace(/[^A-Za-z0-9._ -]+/g, "")
    .trim()
    .replace(/\s+/g, "_")
    .slice(0, 72) || "chat_prompt_response";
  return `${baseName}_${timestamp}.md`;
}

function normalizeMarkdownFilename(value) {
  let filename = String(value || "")
    .trim()
    .replace(/[/\\]+/g, "_")
    .replace(/[^A-Za-z0-9._ -]+/g, "_")
    .replace(/\s+/g, "_")
    .replace(/^_+|_+$/g, "");
  if (!filename) {
    return "";
  }
  if (!/\.(md|markdown)$/i.test(filename)) {
    filename = `${filename}.md`;
  }
  return filename.slice(0, 180);
}

function formatMarkdownUploadSummary(payload) {
  const vectorization = payload.vectorization || {};
  const chunkSummary = Number.isFinite(Number(vectorization.chunkCountAfter))
    ? ` Vector table ${vectorization.vectorTable} now has ${vectorization.chunkCountAfter} chunks.`
    : "";
  const elapsedSummary = Number.isFinite(Number(vectorization.elapsedMs))
    ? ` Completed in ${formatElapsedMs(Number(vectorization.elapsedMs))}.`
    : "";
  return `${payload.message} Object: ${payload.objectName}.${chunkSummary}${elapsedSummary}`;
}

function formatRagIndexStatus(payload) {
  const vectorization = payload && payload.vectorization || {};
  const filename = vectorization.filename || payload && payload.objectName || "document";
  const chunkCount = Number(vectorization.chunkCountAfter);
  const chunkSummary = Number.isFinite(chunkCount)
    ? `, ${chunkCount} chunks indexed`
    : "";
  return `RAG index completed: ${filename}${chunkSummary}`;
}

function buildDefaultReportFilename() {
  const title = resultTitle.textContent && resultTitle.textContent !== "Ready"
    ? resultTitle.textContent
    : "AI Agent Report";
  const timestamp = new Date().toISOString().slice(0, 19).replace(/[T:]/g, "-");
  const baseName = title
    .replace(/[^A-Za-z0-9._ -]+/g, "")
    .trim()
    .replace(/\s+/g, "_")
    .slice(0, 80) || "AI_Agent_Report";
  return `${baseName}_${timestamp}.html`;
}

function exportRenderedPdf() {
  if (!currentRenderedHtml) {
    rawOutput.textContent = "Run a prompt before exporting a PDF.";
    return;
  }

  const printHtml = preparePrintableHtml(currentRenderedHtml);
  const blob = new Blob([printHtml], { type: "text/html" });
  const url = URL.createObjectURL(blob);
  const opened = window.open(url, "_blank", "noopener,noreferrer");
  if (!opened) {
    rawOutput.textContent = "Allow pop-ups to export PDF.";
    setTimeout(() => URL.revokeObjectURL(url), 1000);
    return;
  }

  setTimeout(() => {
    try {
      opened.focus();
      opened.print();
    } catch {
      rawOutput.textContent = "Use the browser print command in the opened report window to save as PDF.";
    }
    setTimeout(() => URL.revokeObjectURL(url), 60000);
  }, 700);
}

function preparePrintableHtml(html) {
  const printStyle = `
    <style>
      @media print {
        @page { margin: 0.5in; }
        html, body { background: #fff !important; }
        * { box-shadow: none !important; }
      }
    </style>
    <script>
      window.addEventListener("load", () => {
        document.title = document.title || "AI Agent Report";
      });
    </script>`;

  if (/<\/head>/i.test(html)) {
    return html.replace(/<\/head>/i, `${printStyle}</head>`);
  }
  return `<!doctype html><html><head><title>AI Agent Report</title>${printStyle}</head><body>${html}</body></html>`;
}

function formatRawOutput(payload) {
  const parts = [
    "DATABASE AI RESPONSE",
    payload.response || ""
  ];

  if (payload.llm) {
    parts.push(
      "",
      "OCI GROK RENDERING",
      `Model: ${payload.llm.modelId || ""}`,
      `Endpoint: ${payload.llm.endpoint || ""}`,
      `Instruction: ${payload.llm.instructionName || "none"}`,
      `Custom instructions: ${payload.llm.customInstructions ? "included" : "none"}`,
      `Status: ${payload.llm.ok ? "ok" : payload.llm.skipped || payload.llm.error || "not used"}`
    );

    if (payload.llmResponse) {
      parts.push("", payload.llmResponse);
    }
  }

  return parts.join("\n");
}

function setView(view) {
  tabs.forEach((button) => {
    button.classList.toggle("active", button.dataset.view === view);
  });
  outputSurface.classList.toggle("show-raw", view === "raw");
}

function setRenderedHtml(html) {
  if (renderedBlobUrl) {
    URL.revokeObjectURL(renderedBlobUrl);
    renderedBlobUrl = "";
  }

  currentRenderedHtml = injectResizeScript(html);
  const blob = new Blob([currentRenderedHtml], { type: "text/html" });
  renderedBlobUrl = URL.createObjectURL(blob);
  renderedOutput.style.height = "640px";
  renderedOutput.src = renderedBlobUrl;
}

window.addEventListener("message", (event) => {
  if (!event.data || event.data.type !== "dtc-render-height") {
    return;
  }
  renderedOutput.style.height = `${Math.max(640, Number(event.data.height) + 24)}px`;
});

renderedOutput.addEventListener("load", () => {
  try {
    const doc = renderedOutput.contentDocument;
    const body = doc && doc.body;
    const html = doc && doc.documentElement;
    if (!body || !html) {
      return;
    }

    const contentHeight = Math.max(
      body.scrollHeight,
      body.offsetHeight,
      html.clientHeight,
      html.scrollHeight,
      html.offsetHeight
    );
    renderedOutput.style.height = `${Math.max(640, contentHeight + 24)}px`;
  } catch {
    renderedOutput.style.height = "640px";
  }
});

function injectResizeScript(html) {
  const script = `<script>
    (() => {
      const sendHeight = () => {
        const body = document.body;
        const root = document.documentElement;
        const height = Math.max(
          body ? body.scrollHeight : 0,
          body ? body.offsetHeight : 0,
          root ? root.scrollHeight : 0,
          root ? root.offsetHeight : 0
        );
        parent.postMessage({ type: "dtc-render-height", height }, "*");
      };
      addEventListener("load", sendHeight);
      addEventListener("resize", sendHeight);
      setTimeout(sendHeight, 0);
      setTimeout(sendHeight, 300);
      setTimeout(sendHeight, 1000);
    })();
  </script>`;

  if (/<\/body>/i.test(html)) {
    return html.replace(/<\/body>/i, `${script}</body>`);
  }

  return `${html}${script}`;
}

function renderResponse(response, extractedHtml) {
  const text = String(response || "");
  if (!text.trim()) {
    return textAsHtml("No response returned.");
  }

  if (isFullHtmlDocument(text)) {
    return text;
  }

  const fencedBlocks = splitHtmlFences(text);
  if (fencedBlocks.length > 1 || fencedBlocks.some((block) => block.type === "html")) {
    return composeMixedResponse(fencedBlocks);
  }

  if (isFullHtmlDocument(extractedHtml)) {
    return extractedHtml;
  }

  if (extractedHtml || containsHtml(text)) {
    return wrapHtml(extractedHtml || text);
  }

  return textAsHtml(text);
}

function appendSourceResponseWhenUseful(html, databaseResponse, llm) {
  const source = String(databaseResponse || "").trim();
  if (!source || !llm || !llm.ok) {
    return html;
  }

  const visibleText = stripHtmlToText(html);
  const hasReportDataSection = /\b(report data|database result data|returned data|source data)\b/i.test(visibleText);
  const hasMostSource = source.length < 2000
    ? visibleText.includes(source.slice(0, Math.min(source.length, 500)))
    : visibleText.includes(source.slice(0, 500)) && visibleText.includes(source.slice(-500));

  if (hasMostSource) {
    return html;
  }

  const sectionTitle = hasReportDataSection ? "Additional Database Report Data" : "Report Data";
  const sourceSection = `
    <section class="database-report-data" style="margin-top:24px; padding-top:18px; border-top:1px solid #d6dee8;">
      <h2 style="margin:0 0 10px; color:#172033; font-size:20px;">${sectionTitle}</h2>
      <p style="margin:0 0 10px; color:#526174; font-size:13px;">Database-returned values preserved for audit and review.</p>
      <pre style="white-space:pre-wrap; word-break:break-word; overflow:auto; max-height:none; margin:12px 0 0; padding:14px; border:1px solid #d6dee8; border-radius:8px; background:#f8fafc; color:#182333; font:12px/1.5 ui-monospace, SFMono-Regular, Menlo, Consolas, monospace;">${escapeHtml(source)}</pre>
    </section>`;

  if (/<\/body>/i.test(html)) {
    return html.replace(/<\/body>/i, `${sourceSection}</body>`);
  }

  return wrapHtml(`${html}${sourceSection}`);
}

function appendRagSearchWhenUseful(html, ragSearch) {
  if (!ragSearch) {
    return html;
  }

  const response = ragSearch.ok
    ? String(ragSearch.response || "No RAG search response was returned.").trim()
    : `RAG search error: ${ragSearch.error || "Unknown error"}`;
  if (!response) {
    return html;
  }

  const visibleText = stripHtmlToText(html);
  const responseStart = response.slice(0, Math.min(response.length, 300));
  if (responseStart && visibleText.includes(responseStart)) {
    return html;
  }

  const section = `
    <section class="fsi-rag-search-results" style="margin-top:24px; padding-top:18px; border-top:1px solid #d6dee8;">
      <h2 style="margin:0 0 10px; color:#172033; font-size:20px;">FSI RAG Search Results and Document Citations</h2>
      <p style="margin:0 0 10px; color:#61708a; font-size:13px;">RAG profile: ${escapeHtml(ragSearch.profileName || "fsi_select_ai_rag_kb_profile")}</p>
      <pre style="white-space:pre-wrap; word-break:break-word; overflow:auto; margin:0; padding:14px; border:1px solid #d6dee8; border-radius:8px; background:#f8fafc; color:#182333; font:13px/1.55 ui-monospace, SFMono-Regular, Menlo, Consolas, monospace;">${escapeHtml(response)}</pre>
    </section>`;

  if (/<\/body>/i.test(html)) {
    return html.replace(/<\/body>/i, `${section}</body>`);
  }

  return wrapHtml(`${html}${section}`);
}

function stripHtmlToText(html) {
  return String(html || "")
    .replace(/<script[\s\S]*?<\/script>/gi, "")
    .replace(/<style[\s\S]*?<\/style>/gi, "")
    .replace(/<[^>]+>/g, " ")
    .replace(/\s+/g, " ")
    .trim();
}

function splitHtmlFences(text) {
  const blocks = [];
  const pattern = /```html\s*([\s\S]*?)```/gi;
  let lastIndex = 0;
  let match;

  while ((match = pattern.exec(text)) !== null) {
    if (match.index > lastIndex) {
      blocks.push({ type: "text", value: text.slice(lastIndex, match.index) });
    }
    blocks.push({ type: "html", value: match[1].trim() });
    lastIndex = pattern.lastIndex;
  }

  if (lastIndex < text.length) {
    blocks.push({ type: "text", value: text.slice(lastIndex) });
  }

  return blocks.length ? blocks : [{ type: "text", value: text }];
}

function composeMixedResponse(blocks) {
  const meaningfulBlocks = blocks.filter((block) => block.value.trim());
  if (meaningfulBlocks.length === 1 && meaningfulBlocks[0].type === "html") {
    return meaningfulBlocks[0].value;
  }

  const body = blocks
    .map((block) => {
      if (block.type === "html") {
        return `<section class="rendered-block">${block.value}</section>`;
      }

      const text = block.value.trim();
      if (!text) {
        return "";
      }

      return `<section class="answer-text">${formatPlainText(text)}</section>`;
    })
    .join("");

  return wrapHtml(body || "No response returned.");
}

function wrapHtml(html) {
  const hasDocument = /<html[\s>]/i.test(html) || /<!doctype\s+html/i.test(html);
  if (hasDocument) {
    return html;
  }
  return `<!doctype html>
<html>
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>
      body {
        margin: 0;
        padding: 20px;
        color: #182333;
        font: 14px/1.5 "Oracle Sans", "OracleSans", "Redwood", system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
        background: #fff;
      }
      .answer-text {
        margin: 0 0 16px;
        white-space: pre-wrap;
        word-break: break-word;
      }
      .rendered-block {
        margin: 0 0 18px;
        overflow-x: auto;
      }
      table {
        width: 100%;
        border-collapse: collapse;
      }
      th, td {
        padding: 9px 10px;
        border: 1px solid #d6dee8;
        text-align: left;
        vertical-align: top;
      }
      th {
        background: #eef3f8;
      }
    </style>
  </head>
  <body>${html}</body>
</html>`;
}

function textAsHtml(text, isError = false) {
  return `<!doctype html>
<html>
  <head>
    <meta charset="utf-8">
    <style>
      body {
        margin: 0;
        padding: 24px;
        color: ${isError ? "#991b1b" : "#182333"};
        white-space: pre-wrap;
        word-break: break-word;
        font: 14px/1.55 "Oracle Sans", "OracleSans", "Redwood", system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
        background: #fff;
      }
    </style>
  </head>
  <body>${escapeHtml(text)}</body>
</html>`;
}

function loadingHtml() {
  return textAsHtml("Running database AI request...");
}

function escapeHtml(value) {
  return String(value)
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#039;");
}

function formatPlainText(text) {
  return escapeHtml(text)
    .replace(/^### (.*)$/gm, "<h3>$1</h3>")
    .replace(/^## (.*)$/gm, "<h2>$1</h2>")
    .replace(/^# (.*)$/gm, "<h1>$1</h1>")
    .replace(/\*\*(.*?)\*\*/g, "<strong>$1</strong>");
}

function containsHtml(text) {
  return /<(?:!doctype\s+html|html|body|table|thead|tbody|tr|td|th|div|section|article|canvas|svg|style|script|ul|ol|li|p|h[1-6])\b/i.test(text);
}

function isFullHtmlDocument(text) {
  return /<html[\s>]/i.test(text) || /<!doctype\s+html/i.test(text);
}
