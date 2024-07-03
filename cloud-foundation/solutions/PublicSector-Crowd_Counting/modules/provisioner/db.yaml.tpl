db:
  - name: ${db_name}
    enabled: true              # true: inserted into DB, false: no access to DB
    dsn: ${db_name}_high       # TNS name for DB
    user: DEMO                 # User name for demo schema
    password: ${db_password}   # User password 
    adminpw: ${db_password}    # ADB ADMIN passwrod
    https_proxy:               # Proxy setting if needed
    https_port:                # Proxy setting if needed
    llmpw: ${llmpw}            # Token of the LLM provided by openai

