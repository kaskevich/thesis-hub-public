"""Compare every number in docs/article_values.csv (typed from the published article) with the value
obtained from the released data (tables/ and results/). Run r1-r3 first.

Output: docs/reconciliation_with_article.csv
  status: 'matches' (within one unit of the last published digit), 'within 1 %', 'within 5 %', 'differs',
          'not reproduced' (no counterpart found in the data)
"""
import os
import re
import numpy as np
import pandas as pd
from common import PKG, RESULTS, TABLES, hexagons

R = lambda f: pd.read_csv(os.path.join(RESULTS, f))
T = lambda f: pd.read_csv(os.path.join(TABLES, f))
FIX = {'Laane': 'Lääne', 'Laane-Viru': 'Lääne-Viru', 'Parnu': 'Pärnu', 'Hiiumaa': 'Hiiu', 'Tallinn': 'Tallinn area'}
art = pd.read_csv(os.path.join(PKG, 'docs', 'article_values.csv'), dtype={'published_value': str})
data, source, note = {}, {}, {}


def put(key, value, src, nt=''):
    data[key], source[key], note[key] = value, src, nt


first_code = lambda c: re.split(r'[,;]', str(c))[0].replace('*', '').strip()

# Table 3: GI polygons by first Annex I code
gp = T('gi_polygons_area_by_class_habitat.csv')
gp['code'] = gp['annex1_code'].map(first_code)
nat = gp[gp.gi_class == 'natura2000']
src3 = 'tables/gi_polygons_area_by_class_habitat.csv (GI polygons, area by first Annex I code)'
put('T3.forest', gp[gp.gi_class == 'forest'].area_ha.sum(), src3,
    'Table 3 repeats the values typed in the author file Habitats_EE_Coast.numbers (tables/table3_habitat_types_author.csv), '
    'which has no calculation trail; GI polygons give the value shown here')
put('T3.perm', gp[gp.gi_class == 'perm'].area_ha.sum(), src3, 'as T3.forest')
put('T3.annex1', nat.area_ha.sum(), src3, 'as T3.forest')
for k in art.id[art.id.str.match(r'T3\.\d')]:
    put(k, nat[nat.code == k.split('.')[1]].area_ha.sum(), src3, 'as T3.forest')

# Table 4
share = R('gi_share_by_region.csv').set_index('region')
core = R('core_metrics_by_region.csv').set_index('region')
for reg in core.index:
    put(f'T4.area.{reg}', share.loc[reg, 'county_area_attr_ha'], 'data/01_coastal_zone regions_3km: county_area_attr_ha',
        f'the published values are whole-county areas; the 3 km zone of this region is {share.loc[reg, "zone_area_ha"]:,.0f} ha')
    for k, col in [('lp', 'largest_patch_ha'), ('mpa', 'mean_patch_ha'), ('pd', 'patch_density_per_100ha'),
                   ('lsi', 'lsi'), ('lpi', 'largest_patch_index_pct')]:
        put(f'T4.{k}.{reg}', core.loc[reg, col], 'results/core_metrics_by_region.csv (core patches recomputed from MSPA)',
            'metrics of the core patches (MSPA classes 3, 17, 35, 67), 8-neighbour rule')
data['T4.area.Tallinn area'] = share.loc['Tallinn area', 'zone_area_ha']
source['T4.area.Tallinn area'] = 'data/01_coastal_zone regions_3km: zone_area_ha'
note['T4.area.Tallinn area'] = 'the Tallinn area polygon (19,399 ha) is the only region whose area attribute equals its own area'

# Table 5
p = R('pressures_by_region.csv').set_index('region')
gi_imp = hexagons('gi_hexagons').groupby('region')['imperv_met'].sum() / 1e4
for reg in p.index:
    put(f'T5.forest.{reg}', p.loc[reg, 'forest_loss_ha'], 'results/pressures_by_region.csv (land hexagons)')
    put(f'T5.aband.{reg}', p.loc[reg, 'abandonment_ha'], 'results/pressures_by_region.csv (land hexagons)')
    put(f'T5.imperv.{reg}', gi_imp.get(reg, 0), 'GI hexagons (data/06_hexagons gi_hexagons: sum of imperv_met)',
        f'this column matches the GI hexagons; the other Table 5 columns match the land hexagons, which give '
        f'{p.loc[reg, "imperviousness_ha"]:.2f} ha')
    put(f'T5.frag.{reg}', p.loc[reg, 'gi_fragmentation_ha'], 'results/pressures_by_region.csv (land hexagons)')
    put(f'T5.road.{reg}', np.nan, 'results/pressures_by_region.csv',
        f'road length in GI {p.loc[reg, "road_length_km"]:.1f} km; {p.loc[reg, "road_km_per_km2_gi"]:.3f} km per km2 of GI; '
        f'{p.loc[reg, "road_km_per_km2_hexagons"]:.3f} km per km2 of hexagons; no tested definition gives the published value')
