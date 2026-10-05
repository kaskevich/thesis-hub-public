"""Shared paths and helpers for the reproduction scripts. Uses only files in this package."""
import os
import numpy as np
import pandas as pd
import geopandas as gpd
import pyogrio
import rasterio
from rasterio.features import rasterize
from scipy import stats

PKG = os.path.abspath(os.environ.get('PKG_DIR', os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..')))
RESULTS = os.path.abspath(os.environ.get('RESULTS_DIR', os.path.join(PKG, 'results')))
PENDING = os.environ.get('PENDING_DIR')            # optional: folder with the layers released separately
os.makedirs(RESULTS, exist_ok=True)

MSPA = os.path.join(PKG, 'data', '03_mspa', 'mspa_coastal_3km_20m.tif')
GI_BIN = os.path.join(PKG, 'data', '02_green_infrastructure', 'gi_binary_20m.tif')
GI_CLASS = os.path.join(PKG, 'data', '02_green_infrastructure', 'gi_class_20m.tif')
FOREST = os.path.join(PKG, 'data', '05_pressures', 'forest_loss_2012_2018_20m.tif')
IMPERV = os.path.join(PKG, 'data', '05_pressures', 'imperviousness_increase_2006_2018_20m.tif')
ROADS = os.path.join(PKG, 'data', '05_pressures', 'roads_in_gi.gpkg')
ZONE = os.path.join(PKG, 'data', '01_coastal_zone', 'coastal_zone_3km.gpkg')
HEX = os.path.join(PKG, 'data', '06_hexagons', 'hexagons_impacts.gpkg')
TABLES = os.path.join(PKG, 'tables')

PIXEL_HA = 0.04                                        # 20 m x 20 m
# MSPA byte codes grouped into the GI elements of the article. Cores = the classes found in the
# author's core rasters (Cores/*_cores.tif); corridors = bridges; branches; islets.
ELEMENT = {3: 'cores', 17: 'cores', 35: 'cores', 67: 'cores', 33: 'corridors', 1: 'branches', 101: 'branches',
           9: 'islets', 109: 'islets', 65: 'other foreground', 105: 'other foreground', 133: 'other foreground',
           137: 'other foreground', 165: 'other foreground', 169: 'other foreground', 100: 'background (core-opening)',
           220: 'background (border-opening)', 0: 'background'}
FOREGROUND = [c for c, e in ELEMENT.items() if not e.startswith('background')]
FRAGMENTED = [1, 9, 101, 109]                         # branch and islet classes: the GI fragmentation indicator
GI_CLASSES = {1: 'forest', 2: 'permanent grassland', 3: 'Natura 2000 habitat'}
INDICATORS = {'for_c_norm': 'forest cover loss', 'ab_c_norm': 'grassland abandonment',
              'imp_c_norm': 'imperviousness increase', 'road_f_nor': 'road density in GI',
              'frag_norm': 'GI fragmentation', 'cum_norm': 'cumulative impact'}


def save(df, name):
    p = os.path.join(RESULTS, name)
    df.to_csv(p, index=False)
    print('  wrote results/' + name, len(df), 'rows')
    return p


def regions():
    return pyogrio.read_dataframe(ZONE, layer='regions_3km')


def hexagons(layer):
    return pyogrio.read_dataframe(HEX, layer=layer)


def region_masks(shape, transform, regs=None):
    regs = regions() if regs is None else regs
    for _, r in regs.iterrows():
        yield r['region'], rasterize([(r.geometry, 1)], out_shape=shape, transform=transform, fill=0,
                                     dtype='uint8').astype(bool)


def zonal_counts(raster_path, polys, value_test, strip=1024):
    """Count, for each polygon, the raster cells whose centre lies inside it and pass value_test.
    polys: GeoSeries in any CRS (reprojected to the raster CRS). Polygons must not overlap."""
    with rasterio.open(raster_path) as s:
        g = polys.to_crs(s.crs) if polys.crs != s.crs else polys
        counts = np.zeros(len(g) + 1, np.int64)
        bounds = g.bounds.values
        for r0 in range(0, s.height, strip):
            h = min(strip, s.height - r0)
            win = rasterio.windows.Window(0, r0, s.width, h)
            tr = s.window_transform(win)
            top, bottom = tr.f, tr.f + tr.e * h
            sel = np.where((bounds[:, 1] <= top) & (bounds[:, 3] >= bottom))[0]
            if len(sel) == 0:
                continue
            ids = rasterize(((g.iloc[i], i + 1) for i in sel), out_shape=(h, s.width), transform=tr, fill=0,
                            dtype='int32')
            a = s.read(1, window=win)
            m = value_test(a) & (ids > 0)
            counts += np.bincount(ids[m], minlength=len(g) + 1)
    return counts[1:]


def minmax(x):
    x = np.asarray(x, float)
    return (x - x.min()) / (x.max() - x.min())


def kruskal(values, groups):
    labs = sorted(set(groups))
    h, p = stats.kruskal(*[values[groups == l] for l in labs])
    return h, len(labs) - 1, p


def dunn(values, groups):
    """Dunn's test with tie correction; z = mean rank of A minus mean rank of B (A before B alphabetically),
    as in FSA::dunnTest. Returns rows with z, unadjusted and Bonferroni-adjusted two-sided p."""
    v = np.asarray(values, float)
    g = np.asarray(groups)
    r = stats.rankdata(v)
    n = len(v)
    _, cnt = np.unique(v, return_counts=True)
    tie = (cnt ** 3 - cnt).sum() / (12 * (n - 1))
    labs = sorted(set(g))
    rbar = {l: r[g == l].mean() for l in labs}
    ng = {l: int((g == l).sum()) for l in labs}
    rows = []
    k = len(labs) * (len(labs) - 1) / 2
    for i, a in enumerate(labs):
        for b in labs[i + 1:]:
            se = np.sqrt((n * (n + 1) / 12 - tie) * (1 / ng[a] + 1 / ng[b]))
            z = (rbar[a] - rbar[b]) / se
            p = 2 * stats.norm.sf(abs(z))
            rows.append({'group_a': a, 'group_b': b, 'z': z, 'p_unadjusted': p, 'p_bonferroni': min(1.0, p * k)})
    return pd.DataFrame(rows)


def hex_neighbours(gdf, dist=501.0):
    """Hexagon neighbours (shared edge) as index pairs: centroids 500 m apart on this grid."""
    from scipy.spatial import cKDTree
    xy = np.c_[gdf.geometry.centroid.x, gdf.geometry.centroid.y]
    pairs = cKDTree(xy).query_pairs(dist, output_type='ndarray')
    nb = [[] for _ in range(len(gdf))]
    for i, j in pairs:
        nb[i].append(j)
        nb[j].append(i)
    return nb


def local_g(x, nb):
    """Getis-Ord local G (Gi, the focal cell excluded, binary weights) as returned by spdep::localG
    without include.self: a z-value."""
    x = np.asarray(x, float)
    n = len(x)
    tot, tot2 = x.sum(), (x ** 2).sum()
    out = np.empty(n)
    for i in range(n):
        w = len(nb[i])
        xbar = (tot - x[i]) / (n - 1)
        s = np.sqrt((tot2 - x[i] ** 2) / (n - 1) - xbar ** 2)
        lag = x[nb[i]].sum()
        out[i] = (lag - w * xbar) / (s * np.sqrt(((n - 1) * w - w ** 2) / (n - 2)))
    return out


def global_g(x, nb):
    """Getis-Ord global G with binary weights; expectation and variance under randomisation
    (Getis and Ord 1992), as in spdep::globalG.test."""
    x = np.asarray(x, float)
    n = len(x)
    w = np.array([len(v) for v in nb], float)
    s0 = w.sum()
    s1 = 0.5 * 4 * s0                                   # symmetric binary weights: (w_ij + w_ji)^2 = 4
    s2 = ((2 * w) ** 2).sum()
    num = sum(x[i] * x[nb[i]].sum() for i in range(n))
    den = x.sum() ** 2 - (x ** 2).sum()
    G = num / den
    E = s0 / (n * (n - 1))
    m1, m2, m3, m4 = [(x ** k).sum() for k in (1, 2, 3, 4)]
    b0 = (n * n - 3 * n + 3) * s1 - n * s2 + 3 * s0 ** 2
    b1 = -((n * n - n) * s1 - 2 * n * s2 + 6 * s0 ** 2)
    b2 = -(2 * n * s1 - (n + 3) * s2 + 6 * s0 ** 2)
    b3 = 4 * (n - 1) * s1 - 2 * (n + 1) * s2 + 8 * s0 ** 2
    b4 = s1 - s2 + s0 ** 2
    eg2 = (b0 * m2 ** 2 + b1 * m4 + b2 * m1 ** 2 * m2 + b3 * m1 * m3 + b4 * m1 ** 4) / \
          ((m1 ** 2 - m2) ** 2 * n * (n - 1) * (n - 2) * (n - 3))
    var = eg2 - E ** 2
    return G, E, var, (G - E) / np.sqrt(var)


def impact_class(g):
    p = 2 * stats.norm.sf(np.abs(g))
    out = np.full(len(g), 'Neutral Impact', dtype=object)
    for cond, lab in [((g > 0) & (p <= 0.10), 'Moderate Impact'), ((g > 0) & (p <= 0.05), 'High Impact'),
                      ((g > 0) & (p <= 0.01), 'Very High Impact'), ((g < 0) & (p <= 0.10), 'Slightly Low Impact'),
                      ((g < 0) & (p <= 0.05), 'Low Impact'), ((g < 0) & (p <= 0.01), 'Very Low Impact')]:
        out[cond] = lab
    return out
