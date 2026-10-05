"""Build the data release for Kaskevich et al. (2024), Ecological Indicators 169, 112824,
from the author's working data.

    PAPER1_DIR=~/Desktop/BGI_DP  ANALYSIS_DIR=~/Desktop/ThirtyFourtyDocker/ls_metrics_allstat \
    python3 code/build/build_from_raw.py mspa gi giclass pressures vectors hexagons tables lsm code

Each step can be run on its own. Outputs go to the package folder (two levels above this file)
and, for the layers whose redistribution terms are still being confirmed, to PENDING_DIR
(default: <package>_pending_licence_check, a sibling folder that is not part of the package).

Requires Python 3.10+ with numpy, pandas, geopandas, pyogrio, shapely 2, rasterio (GDAL 3.6+),
openpyxl.
"""
import glob, os, re, shutil, sys, tempfile
import numpy as np
import pandas as pd
import geopandas as gpd
import pyogrio
import rasterio
import rasterio.shutil
from rasterio.crs import CRS
from rasterio.features import rasterize
from rasterio.windows import Window, from_bounds
import shapely
from shapely import force_2d

HERE = os.path.dirname(os.path.abspath(__file__))
PKG = os.path.abspath(os.environ.get('OUT_DIR', os.path.join(HERE, '..', '..')))
PEND = os.path.abspath(os.environ.get('PENDING_DIR', PKG.rstrip('/') + '_pending_licence_check'))
P1 = os.path.expanduser(os.environ.get('PAPER1_DIR', '~/Desktop/BGI_DP'))
AN = os.path.expanduser(os.environ.get('ANALYSIS_DIR', '~/Desktop/ThirtyFourtyDocker/ls_metrics_allstat'))
TMP = tempfile.mkdtemp(prefix='p1rel_')
os.environ.setdefault('GDAL_CACHEMAX', '256')
EST97 = CRS.from_epsg(3301)
LAEA = CRS.from_epsg(3035)

# Region names: hexagon attribute value -> label used in this release
REGION = {'Harju maakond': 'Harju', 'Hiiu maakond': 'Hiiu', 'Ida-Viru maakond': 'Ida-Viru',
          'Laane maakond': 'Lääne', 'Laane-Viru maakond': 'Lääne-Viru', 'Parnu maakond': 'Pärnu',
          'Saare maakond': 'Saare', 'Tallinn maakond': 'Tallinn area'}
COUNTY_3KM = [('Harju', 'Coastline/Harju_maakond_3km.shp'), ('Hiiu', 'Coastline/Hiiu_maakond_3km.shp'),
              ('Ida-Viru', 'Coastline/Ida-Viru_maakond_3km.shp'), ('Lääne', 'Coastline/Laane_maakond_3km.shp'),
              ('Lääne-Viru', 'Coastline/Laane-Viru_maakond_3km.shp'), ('Pärnu', 'Coastline/Parnu_maakond_3km.shp'),
              ('Saare', 'Coastline/Saare_maakond_3km.shp'), ('Tallinn area', 'Coastline/Tallinn_county_3km.shp')]
GI_COUNTY_RASTERS = ['Harju maakond.tif', 'Hiiu maakond.tif', 'Ida-Viru maakond.tif', 'Lääne maakond.tif',
                     'Lääne-Viru maakond.tif', 'Pärnu maakond.tif', 'Saare maakond.tif']
GI_CLASS = {'forest': 1, 'perm': 2, 'natura2000': 3}       # painted in this order: later classes win


def out(*parts, pending=False):
    p = os.path.join(PEND if pending else PKG, *parts)
    os.makedirs(os.path.dirname(p), exist_ok=True)
    return p


_GPKG = {}


def gpkg_path(final):
    """GeoPackages are SQLite files: build them in the temporary folder, copy them at the end of the step."""
    os.makedirs(os.path.join(TMP, 'gpkg'), exist_ok=True)
    t = os.path.join(TMP, 'gpkg', final.replace(os.sep, '_'))
    if os.path.exists(t) and t not in _GPKG:
        os.remove(t)
    _GPKG[t] = final
    return t


