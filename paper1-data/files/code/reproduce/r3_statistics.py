"""Indicator derivation, Kruskal-Wallis and Dunn tests, hot-spot analysis and county totals, recomputed
from the hexagon layers.

Outputs (results/):
  indicator_derivation_check.csv   stored derived fields against their recomputation from the counts
  kruskal_wallis.csv               H, df, p for the six normalised indicators by region (GI hexagons)
  dunn_pairwise.csv                Dunn z and Bonferroni-adjusted p for the 28 region pairs, six indicators
  hotspot_check.csv                local G and impact classes recomputed against the stored ones
  global_g.csv                     Getis-Ord global G of the cumulative impact
  hotspot_classes_by_region.csv    hexagons and area per impact class and region
  pressures_by_region.csv          county totals from the land hexagons (Table 5)
"""
import numpy as np
import pandas as pd
from common import (INDICATORS, hexagons, minmax, kruskal, dunn, hex_neighbours, local_g, global_g, impact_class,
                    save, PIXEL_HA)

g = hexagons('gi_hexagons')
d = g.drop(columns='geometry')

# 1. derived fields
chk = []


def check(name, rule, stored, recomputed, tol, layer='gi_hexagons'):
    stored, recomputed = np.asarray(stored, float), np.asarray(recomputed, float)
    ok = np.abs(stored - recomputed) <= tol
    chk.append({'layer': layer, 'field': name, 'rule': rule, 'tolerance': tol, 'identical_share': round(float(ok.mean()), 5),
                'max_abs_difference': round(float(np.nanmax(np.abs(stored - recomputed))), 4)})


pct = lambda a: np.minimum(100, 100 * a / d['GN_met'])
for name, rule, rec, tol in [
        ('forest_met', 'for_count x 400 m2', d.for_count * 400, 0), ('aband_met', 'ab_count x 400 m2', d.ab_count * 400, 0),
        ('imperv_met', 'imperv_cou x 400 m2', d.imperv_cou * 400, 0), ('GN_met', 'GN_count x 400 m2', d.GN_count * 400, 0),
        ('frag_gi_m', 'frag_gi_c x 400 m2', d.frag_gi_c * 400, 0),
        ('perc_for', '100 x forest_met / GN_met', 100 * d.forest_met / d.GN_met, 0.001),
        ('aband_perc', 'round(100 x aband_met / GN_met)', np.round(100 * d.aband_met / d.GN_met), 0),
        ('imperv_per', 'round(100 x imperv_met / GN_met)', np.round(100 * d.imperv_met / d.GN_met), 0),
        ('frag_gi_pr', '100 x frag_gi_m / GN_met', 100 * d.frag_gi_m / d.GN_met, 0.001),
        ('road_frac', 'road_lengh / GN_met (m per m2), 3 decimals', np.round(d.road_lengh / d.GN_met, 3), 0.0005),
        ('for_c_norm', 'min-max of perc_for', minmax(d.perc_for), 0.0005),
        ('ab_c_norm', 'min-max of aband_perc', minmax(d.aband_perc), 0.0005),
        ('imp_c_norm', 'min-max of imperv_per', minmax(d.imperv_per), 0.0005),
        ('road_f_nor', 'min-max of road_frac', minmax(d.road_frac), 0.0005),
        ('frag_norm', 'min-max of frag_gi_pr', minmax(d.frag_gi_pr), 0.0005),
        ('cum_imp', 'sum of the five normalised indicators', d[list(INDICATORS)[:5]].sum(axis=1), 0.0015),
        ('cum_norm', 'min-max of cum_imp', minmax(d.cum_imp), 0.0005)]:
    check(name, rule, d[name], rec, tol)
# the land hexagons normalise the raw counts and the road length (not the shares of GI area)
ld = hexagons('land_hexagons').drop(columns='geometry')
for name, rule, rec in [('for_c_norm', 'min-max of for_count', minmax(ld.for_count)),
                        ('ab_c_norm', 'min-max of ab_count', minmax(ld.ab_count)),
                        ('imp_c_norm', 'min-max of imperv_cou', minmax(ld.imperv_cou)),
                        ('road_m_nor', 'min-max of road_lengh', minmax(ld.road_lengh)),
                        ('frag_norm', 'min-max of frag_gi_c', minmax(ld.frag_gi_c)),
                        ('cum_imp', 'sum of the five normalised indicators',
                         ld[['for_c_norm', 'ab_c_norm', 'imp_c_norm', 'road_m_nor', 'frag_norm']].sum(axis=1)),
                        ('cum_norm', 'min-max of cum_imp', minmax(ld.cum_imp))]:
    check(name, rule, ld[name], rec, 0.0015 if name == 'cum_imp' else 0.0006, layer='land_hexagons')
