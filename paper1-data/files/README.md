# Green Infrastructure, MSPA elements and pressures in the 3 km coastal zone of Estonia

**Data and code for:** Kaskevich, V., Villoslada, M., Ward, R.D., Sepp, K. (2024). Analyzing the structural
elements, ecological characteristics, and impact assessment of local green infrastructure in the coastal zone
of Estonia. *Ecological Indicators* 169, 112824. https://doi.org/10.1016/j.ecolind.2024.112824

Version 1.0 · 5 October 2026 · Volha Kaskevich, Institute of Agriculture and Environmental Sciences,
Estonian University of Life Sciences · volha.kaskevich@emu.ee

The article states that data are available on request. This package releases the layers and tables behind its
figures and tables, the original analysis scripts, scripts that recompute the results from the released files,
and a line-by-line comparison of 165 published numbers with the data.

## Contents

| Path | Content | Article |
|---|---|---|
| `data/01_coastal_zone/coastal_zone_3km.gpkg` | `coastal_zone_3km`: land within 3 km of the coastline (415,521 ha); `regions_3km`: the seven coastal counties and the Tallinn area; `coastline_buffer_3km`: the 3 km buffer on both sides of the coastline | Figs 1, 3 |
| `data/02_green_infrastructure/gi_binary_20m.tif` | GI raster used as MSPA input (1 = GI), seven counties, 20 m | Section 2.2.2 |
| `data/02_green_infrastructure/gi_class_20m.tif` | GI class at 20 m in the 3 km zone: forest, permanent grassland, Natura 2000 habitat | Fig. 3, Table 3 |
| `data/03_mspa/mspa_coastal_3km_20m.tif` | MSPA classes (GuidosToolbox byte codes) of the 3 km zone | Fig. 4 |
| `data/05_pressures/forest_loss_2012_2018_20m.tif` | Tree cover loss 2012–2018 (Copernicus-derived) | Table 5, Figs 8–9 |
| `data/05_pressures/imperviousness_increase_2006_2018_20m.tif` | Imperviousness increase 2006–2018 (Copernicus-derived) | Table 5, Figs 8–9 |
| `data/05_pressures/roads_in_gi.gpkg` | Roads crossing GI (Estonian Topographic Database) | Table 5, Figs 8–9 |
| `data/06_hexagons/hexagons_impacts.gpkg` | 500 m hexagons: `gi_hexagons` (19,741, indicators and cumulative impact), `hotspots` (19,688, local G and impact class), `land_hexagons` (20,413, county totals) | Table 5, Figs 3, 8–10 |
| `tables/` | Author tables: Table 3 and 4 sources, element areas by county and GI class (Figs 5–6), Annex I habitats by element (Fig. 7), landscape metrics at patch and landscape level, the hexagon attributes as CSV | Tables 3–4, Figs 5–7 |
| `results/` | Recomputation from the released files (output of `code/reproduce`) | all |
| `code/original/` | The R and Python scripts used for the article (paths shortened to `~/`) | |
| `code/reproduce/` | Python scripts that recompute the results from this package | |
| `code/build/` | Script that built this package from the author's working data | |
| `docs/` | Data dictionary, MSPA codes, methods and parameters, provenance and licences, comparison with the article, file manifest | |

All layers are in L-EST97 (EPSG:3301) except the two Copernicus-derived rasters, which keep their original
ETRS89-LAEA grid (EPSG:3035) so that no resampling was needed. Rasters are Cloud Optimized GeoTIFFs (DEFLATE)
with internal overviews; vectors are GeoPackages. Field definitions: `docs/data_dictionary.csv`. Checksums:
`SHA256SUMS.txt`.

## Key definitions

- **GI** (MSPA foreground): forest and Natura 2000 habitat polygons, rasterised at 20 m. The permanent-grassland
  polygons of the GI layer are not part of the MSPA input (see the comparison document).
