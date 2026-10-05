library(rgdal)
library(landscapemetrics)
library(raster)
library(tidyr)
library(dplyr)


setwd("~/Desktop/ThirtyFourtyDocker/ls_metrics_allstat")

# read in the rasters
harju_corridors <- raster("~/Desktop/BGI_DP/BGI_raster_by_regions /MSPA_rasters_clipped_3km/reclass_corridors/Harju_corridors.tif")
laane_corridors <- raster("~/Desktop/BGI_DP/BGI_raster_by_regions /MSPA_rasters_clipped_3km/reclass_corridors/Laane_corridors.tif")
hiiu_corridors <- raster("~/Desktop/BGI_DP/BGI_raster_by_regions /MSPA_rasters_clipped_3km/reclass_corridors/Hiiu_corridors.tif")
idaviru_corridors <- raster("~/Desktop/BGI_DP/BGI_raster_by_regions /MSPA_rasters_clipped_3km/reclass_corridors/Ida-Viru_corridors.tif")
laaneviru_corridors <- raster("~/Desktop/BGI_DP/BGI_raster_by_regions /MSPA_rasters_clipped_3km/reclass_corridors/Laane_Viru_corridors.tif")
parnu_corridors <- raster("~/Desktop/BGI_DP/BGI_raster_by_regions /MSPA_rasters_clipped_3km/reclass_corridors/Parnu_corridors.tif")
saare_corridors <- raster("~/Desktop/BGI_DP/BGI_raster_by_regions /MSPA_rasters_clipped_3km/reclass_corridors/Saare_corridors.tif")

raster_corridors_list <- list(harju_corridors, laane_corridors, hiiu_corridors, idaviru_corridors, laaneviru_corridors, parnu_corridors, saare_corridors)
counties <- c("Harju", "Lääne", "Hiiu", "Ida-Viru", "Lääne-Viru", "Pärnu", "Saare")
names(raster_corridors_list) <- counties

# calculate landscape metrics
harju_corridors_metrics <- calculate_lsm(harju_corridors, level = "landscape")
laane_corridors_metrics <- calculate_lsm(laane_corridors, level = "landscape")
hiiu_corridors_metrics <- calculate_lsm(hiiu_corridors, level = "landscape")
idaviru_corridors_metrics <- calculate_lsm(idaviru_corridors, level = "landscape")
laaneviru_corridors_metrics <- calculate_lsm(laaneviru_corridors, level = "landscape")
parnu_corridors_metrics <- calculate_lsm(parnu_corridors, level = "landscape")
saare_corridors_metrics <- calculate_lsm(saare_corridors, level = "landscape")

# create a list of all the metrics data frames
lsm_corridors_list <- list(harju_corridors_metrics, laane_corridors_metrics, hiiu_corridors_metrics, idaviru_corridors_metrics, laaneviru_corridors_metrics, parnu_corridors_metrics, saare_corridors_metrics)

# combine the metrics for all counties into a single data frame
lsm_corridors_df <- do.call(rbind, lsm_corridors_list)
str(lsm_corridors_df)
str(lsm_corridors_df$metric)
print(lsm_corridors_df$metric)

# add a column with the county names
lsm_corridors_df$county <- row.names(lsm_corridors_df)

# add a region column
lsm_corridors_df <- transform(lsm_corridors_df, Region = rep(counties, each = nrow(lsm_corridors_df)/length(counties)))

# Install the required package
install.packages("writexl")

# Load required library
library(openxlsx)

#export the results to an excel file
write.xlsx(lsm_corridors_df, "landscape_metrics_corridors.xlsx")

# Store the LSM values in a list
metrics_corridors_list <- list(
  harju_corridors_metrics = harju_corridors_metrics,
  laane_corridors_metrics = laane_corridors_metrics,
  hiiu_corridors_metrics = hiiu_corridors_metrics,
  idaviru_corridors_metrics = idaviru_corridors_metrics,
  laaneviru_corridors_metrics = laaneviru_corridors_metrics,
  parnu_corridors_metrics = parnu_corridors_metrics,
  saare_corridors_metrics = saare_corridors_metrics
)


# Convert the list to a data frame
metrics_corridors_df <- as.data.frame(t(metrics_corridors_list))

# Add a column with the region names
metrics_corridors_df$region <- row.names(metrics_corridors_df)

# Rename the last column to "region"
colnames(metrics_corridors_df)[length(colnames(metrics_corridors_df))] <- "region"

# View the data frame
metrics_corridors_df

str(metrics_corridors_df)

# Calculate patch-level landscape metrics for each raster in the list
patch_metrics_corridors_list <- lapply(raster_corridors_list, function(r) calculate_lsm(r, level = "patch"))


# Combine patch metrics data from all counties into a single data frame
patch_metrics_corridors_df <- do.call(rbind, patch_metrics_corridors_list)

# Write patch-level landscape metrics to a CSV file
write.csv(patch_metrics_corridors_df, file = "corridors_patch_metrics.csv", row.names = FALSE)

# Combine patch metrics data from all counties into a single data frame
patch_metrics_corridors_df <- do.call(rbind, patch_metrics_corridors_list)

# Add a Region column
patch_metrics_corridors_df$Region <- rep(counties, each = nrow(patch_metrics_corridors_df)/length(counties))

# Create a list of metrics and their corresponding names
metrics_list <- list(
  "area" = "Area",
  "cai" = "CAI",
  "circle" = "Circle",
  "contig" = "Contig",
  "core" = "Core",
  "enn" = "ENN",
  "frac" = "Frac",
  "gyrate" = "Gyrate",
  "ncore" = "NCORE",
  "para" = "Para",
  "perim" = "Perim",
  "shape" = "Shape"
)

