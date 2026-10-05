# Code

## `reproduce/`: recompute the results from this package

Python 3.10+ with numpy, pandas, scipy, geopandas, pyogrio, shapely 2 and rasterio. Run from this folder in
the order below. Outputs go to `../../results/` (change it with `RESULTS_DIR`).

| Script | Recomputes | Article |
|---|---|---|
| `r1_gi_and_mspa.py` | MSPA class and element areas by region; GI element × GI class; GI share by region; core-patch metrics; MSPA input against output | Table 4, Figs 4–6, section 4.1 |
| `r2_hexagon_indicators.py` | per-hexagon cell counts and road length from the rasters and the road layer | Figs 8–10 |
| `r3_statistics.py` | derived hexagon fields and normalisation; Kruskal–Wallis and Dunn; local and global G; impact classes; county totals | Table 5, Figs 9–10, section 4.3 |
| `r4_reconcile.py` | comparison of the 165 values in `docs/article_values.csv` with the data | all |
| `common.py` | paths and shared functions (zonal counts, Dunn's test, local and global G) | |

If the separately released layers are available, set `PENDING_DIR` to their folder: `r2` then also checks the
grassland abandonment counts.

## `original/`: the scripts used for the article

The author's scripts as they were run. The only change is that home-folder paths are shortened to
`~/Desktop/...`. They read the author's working folders (`BGI_DP`, `ThirtyFourtyDocker`), which are not part
of this package; the released layers and tables correspond to the files they read as listed in
`docs/provenance_and_licences.csv`.

| Script | Purpose | Used for |
|---|---|---|
| `bgi_statistics/LSM.R` | landscapemetrics on the county core rasters (LPI, mean patch area, patch density, LSI, largest patch) | Table 4 |
| `bgi_statistics/rearrange_tables.py`, `rearrange_tables.r` | collect the element attribute tables by county | Figs 5–7 |
| `bgi_statistics/bgi_area_sums.py` | element areas by county and GI class | Figs 5–6 |
| `bgi_statistics/landscape_statistics.py`, `landscape_statistics_plots.py` | assemble and plot Table 4 | Table 4 |
| `analysis_R/LS_Metrics_results.R`, `LS_patch_corridors.R`, `LS_patch_branches.R`, `LS_patch_islets.R` | landscape and patch metrics by element | `tables/landscape_metrics/` |
| `analysis_R/LM_Plots.R` | landscape metric plots | |
| `analysis_R/BGI_content.R`, `analysis_R/bgi_content/*.R` | GI composition and Annex I habitat graphs | Figs 5–7 |
| `analysis_R/Impacts_Kruskal-Wallis.R` | Kruskal–Wallis and Dunn tests of the six indicators by region | Fig. 9 |
| `analysis_R/Hotspot_Cum_impact.R` | local and global G, impact classes, hot-spot maps | Fig. 10, section 4.3.1 |
| `analysis_R/GN_hexagon_stat/Hotspotanalysis_impacts.R` | earlier hot-spot version (classes at ±1.96) | not reported |
| `analysis_R/GN_hexagon_stat/*_plotting.R`, `Combined_plots_impacts.R`, `Roads.R`, `Table_impacts_sum.R` | indicator plots and county sums | Figs 8–9, Table 5 |
| `analysis_R/Paper1_graphs.R` | figure drafts | |
| `qgis/normalise_in_qgis.py` | min–max normalisation of a hexagon field in the QGIS Python console | hexagon indicators |
| `analysis_R/1.R`, `Annova.R`, `Annova_ls_patch_metrics.R`, `R_plots_impacts_tuckey.R`, `GN_hexagon_stat/Impacts_Annova.R`, `GN_hexagon_stat/Annova_Tuckey_Impacts_plots.R` | exploratory one-way ANOVA and Tukey tests | not reported in the article. `1.R` reads the land-hexagon workbook, in which every hexagon appears twice (see `docs/methods_parameters.md`, section 6) |

## `build/`: how this package was made

`build_from_raw.py` builds every released layer and table from the author's working data:

    PAPER1_DIR=~/Desktop/BGI_DP ANALYSIS_DIR=~/Desktop/ThirtyFourtyDocker/ls_metrics_allstat \
    python3 build_from_raw.py mspa gi giclass pressures vectors hexagons tables lsm code

`make_manifest.py` writes `docs/file_manifest.csv` and `SHA256SUMS.txt`.