def flush_gpkg():
    for t, f in _GPKG.items():
        shutil.copyfile(t, f)
        os.remove(t)
    _GPKG.clear()


def src(rel):
    return os.path.join(P1, rel)


def write_cog(path, arr, transform, crs, nodata=None, tags=None, description=None):
    """Write a single-band Cloud Optimized GeoTIFF (DEFLATE, 512 px tiles, nearest overviews)."""
    tmp = os.path.join(TMP, os.path.basename(path))
    prof = dict(driver='GTiff', width=arr.shape[1], height=arr.shape[0], count=1, dtype=arr.dtype.name,
                crs=crs, transform=transform, nodata=nodata, tiled=True, blockxsize=512, blockysize=512,
                compress='deflate')
    with rasterio.open(tmp, 'w', **prof) as d:
        d.write(arr, 1)
        if tags:
            d.update_tags(**tags)
        if description:
            d.set_band_description(1, description)
    cog = tmp[:-4] + '.cog.tif'
    rasterio.shutil.copy(tmp, cog, driver='COG', compress='DEFLATE', level=9, blocksize=512,
                         overview_resampling='nearest', bigtiff='NO')
    shutil.copyfile(cog, path)          # built in a temporary folder: COG creation writes side files
    os.remove(tmp)
    os.remove(cog)
    print('  wrote', os.path.relpath(path, os.path.dirname(PKG)), arr.shape, arr.dtype)


def coastal_zone():
    z = gpd.read_file(src('Coastline/EE_3km_buffer_coastline.shp')).set_crs(EST97, allow_override=True)
    z['geometry'] = force_2d(z.geometry.values)
    return z


# ---------------------------------------------------------------------------------------------
def mspa_grid():
    with rasterio.open(src('MSPA_rasters_3km/MSPA_EE_coast_3km.tif')) as s:
        return dict(transform=s.transform, shape=(s.height, s.width))


def step_mspa():
    print('rasters: MSPA', flush=True)
    # 1. MSPA, 3 km coastal zone, whole coast. Source is float32 with a LOCAL_CS that is L-EST97.
    with rasterio.open(src('MSPA_rasters_3km/MSPA_EE_coast_3km.tif')) as s:
        grid = dict(transform=s.transform, shape=(s.height, s.width))
        mspa = np.zeros((s.height, s.width), np.uint8)
        for _, w in s.block_windows(1):
            a = s.read(1, window=w)
            assert np.all(a == np.round(a)) and a.min() >= 0 and a.max() <= 255
            mspa[w.row_off:w.row_off + w.height, w.col_off:w.col_off + w.width] = a.astype(np.uint8)
    write_cog(out('data', '03_mspa', 'mspa_coastal_3km_20m.tif'), mspa, grid['transform'], EST97,
              tags={'SOURCE': 'GuidosToolbox 2.5 MSPA, parameter string 8_12_0_1 (8-connectivity, '
                              'EdgeWidth 12 px); county outputs clipped to the 3 km coastal zone and mosaicked',
                    'CLASSES': 'see docs/mspa_codes.csv'},
              description='MSPA class (GuidosToolbox byte code)')


