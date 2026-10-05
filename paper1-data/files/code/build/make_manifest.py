"""Write docs/file_manifest.csv and SHA256SUMS.txt for the package (run after any change).

    python3 code/build/make_manifest.py            # check with:  sha256sum -c SHA256SUMS.txt
"""
import csv
import hashlib
import os

PKG = os.path.abspath(os.environ.get('PKG_DIR', os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..')))
SKIP_DIRS = {'__pycache__', '.git'}
SKIP_FILES = {'SHA256SUMS.txt', 'file_manifest.csv', '.DS_Store', 'Thumbs.db'}
KIND = {'.tif': 'raster (Cloud Optimized GeoTIFF)', '.gpkg': 'vector (GeoPackage)', '.csv': 'table (CSV, UTF-8)',
        '.py': 'code (Python)', '.R': 'code (R)', '.r': 'code (R)', '.md': 'documentation (Markdown)',
        '.cff': 'citation metadata', '.json': 'repository metadata'}

rows = []
for root, dirs, files in os.walk(PKG):
    dirs[:] = sorted(d for d in dirs if d not in SKIP_DIRS)
    for f in sorted(files):
        if f in SKIP_FILES or f.endswith('.pyc'):
            continue
        p = os.path.join(root, f)
        h = hashlib.sha256()
        with open(p, 'rb') as fh:
            for chunk in iter(lambda: fh.read(1 << 20), b''):
                h.update(chunk)
        rel = os.path.relpath(p, PKG).replace(os.sep, '/')
        rows.append({'path': rel, 'bytes': os.path.getsize(p), 'sha256': h.hexdigest(),
                     'kind': KIND.get(os.path.splitext(f)[1], 'other')})
with open(os.path.join(PKG, 'docs', 'file_manifest.csv'), 'w', newline='', encoding='utf-8') as o:
    w = csv.DictWriter(o, fieldnames=['path', 'bytes', 'sha256', 'kind'])
    w.writeheader()
    w.writerows(rows)
with open(os.path.join(PKG, 'SHA256SUMS.txt'), 'w', encoding='utf-8') as o:
    for r in rows:
        o.write(f"{r['sha256']}  {r['path']}\n")
print(len(rows), 'files,', round(sum(r['bytes'] for r in rows) / 2**20, 1), 'MiB')
