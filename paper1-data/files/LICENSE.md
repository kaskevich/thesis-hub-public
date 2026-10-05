# Licences

## Data

The data in `data/`, `tables/`, `results/` and `docs/` are licensed under the Creative Commons
Attribution-ShareAlike 4.0 International licence (CC BY-SA 4.0):
https://creativecommons.org/licenses/by-sa/4.0/legalcode

Share-alike is used because the GI layer includes permanent-grassland data of the Agricultural Registers
and Information Board (PRIA), published under CC BY-SA 3.0, whose adaptations may be licensed under a later
version of the same licence.

Attribution: Kaskevich, V. (2026). Green Infrastructure, MSPA elements and pressures in the 3 km coastal zone
of Estonia: data and code for Kaskevich et al. (2024), version 1.0. Please also cite the article (see
`CITATION.cff`).

## Code

The scripts in `code/` are licensed under the MIT licence.

    MIT License

    Copyright (c) 2022-2026 Volha Kaskevich

    Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
    associated documentation files (the "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the
    following conditions:

    The above copyright notice and this permission notice shall be included in all copies or substantial
    portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
    LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO
    EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
    IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
    USE OR OTHER DEALINGS IN THE SOFTWARE.

## Third-party sources

The released layers are derived from the following sources. Their terms apply to the source data and
require the attributions below. Raw source data are not redistributed; `docs/provenance_and_licences.csv`
gives the layer-by-layer detail.

| Source | Used for | Terms | Attribution |
|---|---|---|---|
| Estonian Land Board: coastline, administrative units, Estonian Topographic Database (ETAK) | coastal zone, regions, roads, forest polygons | Estonian Land Board open data licence, https://geoportaal.maaamet.ee/opendata-licence | Contains data of the Estonian Land Board (coastline and administrative units; Estonian Topographic Database, extract of 6 November 2021) |
| Copernicus Land Monitoring Service: High Resolution Layers Tree Cover Density and Imperviousness | forest loss, imperviousness increase | full, free and open; attribution and statement of modification required, https://land.copernicus.eu/en/data-policy | Contains modified Copernicus Land Monitoring Service information; European Union, Copernicus Land Monitoring Service, European Environment Agency (EEA). The layers were reclassified and cropped by the author |
| Agricultural Registers and Information Board (PRIA): permanent grasslands, managed semi-natural habitats | GI layer; grassland abandonment | CC BY-SA 3.0 | Contains data of the Agricultural Registers and Information Board (PRIA) |
| Natura 2000 habitat data (article Table 1: European Environment Agency; attribute schema of the Estonian Environmental Register habitat inventory) | GI layer (Natura 2000 class) | per provider | see `docs/provenance_and_licences.csv` |

No endorsement by the data providers or the European Union is implied.