def step_gi():
    print('rasters: GI binary', flush=True)
    # 2. GI binary raster (MSPA input), mosaic of the county rasters on the MSPA grid
    grid = mspa_grid()
    T0 = grid['transform']
    base = src('BGI_Project_QGIS Data/BGI_raster_by_regions ')
    # grid: MSPA pixel alignment, extent = union of the MSPA mosaic and the county rasters
    L, R = T0.c, T0.c + T0.a * grid['shape'][1]
    TOP, BOT = T0.f, T0.f + T0.e * grid['shape'][0]
    for f in GI_COUNTY_RASTERS:
        with rasterio.open(os.path.join(base, f)) as s:
            L, R = min(L, s.bounds.left), max(R, s.bounds.right)
            BOT, TOP = min(BOT, s.bounds.bottom), max(TOP, s.bounds.top)
    T = rasterio.Affine(T0.a, 0, L, 0, T0.e, TOP)
    gi = np.zeros((int(round((TOP - BOT) / T0.a)), int(round((R - L) / T0.a))), np.uint8)
    for f in GI_COUNTY_RASTERS:
        with rasterio.open(os.path.join(base, f)) as s:
            col = (s.transform.c - T.c) / T.a
            row = (s.transform.f - T.f) / T.e
            assert abs(col - round(col)) < 1e-6 and abs(row - round(row)) < 1e-6, f + ' not on the MSPA grid'
            col, row = int(round(col)), int(round(row))
            a = s.read(1).astype(np.uint8)
            r0, c0 = max(row, 0), max(col, 0)
            r1, c1 = min(row + s.height, gi.shape[0]), min(col + s.width, gi.shape[1])
            sub = a[r0 - row:r1 - row, c0 - col:c1 - col] == 1
            gi[r0:r1, c0:c1] |= sub.astype(np.uint8)
            print('  ', f, int((a == 1).sum()), 'GI pixels; outside grid:', int((a == 1).sum() - sub.sum()))
    write_cog(out('data', '02_green_infrastructure', 'gi_binary_20m.tif'), gi, T, EST97,
              tags={'SOURCE': 'Union of the seven county GI rasters used as MSPA input (1 = GI, 0 = not GI)'},
              description='Green Infrastructure (1) / other (0)')


def step_giclass():
    print('rasters: GI class', flush=True)
    grid = mspa_grid()
    T = grid['transform']
    # 3. GI class raster: GI polygons of the 3 km zone rasterized on the same grid (pixel-centre rule)
    gp = gpd.read_file(src('Green_Infrastructure/green_network_3km.shp'), columns=['class'])
    gp['geometry'] = force_2d(gp.geometry.values)
    cls = np.zeros(grid['shape'], np.uint8)
    bits = np.zeros(grid['shape'], np.uint8)
    for name, code in GI_CLASS.items():
        shapes = [(g, 1) for g in gp.geometry[gp['class'] == name] if g is not None and not g.is_empty]
        m = rasterize(shapes, out_shape=grid['shape'], transform=T, fill=0, dtype='uint8')
        cls[m == 1] = code
        m <<= (code - 1)
        bits |= m
        del m
    over = {int(k): int(v) for k, v in zip(*np.unique(bits[bits > 0], return_counts=True))}
    print('  class bit combinations (1 forest, 2 perm, 4 natura2000):', over)
    write_cog(out('data', '02_green_infrastructure', 'gi_class_20m.tif'), cls, T, EST97,
              tags={'SOURCE': 'GI polygons of the 3 km zone rasterized at 20 m (pixel centre)',
                    'CLASSES': '0 not GI; 1 forest; 2 permanent grassland; 3 Natura 2000 habitat '
                               '(where polygons overlap: 3 over 2 over 1)'},
              description='GI class')


