"""Recompute the per-hexagon pressure counts from the released rasters and road layer and compare them
with the values stored in the hexagon layers.

Cells are counted when their centre lies inside the hexagon (the QGIS zonal statistics rule).
Outputs (results/):
  hexagon_counts_recomputed_<layer>.csv   stored and recomputed counts per hexagon
  hexagon_counts_check_<layer>.csv        share of identical values, correlation and totals per indicator

    HEX_LAYERS="gi_hexagons land_hexagons" python3 r2_hexagon_indicators.py
"""
import os
import numpy as np
import pandas as pd
import geopandas as gpd
import pyogrio
from common import (MSPA, GI_BIN, FOREST, IMPERV, ROADS, FRAGMENTED, PENDING, hexagons, zonal_counts, save)

TESTS = [('GN_count', GI_BIN, lambda a: a == 1, 'GI cells (MSPA input raster)'),
         ('frag_gi_c', MSPA, lambda a: np.isin(a, FRAGMENTED), 'branch and islet cells (MSPA 1, 9, 101, 109)'),
         ('for_count', FOREST, lambda a: a == 1, 'tree cover loss cells'),
         ('imperv_cou', IMPERV, lambda a: a == 1, 'imperviousness increase cells')]
ABANDON = os.path.join(PENDING, 'data', '05_pressures', 'grassland_abandonment_20m.tif') if PENDING else None
if ABANDON and os.path.exists(ABANDON):
    TESTS.append(('ab_count', ABANDON, lambda a: a == 1, 'abandoned semi-natural grassland cells'))

roads = pyogrio.read_dataframe(ROADS)
for layer in os.environ.get('HEX_LAYERS', 'gi_hexagons land_hexagons').split():
    summary = []
    h = hexagons(layer)
    res = pd.DataFrame({'id': h['id'], 'region': h['region']})
    for field, path, test, label in TESTS:
        res[field + '_stored'] = h[field].values
        res[field + '_recomputed'] = zonal_counts(path, h.geometry, test)
        print('  ', layer, field, 'done', flush=True)
    # road length inside each hexagon
    inter = gpd.overlay(roads[['geometry']], gpd.GeoDataFrame({'i': np.arange(len(h))}, geometry=h.geometry.values,
                                                               crs=h.crs), how='intersection', keep_geom_type=True)
    res['road_lengh_stored'] = h['road_lengh'].values
    res['road_lengh_recomputed'] = inter.assign(L=inter.length).groupby('i')['L'].sum().reindex(
        np.arange(len(h)), fill_value=0).round(2).values
    save(res, f'hexagon_counts_recomputed_{layer}.csv')
    for field, *_rest in TESTS + [('road_lengh', None, None, 'road length in GI (m)')]:
        a, b = res[field + '_stored'].astype(float), res[field + '_recomputed'].astype(float)
        tol = 1.0 if field == 'road_lengh' else 0.0
        summary.append({'layer': layer, 'field': field, 'description': _rest[-1], 'hexagons': len(a),
                        'identical_share': round(float((np.abs(a - b) <= tol).mean()), 4),
                        'within_1_cell_or_1m_share': round(float((np.abs(a - b) <= max(tol, 1)).mean()), 4),
                        'correlation': round(float(np.corrcoef(a, b)[0, 1]), 6) if b.std() > 0 else None,
                        'total_stored': round(float(a.sum()), 1), 'total_recomputed': round(float(b.sum()), 1)})
    save(pd.DataFrame(summary), f'hexagon_counts_check_{layer}.csv')
