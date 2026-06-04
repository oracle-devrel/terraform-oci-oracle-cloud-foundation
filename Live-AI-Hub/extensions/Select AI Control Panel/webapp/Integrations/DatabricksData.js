const { DBSQLClient } = require('@databricks/sql');
const fs = require("node:fs");
const path = require("node:path");

loadDotEnv(path.join(__dirname, "..", ".env"));

const token = requiredEnv("DATABRICKS_TOKEN");
const serverHostname = requiredEnv("DATABRICKS_SERVER_HOSTNAME");
const httpPath = requiredEnv("DATABRICKS_HTTP_PATH");
const query = requiredEnv("DATABRICKS_SQL");

const outputColumns = ["repairer_name", "fraud_score"];

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

function requiredEnv(name) {
  const value = process.env[name] && process.env[name].trim();
  if (!value) {
    throw new Error(`${name} must be set in webapp/.env`);
  }
  return value;
}

function printTable(rows, columns) {
  if (rows.length === 0) {
    console.log("No repairer fraud scores found.");
    return;
  }

  const widths = columns.map((column) => {
    const values = rows.map((row) => String(row[column] ?? ""));
    return Math.max(column.length, ...values.map((value) => value.length));
  });

  const separator = `+${widths.map((width) => "-".repeat(width + 2)).join("+")}+`;
  const formatRow = (values) =>
    `| ${values
      .map((value, index) => String(value ?? "").padEnd(widths[index], " "))
      .join(" | ")} |`;

  console.log(separator);
  console.log(formatRow(columns));
  console.log(separator);

  for (const row of rows) {
    console.log(formatRow(columns.map((column) => row[column])));
  }

  console.log(separator);
}

async function main() {
  const client = new DBSQLClient();
  const connectedClient = await client.connect({
    token: token,
    host: serverHostname,
    path: httpPath
  });

  const session = await connectedClient.openSession();

  try {
    const queryOperation = await session.executeStatement(query, { runAsync: true });

    try {
      const rows = await queryOperation.fetchAll();
      console.log(`Repairer fraud scores (${rows.length} repairers)`);
      printTable(rows, outputColumns);
    } finally {
      await queryOperation.close();
    }
  } finally {
    await session.close();
    await connectedClient.close();
  }
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