def step_pressures():
    print('rasters: pressures', flush=True)
    # 4. Pressure rasters (Copernicus-derived, EPSG:3035 grid kept), cropped to the coastal zone + 600 m
    z = coastal_zone()
    zb = gpd.GeoSeries([z.union_all().buffer(600)], crs=EST97).to_crs(LAEA)
    for rel, name, desc in [
            ('impacts/tree-coveer-density/forest_cover_change/forest_loss_recl18-12.tif',
             'forest_loss_2012_2018_20m.tif', 'Tree cover loss 2012-2018 (1), no loss (0)'),
            ('impacts/imperviousness/change/imperv_change18-06_pos.tif',
             'imperviousness_increase_2006_2018_20m.tif', 'Imperviousness increase 2006-2018 (1), none (0)')]:
        with rasterio.open(src(rel)) as s:
            w = from_bounds(*zb.total_bounds, s.transform).round_offsets().round_lengths()
            w = w.intersection(Window(0, 0, s.width, s.height))
            a = s.read(1, window=w)
            tr = s.window_transform(w)
            valid = (a != s.nodata) if s.nodata is not None else np.ones(a.shape, bool)
            assert set(np.unique(a[valid]).tolist()) <= {0, 1}, rel
            inside = rasterize([(zb.iloc[0], 1)], out_shape=a.shape, transform=tr, fill=0, all_touched=True,
                               dtype='uint8').astype(bool)
            o = np.full(a.shape, 255, np.uint8)
            m = valid & inside
            o[m] = a[m].astype(np.uint8)
            print('  ', name, 'pixels =1:', int((o == 1).sum()))
        write_cog(out('data', '05_pressures', name), o, tr, LAEA, nodata=255,
                  tags={'SOURCE': os.path.basename(rel) + ' (author reclassification of a Copernicus Land '
                                  'Monitoring Service product), cropped to the 3 km coastal zone + 600 m; '
                                  'grid and values unchanged'},
                  description=desc)

    # 5. Pending: grassland abandonment raster (semi-natural habitats never managed 2007-2018)
    with rasterio.open(src('impacts/extracted/semnat_hab_never_managed_3km_rst.tif')) as s:
        a = s.read(1)
        assert set(np.unique(a).tolist()) <= {0, 1}
        write_cog(out('data', '05_pressures', 'grassland_abandonment_20m.tif', pending=True), a.astype(np.uint8),
                  s.transform, s.crs, nodata=None,
                  tags={'SOURCE': 'semnat_hab_never_managed_3km_rst.tif; 1 = semi-natural habitat with no '
                                  'management support recorded 2007-2018'},
                  description='Abandoned semi-natural grassland (1)')


