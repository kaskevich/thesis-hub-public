# Methods and parameters

How each released layer was made, with the parameter values and the evidence for them in the working
data. Section numbers refer to the article (Kaskevich et al. 2024, *Ecological Indicators* 169, 112824).
Where the article and the files differ, both are given; `reconciliation_with_article.md` lists all
differences.

## 1. Coastal zone (section 2.1)

- `coastline_buffer_3km`: the author's 3 km buffer of the Estonian coastline, on both sides of the line
  (1,046,171 ha, 12 polygons), following HELCOM Recommendation 15/1 as cited in the article.
- `regions_3km`: the land part of the buffer split by county (seven counties, 415,521 ha) plus the
  Tallinn area (19,399 ha), which the article analyses separately. The Harju polygon includes the Tallinn
  area (overlap 19,386 ha). In the hexagon layers each hexagon belongs to one region, and Harju excludes
  the Tallinn area hexagons.
- `county_area_attr_ha` is the area attribute of the source polygons: the whole-county area for the seven
  counties. These are the values printed in the Table 4 column "3 km Coastline Total Area".
- `coastal_zone_3km`: union of the seven county polygons.

## 2. Green Infrastructure layer (section 2.2.1)

- GI polygons of the 3 km zone: 64,740 polygons in three classes: forest (168,370 ha), Natura 2000 habitat
  (121,782 ha) and permanent grassland (29,689 ha). The article describes the merge priority as semi-natural
  grasslands, Natura 2000 habitats, permanent meadows, forests; in the released polygons the classes do not
  overlap (one 20 m cell is covered by two classes).
- MSPA input: one GI raster per county, 20 m, value 1 = GI (files dated May 2022), covering whole counties.
  `gi_binary_20m.tif` is their union on the MSPA pixel grid.
- Inside the 3 km zone the MSPA input equals the MSPA foreground exactly (287,208 ha; no cell differs).
  It contains all forest cells and 97.6 % of the Natura 2000 cells of `gi_class_20m.tif`, and none of the
  permanent-grassland cells.

## 3. Morphological Spatial Pattern Analysis (section 2.2.2)

| Parameter | Value | Evidence |
|---|---|---|
| Software | GuidosToolbox 2.5 | article |
| Foreground connectivity | 8 | file names `*_8_12_0_1*` |
| EdgeWidth | 12 cells = 240 m at 20 m | file names; in the released rasters all 1,333,324 core cells (class 17) lie at least 13 cells from the nearest non-GI cell. The article states 200 m (10 cells) |
| Transition | file names give 0 | the output contains bridge-in-edge (35) and loop-in-edge (67) cells, which GuidosToolbox writes when transition pixels are shown; the setting cannot be confirmed from the files |
| Intext | 1 | internal classes (+100) and the opening classes 100 and 220 are present |
| Processing unit | county (whole county raster), then clipped to the 3 km zone and mosaicked | `MSPA 200m edge/*_8_12_0_1.tif`, `MSPA_rasters_3km/*_coast.tif` |

GI elements as used in the article, from the classes present in the author's element rasters:

| Element | MSPA codes | Area in the 3 km zone (ha) |
|---|---|---|
| Cores | 3, 17, 35, 67 (core with its edge and the transition cells of the edge) | 150,058 |
| Corridors | 33 (bridge) | 111,317 |
| Branches | 1, 101 | 6,723 |
| Islets | 9, 109 | 13,485 |
| Other foreground | 65, 105, 133, 137, 165, 169 | 5,625 |

Areas from `results/mspa_class_area_by_region.csv`.

## 4. Landscape metrics (section 2.2.2, Table 4)

- R package landscapemetrics on the county core rasters (cores = 1, everything else NA), 8-neighbour rule,
  landscape level: largest patch index (LPI), mean patch area, patch density (per 100 ha, which equals per km²)
  and landscape shape index (LSI). Because all non-core cells are NA, the "landscape" is the core area:
  LPI = largest core patch / total core area.
- `r1_gi_and_mspa.py` recomputes these metrics from the released MSPA raster for the eight regions and
  obtains the Table 4 values.
- Patch-level metrics (area, core area, CAI, circle, contiguity, ENN, fractal dimension, gyration, number of
  core areas, perimeter, perimeter–area ratio, shape) are released for the core patches, for every MSPA class
  per county and for the islets (`tables/landscape_metrics/`).
- The patch-level workbooks list the counties one after the other, but their region column is not consistent
  between sheets. In the released tables the county is assigned from the order of the blocks (patch ids
  restart at 1 for each county). That order is the one in the landscape-level workbooks: Harju, Lääne, Hiiu,
  Ida-Viru, Lääne-Viru, Pärnu, Saare. For all four workbooks the block sizes equal the landscape-level patch
  counts. As a further check, the class areas of each block equal the MSPA class areas of that county in the
  released raster.

