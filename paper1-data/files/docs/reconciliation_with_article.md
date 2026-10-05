# Comparison with the published article

Every number in the article that the data can be checked against (165 values from Tables 3–5, Figs 5, 6,
7 and 9 and the text) was typed into `article_values.csv`. `code/reproduce/r4_reconcile.py` then compared
each one with the value from the released files. The result for every value, with its source and a note,
is in `reconciliation_with_article.csv`.

A value **matches** when it lies within one unit of the last published digit. Otherwise the CSV gives the
relative difference class: within 1 %, within 5 %, differs, or not reproduced.

## 1. Reproduced

| Article item | Result |
|---|---|
| Table 4, all landscape metrics (8 regions × 5 metrics) | all 40 match, recomputed from the released MSPA raster |
| Table 4, county area (7 counties) | all match the whole-county area attribute (see 3.3) |
| Table 5, forest cover loss and grassland abandonment (8 regions) | all 16 match (sums over `land_hexagons`) |
| Table 5, GI fragmentation | 7 of 8 match (see 2.3) |
| Table 5, impervious surfaces | 7 of 8 match the sums over `gi_hexagons` (see 2.3) |
| Fig. 5, element areas by GI class | 7 of 9 match (see 2.1) |
| Section 4.1, county element areas (14 values) | all match |
| Fig. 9B, Dunn z of the cumulative impact (four pairs read from the figure) | all match |
| Section 4.3, Dunn z of grassland abandonment, Saare vs Tallinn area (14.99) | matches |
| Section 4.3.1, global G (5.39 × 10⁻⁴) and its standard deviate (103.25) | match |
| Fig. 10, hot-spot classes | all 19,688 hexagons reproduced (local G and class) |

## 2. Published numbers that differ from the data

### 2.1 Element areas: text and Fig. 5

| Item | Article | Data | Note |
|---|---|---|---|
| Forest cores, text (sections 4.1, 5.1) | 81,254 ha | 81,444 ha | Fig. 5 gives 81,444 |
| Natura 2000 cores, text (sections 4.1, 5.1) | 58,447 ha | 68,147 ha | Fig. 5 gives 68,147 |
| Forest corridors, text (section 5.1) | 58,920 ha | 68,521 ha | Fig. 5 gives 68,521 |
| Natura 2000 corridors, text (section 5.1) | 31,767 ha | 39,208 ha | Fig. 5 gives 39,208 |
| Permanent-meadow corridors, Fig. 5 | 102 ha | 207 ha | element polygons |
| Natura 2000 branches, Fig. 5 and section 4.1 | 2,041 ha | 3,451 ha | element polygons; the MSPA × GI class rasters give 3,585 ha |
| Total GI, section 4.1 and Fig. 3 | 283,269 ha | 287,208 ha | MSPA foreground in the 3 km zone. GI polygons: 319,840 ha; cores + corridors + branches: 263,874 ha |

### 2.2 Annex I habitat types in the elements (section 4.1, Fig. 7)

These text values were compared with the Natura 2000 element polygons, using the first Annex I code of each
polygon (`tables/annex1_habitats_by_element_region.csv`).

| Item | Article | Data |
|---|---|---|
| 9010 in cores | 11,700 ha | 16,287 ha |
| 9010 in cores, Saare | 5,000 ha | 5,347 ha |
| 9010 in corridors | 3,810 ha | 3,775 ha |
| 9010 in branches | 68 ha | 72 ha |
| 1630 in cores | 8,600 ha (section 5.1: 8,500) | 7,968 ha |
| 1630 in corridors and branches | 10,390 ha | 10,871 ha |

The figures given for 6280 in Saare (4,000 ha) and Hiiu (800 ha) are close to the core values (4,086 and
823 ha). The 2180 figure for Harju, Hiiu and Pärnu (3,600 ha) is close to the value over all elements
(3,555 ha).

### 2.3 Table 5

- **Tallinn area row:** the GI fragmentation (550.6 ha) and impervious surfaces (4.3 ha) repeat the
  Lääne-Viru row. The data give 1,224.6 ha and 5.4 ha.
- **Impervious surfaces:** this column equals the sums over the GI hexagons. The other columns equal the
  sums over all land hexagons.
- **Road density:** none of the tested definitions gives the published values (0.0004–0.3325 km/km²), and the
  values span three orders of magnitude between counties. The data give 0.47–2.25 km of road per km² of GI
  and 0.33–0.84 km per km² of hexagon area. Road length per county is in `results/pressures_by_region.csv`.