- **MSPA**: GuidosToolbox 2.5, 8-neighbour foreground connectivity, EdgeWidth 12 cells (240 m), run per county and
  clipped to the 3 km zone. **Cores** = MSPA classes 3, 17, 35, 67 (core with its edge); **corridors** = bridges (33);
  **branches** = 1, 101; **islets** = 9, 109. Full code list: `docs/mspa_codes.csv`.
- **Hexagon indicators** (`gi_hexagons`): shares of the GI area of each hexagon for forest loss, grassland
  abandonment, imperviousness increase and GI fragmentation (branch and islet cells), road length per GI area;
  each min–max normalised over the 19,741 GI hexagons; their sum, normalised again, is the cumulative impact
  (`cum_norm`).
- **Hot spots**: Getis–Ord local G of `cum_norm`, queen contiguity, binary weights, focal hexagon excluded;
  impact classes from two-sided p-values (0.01, 0.05, 0.10).

Details and evidence for every parameter: `docs/methods_parameters.md`.

## Reproducing the results

Python 3.10+ with numpy, pandas, scipy, geopandas, pyogrio, shapely 2 and rasterio:

    cd code/reproduce
    python3 r1_gi_and_mspa.py          # MSPA and GI areas, core-patch metrics (Table 4), MSPA input vs output
    python3 r2_hexagon_indicators.py   # per-hexagon counts from the rasters and roads
    python3 r3_statistics.py           # derived fields, Kruskal-Wallis and Dunn, hot spots, county totals
    python3 r4_reconcile.py            # compare with the published numbers -> docs/reconciliation_with_article.csv

Each script takes under a minute and about 2 GB of memory. Outputs go to `results/`.

## What the recomputation shows

- Recomputed from the released MSPA raster, the core-patch metrics give all values of Table 4 for the eight
  regions (largest patch, mean patch area, patch density, LSI, LPI).
- Local G and the impact class of all 19,688 hexagons in `hotspots` are reproduced exactly, as are the global G
  (5.39 × 10⁻⁴) and its standard deviate (103.25).
- Per-hexagon counts recomputed from the rasters equal the stored values for 99.8 % (tree cover loss),
  99.99 % (imperviousness) and 100 % (road length, within 1 m) of hexagons; GI fragmentation agrees for 91 %
  (r = 0.9998). The GI cell count agrees for 52 % (r = 0.998): the stored values come from a slightly
  different version of the GI raster.
- County totals of forest loss, grassland abandonment and GI fragmentation reproduce Table 5 except one row.

Some published numbers differ from the data, and a few method statements differ from the files: the MSPA edge
width (240 m, not 200 m), the hot-spot statistic (Gi, not Gi\*), the Table 4 area column (whole counties, not the
3 km zone), several numbers in the text that differ from Fig. 5, and Table 3, which has no calculation trail.
The full list, with the evidence for each item: `docs/reconciliation_with_article.md` and
`docs/reconciliation_with_article.csv`.

## Layers released separately

Three layers carry habitat-inventory attributes per polygon: the GI polygons with Annex I codes, the MSPA
elements as polygons with Annex I codes, and the abandoned semi-natural grassland polygons (and their 20 m
raster). They will be added once the redistribution terms of the habitat inventory are confirmed. Their
aggregates are already in `tables/`, and the hexagon attributes derived from them are in
`data/06_hexagons`.

## Licence and attribution

Data: [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/). Code: MIT. Third-party sources and
the attribution they require are listed in `LICENSE.md` and `docs/provenance_and_licences.csv`. Contains data of
the Estonian Land Board (coastline, administrative units, Estonian Topographic Database) used under the
Estonian Land Board open data licence; contains modified Copernicus Land Monitoring Service information
(European Union, Copernicus Land Monitoring Service, European Environment Agency); contains data of the
Agricultural Registers and Information Board (PRIA).

## Citation

Please cite the article and this dataset (`CITATION.cff`).