## 5. Pressure layers (section 2.2.3, Table 2)

| Indicator | Released layer | Source and processing |
|---|---|---|
| Forest cover loss | `forest_loss_2012_2018_20m.tif` | Copernicus HRL Tree Cover Density 2012 and 2018, reclassified by the author to loss (1) / no loss (0); article: 30 % threshold. Kept on its EPSG:3035 grid, cropped to the 3 km zone + 600 m |
| Imperviousness increase | `imperviousness_increase_2006_2018_20m.tif` | derived by the author from the Copernicus HRL Imperviousness products (the working data hold the change layers 2006–2009 to 2015–2018 and the status layers 2006–2018): positive change 2006–2018 (1) / none (0); EPSG:3035 grid |
| Grassland abandonment | released separately | semi-natural habitat inventory polygons with no management support in the PRIA managed-habitat layers; the working data hold layers for 2007–2015 and 2018 (the article gives 2007–2020); rasterised at 20 m |
| Roads | `roads_in_gi.gpkg` | Estonian Topographic Database road features (extract of 6 November 2021) intersected with the GI polygons; 6,761 segments, 2,114 km. Road types: traffic area 5,739, not filled 718, parking 132, other 94, sport 46, pedestrian area 31, bus station 1 |
| GI fragmentation | from the MSPA raster | branch and islet cells (codes 1, 9, 101, 109) |

## 6. Hexagon indicators (section 2.2.3)

- Grid: QGIS hexagonal grid, cells 500 m across flats (577 m across corners), 21.65 ha each.
- `gi_hexagons` (19,741): hexagons with GI. This is the set used for the Kruskal–Wallis and Dunn tests
  (Fig. 9) and for the hot-spot analysis (Fig. 10).
- `land_hexagons` (20,413): in the author's file each hexagon is stored twice, and one copy has the bounding
  box, the GI count and the percentage fields set to 0. Counts, normalised values and region agree between the
  two copies, and the complete copy is released. Sums over this set give Table 5, except the imperviousness
  column, which equals the sum over `gi_hexagons`.
- Counts: number of 20 m cells whose centre lies inside the hexagon (QGIS zonal statistics); `*_met` = count ×
  400 m²; percentages are of the GI area of the hexagon (`GN_met`), capped at 100.
- Normalisation (min–max to 0–1):
  - in `gi_hexagons`, the shares of GI area (`perc_for`, `aband_perc`, `imperv_per`, `frag_gi_pr`) and the road
    length per GI area (`road_frac`);
  - in `land_hexagons`, the raw counts and the road length.
- `cum_imp` is the sum of the five normalised indicators; `cum_norm` is `cum_imp` normalised again.
- `r3_statistics.py` checks every derivation; all agree with the stored values within the stored rounding
  (`results/indicator_derivation_check.csv`).
- `r2_hexagon_indicators.py` recomputes the counts from the released rasters
  (`results/hexagon_counts_check_*.csv`): tree cover loss 99.8 %, imperviousness 99.99 %, abandonment 99.8 % (with the
  separately released raster) and road length 100 % identical; GI fragmentation 91 % identical (r = 0.9998); GI count 52 % identical
  (r = 0.998, totals 0.9 % apart). The stored GI count comes from a slightly different version of the GI raster.

## 7. Statistics (sections 2.2.3, 4.3)

- Kruskal–Wallis test (rstatix) and Dunn's test with Bonferroni adjustment (`dunnTest`, package FSA, loaded
  together with dunn.test in the scripts) of each normalised indicator by region, over the 19,741 GI
  hexagons, 8 groups. The results are in `results/kruskal_wallis.csv` and `results/dunn_pairwise.csv`;
  z = mean rank of the first region minus that of the second, in alphabetical order.
- Hot spots (R packages spdep and sf):
  - queen contiguity (`poly2nb`);
  - the 53 GI hexagons without neighbours removed;
  - binary weights (`nb2listw`, style B);
  - `localG` of `cum_norm` without `include.self`, so the statistic is Gi (focal hexagon excluded), not Gi\*;
  - two-sided normal p-values;
  - classes: Very High / High / Moderate for G > 0 and p ≤ 0.01 / 0.05 / 0.10, the corresponding Low classes
    for G < 0, Neutral otherwise.
- Global G: `globalG.test`, binary weights.
- `r3_statistics.py` reproduces local G for all 19,688 hexagons (maximum difference 4 × 10⁻¹⁵) and the stored
  impact class of every hexagon.