# ---------------------------------------------------------------------------------------------
def step_vectors():
    print('vectors')
    gpkg = gpkg_path(out('data', '01_coastal_zone', 'coastal_zone_3km.gpkg'))
    z = coastal_zone()
    buf = gpd.GeoDataFrame({'name': ['3 km buffer of the Estonian coastline (land and sea)'],
                            'area_ha': [z.union_all().area / 1e4]}, geometry=[z.union_all()], crs=EST97)
    pyogrio.write_dataframe(buf, gpkg, layer='coastline_buffer_3km', driver='GPKG')
    rows = []
    for name, rel in COUNTY_3KM:
        g = gpd.read_file(src(rel)).set_crs(EST97, allow_override=True)
        geom = shapely.union_all(force_2d(g.geometry.values))
        attr_area = None
        for c in ('area', 'Area'):
            if c in g:
                attr_area = float(g[c].iloc[0]) / 1e4
        rows.append({'region': name, 'county_code': str(g['MKOOD'].iloc[0]), 'zone_area_ha': geom.area / 1e4,
                     'county_area_attr_ha': attr_area, 'geometry': geom})
    reg = gpd.GeoDataFrame(rows, geometry='geometry', crs=EST97)
    land = shapely.union_all(reg[reg.region != 'Tallinn area'].geometry.values)
    zone = gpd.GeoDataFrame({'name': ['Estonian coastal zone, 3 km inland (land part of the buffer)'],
                             'area_ha': [land.area / 1e4]}, geometry=[land], crs=EST97)
    pyogrio.write_dataframe(zone, gpkg, layer='coastal_zone_3km', driver='GPKG')
    pyogrio.write_dataframe(reg, gpkg, layer='regions_3km', driver='GPKG')
    print('  regions:', reg[['region', 'zone_area_ha', 'county_area_attr_ha']].round(1).to_dict('records'))

    # Roads crossing GI (ETAK, Estonian Land Board open data)
    r = gpd.read_file(src('impacts/roads/Fragmentation_roads/roads_intersections.shp'),
                      columns=['etak_id', 'kood', 'kood_t', 'tyyp', 'tyyp_t', 'class'])
    r = r.set_crs(EST97, allow_override=True)
    r['geometry'] = force_2d(r.geometry.values)
    r = r.rename(columns={'class': 'gi_class', 'tyyp': 'road_type', 'tyyp_t': 'road_type_label',
                          'kood': 'etak_code', 'kood_t': 'etak_code_label'})
    r['length_m'] = r.length.round(2)
    pyogrio.write_dataframe(r, gpkg_path(out('data', '05_pressures', 'roads_in_gi.gpkg')), layer='roads_in_gi',
                            driver='GPKG')
    print('  roads:', len(r), 'segments,', round(r.length_m.sum() / 1000, 1), 'km;', r.road_type_label.value_counts().to_dict())

    # ---- pending licence check: layers that carry habitat-inventory attributes
    g = gpd.read_file(src('Green_Infrastructure/green_network_3km.shp'), columns=['class', 'natura_cod', 'status'])
    g['geometry'] = force_2d(g.geometry.values)
    g = g.rename(columns={'class': 'gi_class', 'natura_cod': 'annex1_code', 'status': 'annex1_status'})
    g['area_m2'] = g.area.round(1)
    pyogrio.write_dataframe(g, gpkg_path(out('data', '02_green_infrastructure', 'gi_polygons_3km.gpkg', pending=True)),
                            layer='gi_polygons', driver='GPKG')
    ep = gpkg_path(out('data', '04_gi_elements', 'gi_elements.gpkg', pending=True))
    for element, pattern in [('cores', 'Cores/in_vector/*_cores.shp'), ('corridors', 'Corridors/*_corridors.shp'),
                             ('branches', 'Branches/*_branches.shp')]:
        parts = []
        for f in sorted(glob.glob(src(pattern))):
            e = gpd.read_file(f, columns=['class', 'natura_cod', 'status']).set_crs(EST97, allow_override=True)
            e['geometry'] = force_2d(e.geometry.values)
            e.insert(0, 'source_file', os.path.basename(f))
            parts.append(e)
        e = pd.concat(parts, ignore_index=True)
        e = gpd.GeoDataFrame(e, geometry='geometry', crs=EST97).rename(
            columns={'class': 'gi_class', 'natura_cod': 'annex1_code', 'status': 'annex1_status'})
        e['area_m2'] = e.area.round(1)
        pyogrio.write_dataframe(e, ep, layer=element, driver='GPKG')
        print('  ', element, len(e), 'polygons from', len(parts), 'files')
    a = gpd.read_file(src('impacts/seminat_hab_never_managed.shp'), columns=['nat_elup_p'])
    a = a.set_crs(EST97, allow_override=True).rename(columns={'nat_elup_p': 'habitat_code'})
    a['geometry'] = force_2d(a.geometry.values)
    a['area_m2'] = a.area.round(1)
    pyogrio.write_dataframe(a, gpkg_path(out('data', '05_pressures', 'grassland_abandonment.gpkg', pending=True)),
                            layer='abandoned_grassland', driver='GPKG')
    flush_gpkg()
    print('  abandonment polygons:', len(a), '(habitat code and geometry only)')