### 2.4 Statistics

- **Section 4.3, "Z-score of −19.94" for GI fragmentation between Ida-Viru and Tallinn:** the recomputed test
  for GI fragmentation gives z = −0.24 for that pair. A z of −19.94 occurs only for road density, Saare vs
  Tallinn area.
- **Global G:** the expectation is 2.67 × 10⁻⁴ (published 2.76 × 10⁻⁴) and the variance 6.95 × 10⁻¹²
  (published 6.95 × 10⁻⁹). The global G and the standard deviate match. The value of 103.25 is the
  standard deviate (z), which the article calls the standard deviation.

### 2.5 Share of GI by county (section 4.1)

The text gives the share of each county's "coastal area designated as GI": Hiiu 41.1 %, Saare 32.4 %,
Lääne 19.5 %, Harju 9.2 %, Pärnu 7.7 %, Lääne-Viru 5.5 % and Ida-Viru 2.9 %. These approximate the MSPA
foreground divided by the **whole-county** area, which gives 41.3, 32.4, 19.6, 10.7 (9.0 without the Tallinn
area), 7.4, 5.3 and 2.7 %. As shares of the 3 km zone the values are 38.5–77.6 %.

### 2.6 Table 3

Table 3 repeats a table typed by the author (`Habitats_EE_Coast.numbers`, released as
`tables/table3_habitat_types_author.csv`). The working data hold no calculation that produces it. The GI
polygons give the following totals:

| Item | Table 3 | GI polygons |
|---|---|---|
| Forest | 143,010 ha | 168,370 ha |
| Permanent grassland | 164 ha | 29,689 ha |
| Annex I habitats | 86,996 ha | 121,782 ha |

The habitat-type values differ from the GI polygons by 2–451 %. Table 3 is therefore marked "differs"
throughout. Polygon totals by class and Annex I code are in `tables/gi_polygons_area_by_class_habitat.csv`.

## 3. Method statements that differ from the files

1. **MSPA edge width.** The article states 200 m. The files use EdgeWidth 12 cells = 240 m: the parameter
   string is `_8_12_0_1`, and all 1,333,324 core cells (class 17) lie at least 13 cells from the nearest non-GI cell.
2. **Hot-spot statistic.** The article names Gi\* and gives the Gi\* formula. The scripts call
   `spdep::localG` without `include.self`, which is Gi (the focal hexagon excluded). Recomputing with Gi
   reproduces every stored value. Neighbours are queen contiguity with binary weights, and the 53 GI hexagons
   without neighbours are excluded. Neither point is stated in the article.
3. **Table 4.**
   - The column "3 km Coastline Total Area" holds whole-county areas, for example Harju 432,672 ha. Harju's
     land within 3 km of the coast is 71,377 ha.
   - The Tallinn area value (36,238 ha) does not match its polygon (19,399 ha).
   - The metrics describe the core patches (MSPA classes 3, 17, 35, 67), not all GI.
   - The caption expands LSI as "Largest Shape Index"; the methods define the Landscape Shape Index.
4. **Permanent grasslands.** The article lists permanent meadows as a GI component. None of the 29,691 ha of
   permanent-grassland polygons in the 3 km zone is in the MSPA input. The permanent-meadow element areas
   (16, 207 and 45 ha in the element polygons) come from the element polygons' class attribute.
5. **Hexagon aggregation.** The article says raster indicators were averaged per hexagon and road lengths
   summed.
   - In the GI hexagon set (Figs 9–10), each raster indicator is a cell count expressed as a share of the
     hexagon's GI area. This equals the mean of the binary raster over the GI area.
   - Roads enter as road length per GI area.
   - The land hexagon set normalises raw counts and road length.
6. **Time periods.**
   - Forest loss: the raster covers 2012–2018, as in Table 2. The methods text says 2006–2018.
   - Abandonment: the working data hold PRIA managed-habitat layers for 2007–2015 and 2018. The article
     gives 2007–2020.
7. **Software.** "R (version 2023.09.1 + 494)" is an RStudio version string. Dunn's test was run with
   `dunnTest` from the FSA package; the article cites dunn.test.
8. **Grid.** The hexagons are 500 m across flats (577 m across corners) and 21.65 ha each. The article
   describes them as "500 m-diameter".

## 4. Not reproduced

- Table 5 road density (8 values), see 2.3.
- Table 3, see 2.6. The values are reported as differing rather than not reproduced, because the GI polygons
  provide an alternative.
