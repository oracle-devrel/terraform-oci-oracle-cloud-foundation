#!/usr/bin/env python3
"""Download and render the current FSI APEX export for the selected schema."""
from __future__ import annotations
import os,re,sys,urllib.parse,urllib.request
from pathlib import Path
IDENTIFIER_RE=re.compile(r"^[A-Za-z][A-Za-z0-9_$#]{0,127}$")
HOST="objectstorage.us-ashburn-1.oraclecloud.com"
ENV="FSI_APEX_EXPORT_PAR_URL"
SUFFIX="/FSI_files/f108.sql"
MAX_BYTES=40*1024*1024

def download():
    url=os.environ.get(ENV,""); p=urllib.parse.urlsplit(url)
    if p.scheme!="https" or p.hostname!=HOST or "/p/" not in p.path or "/o/" not in p.path or not p.path.endswith(SUFFIX):
        raise ValueError()
    req=urllib.request.Request(url,headers={"User-Agent":"FSI-Terraform-Provisioner/1.0"})
    with urllib.request.urlopen(req,timeout=300) as resp:
        final=urllib.parse.urlsplit(resp.geturl())
        if final.scheme!="https" or final.hostname!=HOST: raise ValueError()
        data=resp.read(MAX_BYTES+1)
    if len(data)>MAX_BYTES: raise ValueError()
    return data.decode("utf-8")

def main():
    if len(sys.argv)!=3:
        print("Usage: render_apex_export.py OUTPUT.sql SCHEMA",file=sys.stderr); return 2
    output,schema=Path(sys.argv[1]),sys.argv[2]
    if not IDENTIFIER_RE.fullmatch(schema):
        print("Invalid Oracle schema identifier.",file=sys.stderr); return 1
    try: text=download()
    except Exception as exc:
        print("Unable to download the configured APEX export (" + type(exc).__name__ + "). Check PAR configuration and network access.",file=sys.stderr); return 1
    schema=schema.upper()
    text,n1=re.subn(r"(?i)\bMADHU_RAO\s*\.",schema+".",text)
    text,n2=re.subn(r"(?i)(p_default_owner\s*=>\s*)'MADHU_RAO'",lambda m:m.group(1)+"'"+schema+"'",text)
    text,n3=re.subn(r"(?i)(p_owner\s*=>\s*nvl\(\s*wwv_flow_application_install\.get_schema\s*,\s*)'MADHU_RAO'(\s*\))",lambda m:m.group(1)+"'"+schema+"'"+m.group(2),text)
    if (n1,n2,n3)!=(7,1,1):
        print("APEX export owner-reference count differs from the audited source.",file=sys.stderr); return 1
    if re.search(r"(?i)\bMADHU_RAO\s*\.",text):
        print("Unmapped original schema qualifier remains in the APEX export.",file=sys.stderr); return 1
    output.parent.mkdir(parents=True,exist_ok=True)
    fd=os.open(output,os.O_WRONLY|os.O_CREAT|os.O_TRUNC,0o600)
    with os.fdopen(fd,"w",encoding="utf-8",newline="\n") as out: out.write(text)
    os.chmod(output,0o600)
    print(f"[FSI] Rendered APEX import SQL file: {output} ({len(text.encode('utf-8'))} bytes)")
    return 0
if __name__=="__main__": raise SystemExit(main())