# ---------------------------------------------------------------------------------------------
def step_hexagons():
    print('hexagons')
    gp = gpkg_path(out('data', '06_hexagons', 'hexagons_impacts.gpkg'))
    g = gpd.read_file(src('BGI_DP_Statistics/GN_hexagon_stat/hexagon_by_regions_gn_nor.shp'))
    h = gpd.read_file(src('hexagon_analysis_hotspots.shp'))
    land = gpd.read_file(src('BGI_DP_Statistics/GN_hexagon_stat/hexagon_regions_land.shp'))
    # land table: every hexagon is stored twice. The copy with id = 0 has the extent, GN_count/GN_met and the
    # percentage fields set to 0; counts, normalised values and region agree. Keep the complete copy (id > 0).
    land['key'] = land.geometry.centroid.x.round(1).astype(str) + '_' + land.geometry.centroid.y.round(1).astype(str)
    same = ['road_lengh', 'ab_count', 'imperv_cou', 'imperv_met', 'frag_gi_c', 'for_c_norm', 'ab_c_norm', 'imp_c_norm',
            'road_m_nor', 'frag_norm', 'cum_imp', 'for_count', 'forest_met', 'aband_met', 'cum_norm', 'county']
    grp = land.groupby('key')
    sizes = grp.size()
    agree = grp[same].nunique(dropna=False).max(axis=1).le(1)
    assert sizes.eq(2).all() and agree.all() and grp['id'].min().eq(0).all() and grp['id'].max().gt(0).all()
    print('  land table rows', len(land), '-> unique hexagons', len(sizes), '(two copies each; kept the copy with id > 0)')
    land = land.sort_values('id', ascending=False).drop_duplicates('key').drop(columns='key').sort_values('id')
    for df in (g, h, land):
        df.insert(1, 'region', df['county'].map(REGION))
        df.insert(2, 'x_centroid', df.geometry.centroid.x.round(1))
        df.insert(3, 'y_centroid', df.geometry.centroid.y.round(1))
        df.set_crs(EST97, allow_override=True, inplace=True)
    for name, df in [('gi_hexagons', g), ('hotspots', h), ('land_hexagons', land)]:
        pyogrio.write_dataframe(df, gp, layer=name, driver='GPKG')
        df.drop(columns='geometry').to_csv(out('tables', 'hexagons', name + '.csv'), index=False)
        print('  ', name, len(df))
    flush_gpkg()


# ---------------------------------------------------------------------------------------------
def step_tables():
    print('tables')
    # Table 4 source (landscapemetrics on the core rasters + element areas)
    t = pd.read_csv(src('BGI_DP_Statistics/bgi/landscape_statistics_fin.csv'), sep=';', encoding='utf-8-sig')
    t.columns = [c.strip() for c in t.columns]
    t = t.rename(columns={'PatchID': 'region', 'bgi_area_ha': 'gi_elements_area_ha', 'area$value': 'largest_core_patch_ha',
                          'area_mn_data': 'mean_core_patch_area_ha', 'pd_data': 'core_patch_density_per_100ha',
                          'lsi_data': 'landscape_shape_index', 'lpi_data': 'largest_patch_index_pct',
                          'total_region_area_ha': 'county_total_area_ha'})
    t.to_csv(out('tables', 'table4_landscape_metrics_by_county.csv'), index=False)
    print('  table4 rows', len(t), list(t.region))
    # Element areas by region and GI class (source of Figs 5 and 6)
    b = pd.read_csv(src('BGI_DP_Statistics/bgi/bgi_area_sums.csv'))
    b = b.rename(columns={'class': 'gi_class', 'infrastructure_type': 'element'})
    b['area_ha'] = (b.pop('area') / 1e4).round(2)
    b.to_csv(out('tables', 'gi_elements_area_by_region_class.csv'), index=False)
    # Annex I habitat types by element and region (source of Fig 7)
    rows = []
    for f in sorted(glob.glob(src('BGI_DP_Statistics/bgi/data/*_*.csv'))):
        region, element = os.path.basename(f)[:-4].rsplit('_', 1)
        d = pd.read_csv(f)
        d['area'] = pd.to_numeric(d['area'].astype(str).str.replace(',', '.'), errors='coerce')
        d = d[d['class'] == 'natura2000']
        for code, x in d.groupby(d['natura_cod'].fillna('none')):
            rows.append({'region': region.replace('Laane', 'Lääne').replace('Parnu', 'Pärnu'), 'element': element,
                         'annex1_code': code, 'n_polygons': len(x), 'area_ha': round(x['area'].sum() / 1e4, 2)})
    pd.DataFrame(rows).to_csv(out('tables', 'annex1_habitats_by_element_region.csv'), index=False)
    print('  annex1 rows', len(rows))
    # GI composition of the 3 km zone from the GI polygons (class and Annex I code)
    gp = gpd.read_file(src('Green_Infrastructure/green_network_3km.shp'), columns=['class', 'natura_cod'])
    gp['area_ha'] = gp.area / 1e4
    comp = gp.groupby(['class', gp['natura_cod'].fillna('')], dropna=False)['area_ha'].agg(['size', 'sum']).reset_index()
    comp.columns = ['gi_class', 'annex1_code', 'n_polygons', 'area_ha']
    comp['area_ha'] = comp['area_ha'].round(2)
    comp.to_csv(out('tables', 'gi_polygons_area_by_class_habitat.csv'), index=False)
    print('  GI polygon totals (ha):', gp.groupby('class')['area_ha'].sum().round(0).to_dict())
    # Table 3 as typed by the author (Apple Numbers file; needs the numbers-parser package)
    try:
        from numbers_parser import Document
        rows = Document(src('Habitats_EE_Coast.numbers')).sheets[0].tables[0].rows(values_only=True)
        t3 = [{'category': r[0].strip(), 'annex1_code': str(r[1]).replace('.0', ''), 'area_ha': r[2], 'pct_of_coastal_gi': r[3]}
              for r in rows[1:21]]
        t3 += [{'category': r[0].strip(), 'annex1_code': '', 'area_ha': r[1], 'pct_of_coastal_gi': r[3]} for r in rows[22:25]]
        t3 = pd.DataFrame(t3)
        t3['pct_of_coastal_gi'] = t3['pct_of_coastal_gi'].astype(float).round(2)
        t3.to_csv(out('tables', 'table3_habitat_types_author.csv'), index=False)
        print('  table3 rows', len(t3))
    except ImportError:
        print('  numbers-parser not installed: table3_habitat_types_author.csv not written')
    # GI share of the county coastal zone, as computed by the author
    shutil.copy2(os.path.join(AN, 'bgi_content', 'Calculated_Percentages.csv'),
                 out('tables', 'gi_class_share_by_county_author.csv'))