note['T5.frag.Tallinn area'] = 'the published row repeats the Lääne-Viru value (550.6)'
note['T5.imperv.Tallinn area'] = note['T5.imperv.Tallinn area'] + '; the published row repeats the Lääne-Viru value (4.3)'

# Figure 5 / text: element areas by GI class (author's vector element layers)
b = T('gi_elements_area_by_region_class.csv')
b['region'] = b['region'].replace(FIX)
tot = b.groupby(['element', 'gi_class']).area_ha.sum()
ras = R('gi_element_by_class.csv')
ras = ras[ras.region == 'Whole raster'].replace({'gi_class': {'forest': 'forest', 'Natura 2000 habitat': 'natura2000',
                                                             'permanent grassland': 'perm'}}).set_index(['element', 'gi_class']).area_ha
for el in ['cores', 'corridors', 'branches']:
    for c in ['forest', 'natura2000', 'perm']:
        v = tot.get((el, c), np.nan)
        put(f'F5.{el}.{c}', v, 'tables/gi_elements_area_by_region_class.csv (author element polygons)',
            f'MSPA raster x GI class raster gives {ras.get((el, c), 0):,.0f} ha')
        for k in [f'TX.{el}.{c}']:
            put(k, v, 'tables/gi_elements_area_by_region_class.csv (author element polygons)', 'the text value differs from Fig. 5')
mb = R('gi_binary_vs_mspa.csv')
fg = mb[(mb.gi_binary == 1) & (mb.mspa_foreground)].area_ha.sum()
put('F5.total', fg, 'results/gi_binary_vs_mspa.csv (MSPA foreground in the 3 km zone)',
    f'GI polygons: {gp.area_ha.sum():,.0f} ha; cores + corridors + branches (element polygons): {b.area_ha.sum():,.0f} ha')
for k in art.id[art.id.str.startswith('F6.')]:
    _, el, c, reg = k.split('.')
    put(k, b[(b.element == el) & (b.gi_class == c) & (b.region == reg)].area_ha.sum(),
        'tables/gi_elements_area_by_region_class.csv (author element polygons)')

# Figure 7: Annex I habitat types by element (natura2000 class of the element polygons)
a = T('annex1_habitats_by_element_region.csv')
a['code'] = a['annex1_code'].map(first_code)
srca = 'tables/annex1_habitats_by_element_region.csv (first Annex I code)'
s = lambda code, els, regs=None: a[(a.code == code) & a.element.isin(els) & (True if regs is None else a.region.isin(regs))].area_ha.sum()
put('F7.9010.cores', s('9010', ['cores']), srca)
put('F7.9010.cores.Saare', s('9010', ['cores'], ['Saare']), srca)
put('F7.9010.corridors', s('9010', ['corridors']), srca)
put('F7.9010.branches', s('9010', ['branches']), srca)
put('F7.1630.cores', s('1630', ['cores']), srca)
put('F7.1630.corridors_branches', s('1630', ['corridors', 'branches']), srca)
put('F7.6280.cores.Saare', s('6280', ['cores'], ['Saare']), srca,
    f'all elements: {s("6280", ["cores", "corridors", "branches"], ["Saare"]):,.0f} ha')
put('F7.6280.cores.Hiiu', s('6280', ['cores'], ['Hiiu']), srca,
    f'all elements: {s("6280", ["cores", "corridors", "branches"], ["Hiiu"]):,.0f} ha')
put('F7.2180.cores.HHP', s('2180', ['cores'], ['Harju', 'Hiiu', 'Pärnu']), srca,
    f'all elements: {s("2180", ["cores", "corridors", "branches"], ["Harju", "Hiiu", "Pärnu"]):,.0f} ha')

