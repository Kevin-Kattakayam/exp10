#!/usr/bin/env python3
"""Generate Flutter platform scaffolding without replacing the lab sources."""
import argparse, pathlib, re, shutil, subprocess, tempfile
p=argparse.ArgumentParser()
p.add_argument('--platforms',default='android,web')
a=p.parse_args()
root=pathlib.Path(__file__).resolve().parent
name=re.search(r'^name:\s*(\w+)',(root/'pubspec.yaml').read_text(),re.M)[1]
with tempfile.TemporaryDirectory(prefix='flutter_lab_') as tmp:
    target=pathlib.Path(tmp)/'scaffold'
    subprocess.run(['flutter','create','--no-pub','--project-name',name,'--platforms',a.platforms,str(target)],check=True)
    for platform in a.platforms.split(','):
        src=target/platform
        if src.exists(): shutil.copytree(src,root/platform,dirs_exist_ok=True)
    if (target/'.metadata').exists(): shutil.copy2(target/'.metadata',root/'.metadata')
subprocess.run(['flutter','pub','get'],cwd=root,check=True)
print('Platform scaffolding prepared. Run flutter analyze, then flutter run -d <device>.')
