"""Areas of GI, MSPA classes and GI elements by region, and the core-patch metrics of Table 4,
recomputed from the released rasters.

Outputs (results/):
  mspa_class_area_by_region.csv     area of every MSPA class in each region and in the whole raster
  gi_element_by_class.csv           GI element (MSPA group) x GI class, whole raster and by region (Figs 5-6)
  gi_share_by_region.csv            GI area against the 3 km zone and against the county area attribute
  core_metrics_by_region.csv        core patches (8-neighbour): number, area, largest, mean, density, LPI, LSI
  gi_binary_vs_mspa.csv             agreement between the MSPA input raster and the MSPA output in the zone
"""
import numpy as np
import pandas as pd
import pyogrio
import rasterio
from rasterio.features import rasterize
from rasterio.windows import from_bounds, Window
from scipy import ndimage
from common import MSPA, GI_BIN, GI_CLASS, PIXEL_HA, ELEMENT, FOREGROUND, GI_CLASSES, ZONE, regions, save

NAMES = ['background', 'cores', 'corridors', 'branches', 'islets', 'other foreground']
LUT = np.zeros(256, np.uint8)
for c, e in ELEMENT.items():
    LUT[c] = NAMES.index(e) if e in NAMES else 0
CLS = {0: 'not in GI polygons', **GI_CLASSES}


def read(path, win):
    with rasterio.open(path) as s:
        return s.read(1, window=win, boundless=True, fill_value=0)


def window_for(geom, transform, shape):
    w = from_bounds(*geom.bounds, transform).round_offsets().round_lengths()
    w = Window(w.col_off - 1, w.row_off - 1, w.width + 2, w.height + 2)
    return w.intersection(Window(0, 0, shape[1], shape[0]))


with rasterio.open(MSPA) as s:
    T, shape = s.transform, (s.height, s.width)
regs = regions()
zone = pyogrio.read_dataframe(ZONE, layer='coastal_zone_3km').geometry.iloc[0]
inter = regs.set_index('region').geometry
print('  Harju and Tallinn area polygons overlap by',
      round(inter['Harju'].intersection(inter['Tallinn area']).area / 1e4, 1), 'ha')

mspa_rows, el_rows, share_rows, core_rows, bin_rows = [], [], [], [], []
units = [('Whole coastal zone', zone, None)] + [(r['region'], r.geometry, r) for _, r in regs.iterrows()]
for name, geom, r in units:
    win = window_for(geom, T, shape)
    tr = rasterio.windows.transform(win, T)
    m = rasterize([(geom, 1)], out_shape=(win.height, win.width), transform=tr, fill=0, dtype='uint8').astype(bool)
    mspa = read(MSPA, win)
    gcls = read(GI_CLASS, win)
    el = LUT[mspa]
    fg = np.isin(mspa, FOREGROUND)
    codes, cnt = np.unique(mspa[m], return_counts=True)
    for c, n in zip(codes, cnt):
        mspa_rows.append({'region': name, 'mspa_code': int(c), 'element': ELEMENT.get(int(c), 'unknown'),
                          'area_ha': round(n * PIXEL_HA, 2)})
    pair = el[m].astype(np.int32) * 10 + gcls[m]
    pc, pn = np.unique(pair, return_counts=True)
    for v, n in zip(pc, pn):
        el_rows.append({'region': name, 'element': NAMES[v // 10], 'gi_class': CLS[v % 10],
                        'area_ha': round(n * PIXEL_HA, 2)})
    if r is None:                                   # whole zone: MSPA input against MSPA output
        with rasterio.open(GI_BIN) as s:
            gbin = s.read(1, window=Window(win.col_off, win.row_off, win.width, win.height), boundless=True,
                          fill_value=0)
        for gv in (0, 1):
            for fv in (False, True):
                bin_rows.append({'gi_binary': gv, 'mspa_foreground': fv,
                                 'area_ha': round(((gbin == gv) & (fg == fv) & m).sum() * PIXEL_HA, 1)})
        continue
    share_rows.append({'region': name, 'zone_area_ha': round(r['zone_area_ha'], 1),
                       'county_area_attr_ha': round(r['county_area_attr_ha'], 1),
                       'gi_polygons_ha': round(((gcls > 0) & m).sum() * PIXEL_HA, 1),
                       'mspa_foreground_ha': round((fg & m).sum() * PIXEL_HA, 1),
                       'cores_corridors_branches_ha': round((np.isin(el, [1, 2, 3]) & m).sum() * PIXEL_HA, 1)})
    # core patches, landscapemetrics conventions: 8-neighbour rule, the landscape is the core cells only
    c = (el == 1) & m
    lab, n = ndimage.label(c, structure=np.ones((3, 3), int))
    sizes = np.bincount(lab.ravel())[1:]
    A = int(c.sum())
    p = np.pad(c, 1)
    E = int(sum((p & ~np.roll(p, s_, axis=ax)).sum() for s_, ax in [(1, 0), (-1, 0), (1, 1), (-1, 1)]))
    k = int(np.floor(np.sqrt(A)))
    emin = 4 * k if A == k * k else (4 * k + 2 if A <= k * (k + 1) else 4 * k + 4)
    core_rows.append({'region': name, 'core_patches': int(n), 'core_area_ha': round(A * PIXEL_HA, 2),
                      'largest_patch_ha': round(sizes.max() * PIXEL_HA, 2),
                      'mean_patch_ha': round(A / n * PIXEL_HA, 2),
                      'patch_density_per_100ha': round(n / (A * PIXEL_HA) * 100, 3),
                      'largest_patch_index_pct': round(100 * sizes.max() / A, 2), 'lsi': round(E / emin, 2)})
    print('  ', name, 'done', flush=True)

# whole raster (the MSPA raster holds the 3 km zone only)
with rasterio.open(MSPA) as s:
    mspa = s.read(1)
codes, cnt = np.unique(mspa, return_counts=True)
for c, n in zip(codes, cnt):
    mspa_rows.append({'region': 'Whole raster', 'mspa_code': int(c), 'element': ELEMENT.get(int(c), 'unknown'),
                      'area_ha': round(n * PIXEL_HA, 2)})
with rasterio.open(GI_CLASS) as s:
    pair = LUT[mspa].astype(np.int16) * 10 + s.read(1)
del mspa
pc, pn = np.unique(pair, return_counts=True)
for v, n in zip(pc, pn):
    el_rows.append({'region': 'Whole raster', 'element': NAMES[v // 10], 'gi_class': CLS[v % 10],
                    'area_ha': round(n * PIXEL_HA, 2)})

save(pd.DataFrame(mspa_rows), 'mspa_class_area_by_region.csv')
save(pd.DataFrame(el_rows), 'gi_element_by_class.csv')
d = pd.DataFrame(share_rows)
for c in ['gi_polygons_ha', 'mspa_foreground_ha', 'cores_corridors_branches_ha']:
    d[c.replace('_ha', '_pct_of_zone')] = (100 * d[c] / d['zone_area_ha']).round(2)
    d[c.replace('_ha', '_pct_of_county')] = (100 * d[c] / d['county_area_attr_ha']).round(2)
save(d, 'gi_share_by_region.csv')
save(pd.DataFrame(core_rows), 'core_metrics_by_region.csv')
save(pd.DataFrame(bin_rows), 'gi_binary_vs_mspa.csv')