# GI share (text): MSPA foreground as a share of the whole county area
for reg in share.index:
    put(f'GS.{reg}', share.loc[reg, 'mspa_foreground_pct_of_county'], 'results/gi_share_by_region.csv',
        'MSPA foreground / whole-county area (the text says "coastal area"); as a share of the 3 km zone: '
        f'{share.loc[reg, "mspa_foreground_pct_of_zone"]:.1f} %')
h = share.loc['Harju']
t = share.loc['Tallinn area']
note['GS.Harju'] += f'; excluding the Tallinn area: {100 * (h.mspa_foreground_ha - t.mspa_foreground_ha) / h.county_area_attr_ha:.1f} %'

# Dunn and global G
dn = R('dunn_pairwise.csv')
z = lambda ind, a_, b_: dn[(dn.indicator == ind) & (dn.group_a == a_) & (dn.group_b == b_)].z.iloc[0]
put('DZ.aband.Saare-Tallinn', z('ab_c_norm', 'Saare', 'Tallinn area'), 'results/dunn_pairwise.csv')
hit = dn.loc[(dn.z.round(2) == -19.94)]
put('DZ.frag.Ida-Viru-Tallinn', z('frag_norm', 'Ida-Viru', 'Tallinn area'), 'results/dunn_pairwise.csv',
    'z = -19.94 occurs only for ' + '; '.join(f'{r.indicator} {r.group_a} vs {r.group_b}' for r in hit.itertuples()))
for k, (a_, b_) in {'F9.cum.Harju-Ida-Viru': ('Harju', 'Ida-Viru'), 'F9.cum.Hiiu-Ida-Viru': ('Hiiu', 'Ida-Viru'),
                     'F9.cum.Ida-Viru-Lääne-Viru': ('Ida-Viru', 'Lääne-Viru'), 'F9.cum.Pärnu-Saare': ('Pärnu', 'Saare')}.items():
    put(k, z('cum_norm', a_, b_), 'results/dunn_pairwise.csv')
gg = R('global_g.csv').iloc[0]
put('GG.G', gg.global_G, 'results/global_g.csv')
put('GG.E', gg.expectation, 'results/global_g.csv', 'E = S0 / (n (n - 1)) with n = 19,688')
put('GG.V', gg.variance, 'results/global_g.csv', 'the published variance is 1000 times larger')
put('GG.Z', gg.standard_deviate, 'results/global_g.csv', 'the published "standard deviation" is the standard deviate (z) of G')


def compare(pub_s, val):
    if val is None or (isinstance(val, float) and np.isnan(val)):
        return np.nan, 'not reproduced'
    pub = float(pub_s)
    if 'e' in pub_s.lower():
        tol = 0.5 * 10 ** (np.floor(np.log10(abs(pub))) - 2)
    else:
        dec = len(pub_s.split('.')[1]) if '.' in pub_s else 0
        tol = 10 ** -dec + 1e-9                     # one unit of the last published digit (rounded or truncated)
    diff = val - pub
    rel = abs(diff) / abs(pub) if pub else np.inf
    st = 'matches' if abs(diff) <= tol else 'within 1 %' if rel <= 0.01 else 'within 5 %' if rel <= 0.05 else 'differs'
    return diff, st


rows = []
for r in art.itertuples():
    v = data.get(r.id, np.nan)
    diff, st = compare(r.published_value, v)
    rows.append({'id': r.id, 'location': r.location, 'item': r.item, 'region': r.region, 'unit': r.unit,
                 'published': r.published_value, 'from_data': v if pd.isna(v) or abs(v) >= 0.01 else float(f'{v:.4g}'),
                 'difference': diff, 'status': st, 'data_source': source.get(r.id, ''), 'note': note.get(r.id, '')})
out = pd.DataFrame(rows)
for c in ['from_data', 'difference']:
    out[c] = out[c].map(lambda x: '' if pd.isna(x) else (f'{x:.4g}' if abs(x) < 0.01 and x != 0 else round(x, 2)))
out.to_csv(os.path.join(PKG, 'docs', 'reconciliation_with_article.csv'), index=False)
print(out.status.value_counts().to_string())
print(out.groupby(out.id.str.split('.').str[0]).status.value_counts().unstack(fill_value=0).to_string())