LSM_ORDER = ['Harju', 'Lääne', 'Hiiu', 'Ida-Viru', 'Lääne-Viru', 'Pärnu', 'Saare']


def step_lsm():
    """landscapemetrics results (R): patch level by element, landscape level, Table 4 summary.

    The patch-level workbooks hold one sheet per metric, rows in the same order in every sheet, the counties
    one after the other (patch ids restart at 1 for each county). Their 'Region' column is not consistent
    between sheets, so the county is assigned from the block order, which is the order of the
    landscape-level workbooks: Harju, Lääne, Hiiu, Ida-Viru, Lääne-Viru, Pärnu, Saare (patch counts per block
    equal the landscape-level 'np' of each county; checked below).
    """
    print('landscapemetrics', flush=True)
    units = {'area': 'area_ha', 'cai': 'cai_pct', 'circle': 'circle', 'contig': 'contig', 'core': 'core_ha',
             'enn': 'enn_m', 'frac': 'frac', 'gyrate': 'gyrate_m', 'ncore': 'ncore', 'para': 'para_m_per_m2',
             'perim': 'perim_m', 'shape': 'shape'}

    def region_col(df):
        if 'Region' in df.columns:                      # these sheets carry a row counter in 'county'
            df = df.drop(columns=[c for c in ['county'] if c in df.columns]).rename(columns={'Region': 'region'})
        return df.rename(columns={'county': 'region'})

    def patches(workbook):
        sheets = pd.read_excel(workbook, sheet_name=None)
        first = next(iter(sheets.values()))
        base = first[['class', 'id']].copy()
        for name, v in sheets.items():
            assert (v[['class', 'id']].values == base[['class', 'id']].values).all(), f'row order differs: {name}'
            base[units[v['metric'].iloc[0]]] = v['value'].values
        block = np.cumsum(np.r_[True, np.diff(base['id'].values) < 0])
        assert block.max() == len(LSM_ORDER), workbook
        base.insert(0, 'region', [LSM_ORDER[b - 1] for b in block])
        return base.rename(columns={'class': 'raster_value', 'id': 'patch_id'})

    d = lambda e: os.path.join(AN, f'LSM_{e}_data')
    landscape = {}
    for e in ['cores', 'branches', 'corridors', 'islets']:
        l = region_col(pd.read_excel(os.path.join(d(e), f'landscape_metrics_{e}.xlsx')))
        landscape[e] = l
        l.insert(0, 'workbook', e)
    np_by_region = lambda e: landscape[e][landscape[e]['metric'] == 'np'].set_index('region')['value'].astype(int)

    for e, name, keep in [('cores', 'patch_metrics_cores.csv', None),
                          ('branches', 'patch_metrics_mspa_classes.csv', None),
                          ('islets', 'patch_metrics_islets.csv', [9, 109])]:
        p = patches(os.path.join(d(e), f'{e}_patch_metrics.xlsx'))
        counts = p.groupby('region').size()
        assert (counts == np_by_region(e).reindex(counts.index)).all(), f'{e}: block sizes differ from np'
        if keep:
            p = p[p['raster_value'].isin(keep)]
        p.to_csv(out('tables', 'landscape_metrics', name), index=False)
        print('  ', name, len(p), 'patches; block sizes = landscape-level np for all counties', flush=True)
    # the corridors workbook repeats the branches workbook except for Harju (its raster lacked class 1)
    c = patches(os.path.join(d('corridors'), 'corridors_patch_metrics.xlsx'))
    b = pd.read_csv(out('tables', 'landscape_metrics', 'patch_metrics_mspa_classes.csv'))
    same = all(c[c.region == r].drop(columns='region').reset_index(drop=True).round(6).equals(
        b[b.region == r].drop(columns='region').reset_index(drop=True).round(6)) for r in LSM_ORDER if r != 'Harju')
    print('   corridors workbook equals branches workbook outside Harju:', same)
    pd.concat(landscape.values()).to_csv(out('tables', 'landscape_metrics', 'landscape_level_metrics.csv'), index=False)
    sp = pd.read_excel(os.path.join(d('cores'), 'cores_spec_metrics.xlsx'))
    sp.to_csv(out('tables', 'landscape_metrics', 'core_metrics_by_county_table4.csv'), index=False)