# Create a new workbook
wb <- createWorkbook()

# Loop through each metric
for (metric_name in names(metrics_list)) {
  
  # Subset the patch metrics data for the current metric
  metric <- patch_metrics_corridors_df[patch_metrics_corridors_df$metric == metric_name, ]
  
  # Create a new sheet for the current metric
  addWorksheet(wb, metrics_list[[metric_name]])
  
  # Write the data to the current sheet
  writeData(wb, sheet = metrics_list[[metric_name]], x = metric)
}

# Save the workbook to an Excel file
saveWorkbook(wb, "corridors_patch_metrics.xlsx")

# calculate specific metrics for each raster
lsm_l_lpi(harju_corridors, directions = 8)
lsm_l_area_mn(harju_corridors, directions = 8)
lsm_l_pd(harju_corridors, directions = 8)
lsm_l_lsi(harju_corridors)
area <- lsm_p_area(harju_corridors, directions = 8)
max(area$value)
#show_lsm(harju_corridors, directions = 8, what = "lsm_p_area_harju_corridors")

lsm_l_lpi(laane_corridors, directions = 8)
lsm_l_area_mn(laane_corridors, directions = 8)
lsm_l_pd(laane_corridors, directions = 8)
lsm_l_lsi(laane_corridors)
area <- lsm_p_area(laane_corridors, directions = 8)
max(area$value)
#show_lsm(laane_corridors, directions = 8, what = "lsm_p_area_laane_corridors")

lsm_l_lpi(hiiu_corridors, directions = 8)
lsm_l_area_mn(hiiu_corridors, directions = 8)
lsm_l_pd(hiiu_corridors, directions = 8)
lsm_l_lsi(hiiu_corridors)
area <- lsm_p_area(hiiu_corridors, directions = 8)
max(area$value)
#show_lsm(hiiu_corridors, directions = 8, what = "lsm_p_area_hiiu_corridors")

lsm_l_lpi(idaviru_corridors, directions = 8)
lsm_l_area_mn(idaviru_corridors, directions = 8)
lsm_l_pd(idaviru_corridors, directions = 8)
lsm_l_lsi(idaviru_corridors)
area <- lsm_p_area(idaviru_corridors, directions = 8)
max(area$value)
#show_lsm(idaviru_corridors, directions = 8, what = "lsm_p_area_idaviru_corridors")

lsm_l_lpi(laaneviru_corridors, directions = 8)
lsm_l_area_mn(laaneviru_corridors, directions = 8)
lsm_l_pd(laaneviru_corridors, directions = 8)
lsm_l_lsi(laaneviru_corridors)
area <- lsm_p_area(laaneviru_corridors, directions = 8)
max(area$value)
#show_lsm(laaneviru_corridors, directions = 8, what = "lsm_p_area_laaneviru_corridors")

lsm_l_lpi(parnu_corridors, directions = 8)
lsm_l_area_mn(parnu_corridors, directions = 8)
lsm_l_pd(parnu_corridors, directions = 8)
lsm_l_lsi(parnu_corridors)
area <- lsm_p_area(parnu_corridors, directions = 8)
max(area$value)
#show_lsm(parnu_corridors, directions = 8, what = "lsm_p_area_parnu_corridors")

lsm_l_lpi(saare_corridors, directions = 8)
lsm_l_area_mn(saare_corridors, directions = 8)
lsm_l_pd(saare_corridors, directions = 8)
lsm_l_lsi(saare_corridors)
area <- lsm_p_area(saare_corridors, directions = 8)
max(area$value)
#show_lsm(saare_corridors, directions = 8, what = "lsm_p_area_saare_corridors")

library(lsm)
library(raster)
library(writexl)

# define the functions for LSM metrics
LSM_L_LPI <- function(x) lsm_l_lpi(x, directions = 8)$value
LSM_L_AREA_MN <- function(x) lsm_l_area_mn(x, directions = 8)$value
LSM_L_PD <- function(x) lsm_l_pd(x, directions = 8)$value
LSM_L_LSI <- function(x) lsm_l_lsi(x)$value
LSM_P_AREA <- function(x) max(lsm_p_area(x, directions = 8)$value)

# create an empty data frame to store the results
results <- data.frame(county = character(),
                      lpi = numeric(),
                      area_mn = numeric(),
                      pd = numeric(),
                      lsi = numeric(),
                      p_area = numeric())

# loop over the counties and rasters, calculate LSM metrics, and save the results to a data frame
for (i in seq_along(counties)) {
  county <- counties[i]
  raster <- raster_corridors_list[[i]]
  
  lpi <- LSM_L_LPI(raster)
  area_mn <- LSM_L_AREA_MN(raster)
  pd <- LSM_L_PD(raster)
  lsi <- LSM_L_LSI(raster)
  p_area <- LSM_P_AREA(raster)
  
  results[i, ] <- c(county, lpi, area_mn, pd, lsi, p_area)
  
  # save the results to an Excel file
  write_xlsx(results, paste0(county, ".xlsx"))
}

library(openxlsx)

# create a new workbook
wb <- createWorkbook()

# loop over the county Excel files and add them to the workbook
for (county in counties) {
  # read the Excel file
  county_file <- paste0(county, ".xlsx")
  county_df <- read.xlsx(county_file, sheet = 1)
  
  # add a new worksheet to the workbook and write the data
  addWorksheet(wb, county)
  writeData(wb, county, county_df)
}

# save the workbook
saveWorkbook(wb, "corridors_spec_metrics.xlsx", overwrite = TRUE)