save(pd.DataFrame(chk), 'indicator_derivation_check.csv')

# 2. Kruskal-Wallis and Dunn (FSA::dunnTest conventions; groups in alphabetical order of the stored names)
kw, dn = [], []
for f, label in INDICATORS.items():
    h, df, p = kruskal(d[f].values, d['county'].values)
    kw.append({'indicator': f, 'description': label, 'n_hexagons': len(d), 'H': round(h, 3), 'df': df, 'p': p})
    t = dunn(d[f].values, d['county'].values)
    t.insert(0, 'indicator', f)
    dn.append(t)
save(pd.DataFrame(kw), 'kruskal_wallis.csv')
dn = pd.concat(dn)
for c in ['group_a', 'group_b']:
    dn[c] = dn[c].str.replace(' maakond', '').replace({'Tallinn': 'Tallinn area', 'Laane': 'Lääne',
                                                        'Laane-Viru': 'Lääne-Viru', 'Parnu': 'Pärnu'})
dn['z'] = dn['z'].round(4)
save(dn, 'dunn_pairwise.csv')

# 3. Hot spots: queen contiguity among the GI hexagons, hexagons without neighbours removed, binary weights,
#    local G without the focal cell (spdep::localG default), impact classes from two-sided p-values
nb = hex_neighbours(g)
keep = np.array([len(v) > 0 for v in nb])
sub = g[keep].reset_index(drop=True)
nb = hex_neighbours(sub)
G = local_g(sub['cum_norm'].values, nb)
cls = impact_class(G)
hs = hexagons('hotspots')
key = lambda df: (df['x_centroid'].round(0).astype(int).astype(str) + '_' + df['y_centroid'].round(0).astype(int).astype(str))
m = pd.DataFrame({'key': key(sub), 'G_recomputed': G, 'class_recomputed': cls}).merge(
    pd.DataFrame({'key': key(hs), 'G_stored': hs['localG'].values, 'class_stored': hs['clssfct'].values}),
    on='key', how='outer', indicator=True)
both = m[m['_merge'] == 'both']
save(pd.DataFrame([{'gi_hexagons': len(g), 'without_neighbours': int((~keep).sum()), 'analysed': len(sub),
                    'stored_hotspot_hexagons': len(hs), 'matched': len(both),
                    'max_abs_G_difference': float(np.abs(both.G_recomputed - both.G_stored).max()),
                    'identical_class_share': float((both.class_recomputed == both.class_stored).mean())}]),
     'hotspot_check.csv')
Gg, E, V, Z = global_g(sub['cum_norm'].values, nb)
save(pd.DataFrame([{'n': len(sub), 'global_G': Gg, 'expectation': E, 'variance': V, 'standard_deviate': Z}]),
     'global_g.csv')
hs['area_ha'] = hs.geometry.area / 1e4
save(hs.groupby(['region', 'clssfct']).agg(hexagons=('id', 'size'), area_ha=('area_ha', 'sum')).round(1).reset_index()
     .rename(columns={'clssfct': 'impact_class'}), 'hotspot_classes_by_region.csv')

# 4. County totals from the land hexagons (one record per hexagon) -- Table 5
land = hexagons('land_hexagons').drop(columns='geometry')
land['frag_gi_m'] = land['frag_gi_c'] * 400                     # not stored in this layer
t = land.groupby('region').agg(hexagons=('id', 'size'), forest_loss_ha=('forest_met', 'sum'),
                               abandonment_ha=('aband_met', 'sum'), imperviousness_ha=('imperv_met', 'sum'),
                               gi_fragmentation_ha=('frag_gi_m', 'sum'), road_length_km=('road_lengh', 'sum'),
                               gi_area_ha=('GN_met', 'sum'), mean_road_m_nor=('road_m_nor', 'mean'),
                               mean_cum_norm=('cum_norm', 'mean'))
for c in ['forest_loss_ha', 'abandonment_ha', 'imperviousness_ha', 'gi_fragmentation_ha', 'gi_area_ha']:
    t[c] = t[c] / 1e4
t['road_length_km'] = t['road_length_km'] / 1000
t['road_km_per_km2_gi'] = t['road_length_km'] / (t['gi_area_ha'] / 100)
t['road_km_per_km2_hexagons'] = t['road_length_km'] / (t['hexagons'] * 0.2165064)
save(t.round(4).reset_index(), 'pressures_by_region.csv')
