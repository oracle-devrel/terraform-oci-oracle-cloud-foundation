# FSI deployment source files

The Terraform provisioner and OCI Resource Manager package use the same flat module layout. Active SQL, APEX, Python, and shell inputs are directly in `modules/provisioner/`; the three approved RAG documents are stored in `documentation/`.

## Active inputs

- `f108.sql` — current APEX application 108 export; Terraform renders it for the selected parsing schema before import.
- `01Seqs.sql`, `02TablesViews.sql`, `03FunctionsProcs.sql` — schema creation scripts, run in dependency order.
- `01_fsi_application_data.sql` — optional relational sample data for a new target schema.
- `03_fsi_vector_index_snapshot.sql` — optional vector-index snapshot data.
- `load_business_data.sh` and `sync_application_sequences.sql` — guarded data loading and sequence alignment.
- `render_apex_export.py`, `render_fsi_runtime_config.py`, `render_vector_snapshot_sql.py` — Terraform renderers.
- `verify.sql` — post-deployment object and configuration checks.
- `documentation/CrossShield_Insurance_HLD-v0.01.md`, `documentation/CrossShield_Insurance_LLD-v0.01.md`, and `documentation/CrossShield_Insurance_HLD_LLD_Comparison_Report-v0.01.md` — approved RAG content uploaded by Terraform.

Terraform uses these SQL sources directly; it does not import a `.DMP` file or a ZIP export. Archive folders at the solution root are outside the active module and are not deployment inputs.

## Deployment behavior

The module creates the schema, optionally loads sample data, applies runtime and RAG configuration, imports the APEX application, and executes `verify.sql`. Use Terraform variables to select the schema, application/workspace settings, sample-data loading, and vector snapshot behavior. Do not manually run create-only DDL over an existing populated schema.
