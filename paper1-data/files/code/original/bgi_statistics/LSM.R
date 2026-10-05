install.packages("rgdal", type="source")
install.packages("landscapemetrics")

library(landscapemetrics)
library(raster)
setwd("~/Desktop/BGI_DP/BGI_DP_Statistics")
        
harju<-raster("~/Desktop/BGI_DP/Cores/Harju_cores.tif")

harju_metrics<-calculate_lsm(harju, level="landscape")

lsm_l_lpi(harju, directions = 8)
lsm_l_area_mn(harju, directions = 8)
lsm_l_pd(harju, directions = 8)
lsm_l_lsi(harju)
area <-lsm_p_area(harju, directions = 8)
area
max(area$value)


tallinn<-raster("~/Desktop/BGI_DP/Cores/Tallinn_cores.tif")

tallinn_metrics<-calculate_lsm(tallinn, level="landscape")
lsm_l_lpi(tallinn, directions = 8)
lsm_l_area_mn(tallinn, directions = 8)
lsm_l_pd(tallinn, directions = 8)
lsm_l_lsi(tallinn)
area <-lsm_p_area(tallinn, directions = 8)
area
max(area$value)


laane<-raster("~/Desktop/BGI_DP/Cores/Laane_cores.tif")

laane_metrics<-calculate_lsm(harju, level="landscape")
lsm_l_lpi(laane, directions = 8)
lsm_l_area_mn(laane, directions = 8)
lsm_l_pd(laane, directions = 8)
lsm_l_lsi(laane)


hiiu<-raster("~/Desktop/BGI_DP/Cores/Hiiu_cores.tif")

hiiu_metrics<-calculate_lsm(hiiu, level="landscape")
lsm_l_lpi(hiiu, directions = 8)
lsm_l_area_mn(hiiu, directions = 8)
lsm_l_pd(hiiu, directions = 8)
lsm_l_lsi(hiiu)
area <-lsm_p_area(hiiu, directions = 8)
area
max(area$value)


idaviru<-raster("~/Desktop/BGI_DP/Cores/Ida-Viru_cores.tif")

idaviru_metrics<-calculate_lsm(idaviru, level="landscape")
lsm_l_lpi(idaviru, directions = 8)
lsm_l_area_mn(idaviru, directions = 8)
lsm_l_pd(idaviru, directions = 8)
lsm_l_lsi(idaviru)
area <-lsm_p_area(idaviru, directions = 8)
area
max(area$value)


laaneviru<-raster("~/Desktop/BGI_DP/Cores/Lääne-Viru_cores.tif")

laaneviru_metrics<-calculate_lsm(laaneviru, level="landscape")
lsm_l_lpi(laaneviru, directions = 8)
lsm_l_area_mn(laaneviru, directions = 8)
lsm_l_pd(laaneviru, directions = 8)
lsm_l_lsi(laaneviru)
area <-lsm_p_area(laaneviru, directions = 8)
area
max(area$value)

parnu<-raster("~/Desktop/BGI_DP/Cores/Pärnu_cores1.tif")

parnu_metrics<-calculate_lsm(parnu, level="landscape")
lsm_l_lpi(parnu, directions = 8)
lsm_l_area_mn(parnu, directions = 8)
lsm_l_pd(parnu, directions = 8)
lsm_l_lsi(parnu)
area <-lsm_p_area(parnu, directions = 8)
area
max(area$value)

saare<-raster("~/Desktop/BGI_DP/Cores/Saare_cores.tif")

saare_metrics<-calculate_lsm(saare, level="landscape")
lsm_l_lpi(saare, directions = 8)
lsm_l_area_mn(saare, directions = 8)
lsm_l_pd(saare, directions = 8)
lsm_l_lsi(saare)
area <-lsm_p_area(saare, directions = 8)
area
max(area$value)

install.packages("openxlsx")
library(openxlsx)

# set your working directory
setwd("~/Desktop/BGI_DP/BGI_DP_Statistics")

# Combine the data into a single data frame
all_metrics <- rbind(harju_metrics, laane_metrics, hiiu_metrics, idaviru_metrics, laaneviru_metrics, parnu_metrics, saare_metrics)

# Save the data to an Excel file
write.xlsx(all_metrics, file = "landscape_metrics_results_all.xlsx",
           sheetName = "All Data", rowNames = FALSE)


plot(harju)
plot(hiiu)
plot(idaviru)
plot(laaneviru)
plot(laane)
plot(parnu) 
plot(saare)

library(sp)
library(lsm)
harju_metrics <- calculate_lsm(harju, level = "landscape")
spplot(harju_metrics, "l_lpi")
spplot(harju_metrics, "l_area_mn")
spplot(harju_metrics, "l_pd")
spplot(harju_metrics, "l_lsi")

library(raster)
library(landscapemetrics)
library(sparr)

harju <- raster("~/Desktop/BGI_DP/Cores/Harju_cores.tif")
harju_metrics <- calculate_lsm(harju, level = "landscape")

laane <- raster("/path/to/laane.tif")
laane_metrics <- calculate_lsm(laane, level = "landscape")

sparr(
  spplot(harju_metrics, "l_lpi"),
  spplot(laane_metrics, "l_lpi"),
  spplot(harju_metrics, "l_area_mn"),
  spplot(laane_metrics, "l_area_mn"),
  spplot(harju_metrics, "l_pd"),
  spplot(laane_metrics, "l_pd"),
  spplot(harju_metrics, "l_lsi"),
  spplot(laane_metrics, "l_lsi"),
  layout = c(2, 4),
  widths = rep(1, 4),
  heights = c(1, 2)
)



# total area of cores in Estonian coast by regions (each raster 20, -20 size; m2 <-(n_pxl * 400))
data <- data.frame(harju_c = 595055,
                   laane_c = 479639,
                   hiiu_c = 620609,
                   idaviru_c = 65253,
                   laaneviru_c = 314198,
                   parnu_c = 478865,
                   saare_c = 1197834)
data
data_multi <- data * 400
data
data_multi
#cores from m2 to ha
data_multi <- data_multi/10000
data_multi

#tables rearrangement

files <- list.files('data', full.names = TRUE)

files_branches <- files[grep('_branches', files)]
files_cores <- files[grep('_cores', files)]
files_corridors <- files[grep('_corridors', files)]

rearrange_tables <- function(files, table_name) {
  table <- data.frame()
  
  for (file in files) {
    region <- strsplit(strsplit(file, '/')[[1]][2], '_')[[1]][1]
    data <- read.csv(file, header = TRUE)
    data$region <- region
    table <- rbind(table, data)
  }
  
  write.csv(table, paste0('./', table_name, '.csv'), row.names = FALSE)
  
  table
}

old_name <- "results.xlsx"
new_name <- "ls_metrics_by_counties_results.xlsx"

file.rename(from = old_name, to = new_name)




branches_data = rearrange_tables(files_branches, 'branches_r')

install.packages("landscapemetrics")
install.packages("dplyr")

# Load the necessary libraries
library(dplyr)
library(tidyr)
library(ggplot2)
library(car)
library(readxl)

