#!/usr/bin/env python3
"""Download and render the optional FSI vector snapshot."""
from __future__ import annotations
import os,re,sys,urllib.parse,urllib.request
from pathlib import Path
IDENTIFIER_RE=re.compile(r"^[A-Za-z][A-Za-z0-9_$#]{0,127}$")
PLACEHOLDER="__FSI_VECTOR_TABLE__"
HOST="objectstorage.us-ashburn-1.oraclecloud.com"
ENV="FSI_VECTOR_SNAPSHOT_PAR_URL"
SUFFIX="/FSI_files/03_fsi_vector_index_snapshot.sql"
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
        print("Usage: render_vector_snapshot_sql.py OUTPUT.sql VECTOR_INDEX_NAME",file=sys.stderr); return 2
    output,index_name=Path(sys.argv[1]),sys.argv[2]
    table_name=f"{index_name}$VECTAB"
    if not IDENTIFIER_RE.fullmatch(index_name) or len(table_name)>128:
        print("Invalid Oracle vector index identifier.",file=sys.stderr); return 1
    try: content=download()
    except Exception as exc:
        print("Unable to download the configured vector snapshot (" + type(exc).__name__ + "). Check PAR configuration and network access.",file=sys.stderr); return 1
    if content.count(PLACEHOLDER)!=512:
        print("Vector snapshot placeholder count does not match the audited DMP export.",file=sys.stderr); return 1
    content=content.replace(PLACEHOLDER,table_name)
    output.parent.mkdir(parents=True,exist_ok=True)
    fd=os.open(output,os.O_WRONLY|os.O_CREAT|os.O_TRUNC,0o600)
    with os.fdopen(fd,"w",encoding="utf-8",newline="\n") as out: out.write(content)
    os.chmod(output,0o600)
    print(f"[FSI] Rendered vector snapshot SQL file: {output} ({len(content.encode('utf-8'))} bytes)")
    return 0
if __name__=="__main__": raise SystemExit(main())