# ---------------------------------------------------------------------------------------------
SECRET = re.compile(r'(sk-[A-Za-z0-9_-]{16,}|api[_-]?key|Sys\.setenv|secret|token\s*=|password|Bearer\s)', re.I)


def step_code():
    print('original code')
    files = []
    for f in sorted(glob.glob(os.path.join(AN, '*.R'))):
        files.append((f, os.path.join('analysis_R', os.path.basename(f))))
    for sub in ['GN_hexagon_stat', 'bgi_content']:
        for f in sorted(glob.glob(os.path.join(AN, sub, '*.R'))):
            files.append((f, os.path.join('analysis_R', sub, os.path.basename(f))))
    for f in sorted(glob.glob(src('BGI_DP_Statistics/bgi/*.py')) + glob.glob(src('BGI_DP_Statistics/bgi/*.r'))):
        files.append((f, os.path.join('bgi_statistics', os.path.basename(f))))
    files.append((src('BGI_DP_Statistics/LSM.R'), os.path.join('bgi_statistics', 'LSM.R')))
    files.append((os.path.join(os.path.dirname(AN), 'qgis_api_example.py'), os.path.join('qgis', 'normalise_in_qgis.py')))
    for f, rel in files:
        txt = open(f, encoding='utf-8', errors='replace').read()
        hit = SECRET.search(txt)
        assert hit is None, f'possible secret in {f}: {hit.group(0)}'
        txt = re.sub(r'/Users/[^/]+/', '~/', txt)
        p = out('code', 'original', rel)
        with open(p, 'w', encoding='utf-8') as o:
            o.write(txt)
    print('  copied', len(files), 'scripts; secret scan clean; home paths replaced by ~/')


STEPS = {'mspa': step_mspa, 'gi': step_gi, 'giclass': step_giclass, 'pressures': step_pressures, 'vectors': step_vectors, 'hexagons': step_hexagons, 'tables': step_tables,
         'lsm': step_lsm, 'code': step_code}
if __name__ == '__main__':
    for a in sys.argv[1:] or STEPS:
        STEPS[a]()
    shutil.rmtree(TMP, ignore_errors=True)
