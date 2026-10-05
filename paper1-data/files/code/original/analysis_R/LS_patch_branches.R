library(rgdal)
library(landscapemetrics)
library(raster)
library(tidyr)
library(dplyr)
library(openxlsx)

setwd("~/Desktop/ThirtyFourtyDocker/ls_metrics_allstat")

# read in the rasters
harju_branches <- raster("~/Desktop/BGI_DP/BGI_raster_by_regions /MSPA_rasters_clipped_3km/reclass_branches/Harju_branches.tif")
laane_branches <- raster("~/Desktop/BGI_DP/BGI_raster_by_regions /MSPA_rasters_clipped_3km/reclass_branches/Laane_branches.tif")
hiiu_branches <- raster("~/Desktop/BGI_DP/BGI_raster_by_regions /MSPA_rasters_clipped_3km/reclass_branches/Hiiu_branches.tif")
idaviru_branches <- raster("~/Desktop/BGI_DP/BGI_raster_by_regions /MSPA_rasters_clipped_3km/reclass_branches/Ida-Viru_branches.tif")
laaneviru_branches <- raster("~/Desktop/BGI_DP/BGI_raster_by_regions /MSPA_rasters_clipped_3km/reclass_branches/Laane-Viru_branches.tif")
parnu_branches <- raster("~/Desktop/BGI_DP/BGI_raster_by_regions /MSPA_rasters_clipped_3km/reclass_branches/Parnu_branches.tif")
saare_branches <- raster("~/Desktop/BGI_DP/BGI_raster_by_regions /MSPA_rasters_clipped_3km/reclass_branches/Saare_branches.tif")

raster_branches_list <- list(harju_branches, laane_branches, hiiu_branches, idaviru_branches, laaneviru_branches, parnu_branches, saare_branches)
counties <- c("Harju", "Lääne", "Hiiu", "Ida-Viru", "Lääne-Viru", "Pärnu", "Saare")
names(raster_branches_list) <- counties

# calculate landscape metrics
harju_branches_metrics <- calculate_lsm(harju_branches, level = "landscape")
laane_branches_metrics <- calculate_lsm(laane_branches, level = "landscape")
hiiu_branches_metrics <- calculate_lsm(hiiu_branches, level = "landscape")
idaviru_branches_metrics <- calculate_lsm(idaviru_branches, level = "landscape")
laaneviru_branches_metrics <- calculate_lsm(laaneviru_branches, level = "landscape")
parnu_branches_metrics <- calculate_lsm(parnu_branches, level = "landscape")
saare_branches_metrics <- calculate_lsm(saare_branches, level = "landscape")

# create a list of all the metrics data frames
lsm_branches_list <- list(harju_branches_metrics, laane_branches_metrics, hiiu_branches_metrics, idaviru_branches_metrics, laaneviru_branches_metrics, parnu_branches_metrics, saare_branches_metrics)

# combine the metrics for all counties into a single data frame
lsm_branches_df <- do.call(rbind, lsm_branches_list)
str(lsm_branches_df)
str(lsm_branches_df$metric)
print(lsm_branches_df$metric)

# add a column with the county names
lsm_branches_df$county <- row.names(lsm_branches_df)

# add a region column
lsm_branches_df <- transform(lsm_branches_df, Region = rep(counties, each = nrow(lsm_branches_df)/length(counties)))

#export the results to an excel file
write.xlsx(lsm_branches_df, "landscape_metrics_branches.xlsx")

# Store the LSM values in a list
metrics_branches_list <- list(
  harju_branches_metrics = harju_branches_metrics,
  laane_branches_metrics = laane_branches_metrics,
  hiiu_branches_metrics = hiiu_branches_metrics,
  idaviru_branches_metrics = idaviru_branches_metrics,
  laaneviru_branches_metrics = laaneviru_branches_metrics,
  parnu_branches_metrics = parnu_branches_metrics,
  saare_branches_metrics = saare_branches_metrics
)


# Convert the list to a data frame
metrics_branches_df <- as.data.frame(t(metrics_branches_list))

# Add a column with the region names
metrics_branches_df$region <- row.names(metrics_branches_df)

# Rename the last column to "region"
colnames(metrics_branches_df)[length(colnames(metrics_branches_df))] <- "region"

# View the data frame
metrics_branches_df

str(metrics_branches_df)

# Calculate patch-level landscape metrics for each raster in the list
patch_metrics_branches_list <- lapply(raster_branches_list, function(r) calculate_lsm(r, level = "patch"))

# Combine patch metrics data from all counties into a single data frame
patch_metrics_branches_df <- do.call(rbind, patch_metrics_branches_list)

# Write patch-level landscape metrics to a CSV file
write.csv(patch_metrics_branches_df, file = "branches_patch_metrics.csv", row.names = FALSE)

# Combine patch metrics data from all counties into a single data frame
patch_metrics_branches_df <- do.call(rbind, patch_metrics_branches_list)

# Add a Region column
patch_metrics_branches_df$Region <- rep(counties, length.out = nrow(patch_metrics_branches_df))

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
  metric <- patch_metrics_branches_df[patch_metrics_branches_df$metric == metric_name, ]
  
  # Create a new sheet for the current metric
  addWorksheet(wb, metrics_list[[metric_name]])
  
  # Write the data to the current sheet
  writeData(wb, sheet = metrics_list[[metric_name]], x = metric)
}

# Save the workbook to an Excel file
saveWorkbook(wb, "branches_patch_metrics.xlsx")

# calculate specific metrics for each raster
lsm_l_lpi(harju_branches, directions = 8)
lsm_l_area_mn(harju_branches, directions = 8)
lsm_l_pd(harju_branches, directions = 8)
lsm_l_lsi(harju_branches)
area <- lsm_p_area(harju_branches, directions = 8)
max(area$value)
#show_lsm(harju_branches, directions = 8, what = "lsm_p_area_harju_branches")

lsm_l_lpi(laane_branches, directions = 8)
lsm_l_area_mn(laane_branches, directions = 8)
lsm_l_pd(laane_branches, directions = 8)
lsm_l_lsi(laane_branches)
area <- lsm_p_area(laane_branches, directions = 8)
max(area$value)
#show_lsm(laane_branches, directions = 8, what = "lsm_p_area_laane_branches")

lsm_l_lpi(hiiu_branches, directions = 8)
lsm_l_area_mn(hiiu_branches, directions = 8)
lsm_l_pd(hiiu_branches, directions = 8)
lsm_l_lsi(hiiu_branches)
area <- lsm_p_area(hiiu_branches, directions = 8)
max(area$value)
#show_lsm(hiiu_branches, directions = 8, what = "lsm_p_area_hiiu_branches")

lsm_l_lpi(idaviru_branches, directions = 8)
lsm_l_area_mn(idaviru_branches, directions = 8)
lsm_l_pd(idaviru_branches, directions = 8)
lsm_l_lsi(idaviru_branches)
area <- lsm_p_area(idaviru_branches, directions = 8)
max(area$value)
#show_lsm(idaviru_branches, directions = 8, what = "lsm_p_area_idaviru_branches")

lsm_l_lpi(laaneviru_branches, directions = 8)
lsm_l_area_mn(laaneviru_branches, directions = 8)
lsm_l_pd(laaneviru_branches, directions = 8)
lsm_l_lsi(laaneviru_branches)
area <- lsm_p_area(laaneviru_branches, directions = 8)
max(area$value)
#show_lsm(laaneviru_branches, directions = 8, what = "lsm_p_area_laaneviru_branches")

lsm_l_lpi(parnu_branches, directions = 8)
lsm_l_area_mn(parnu_branches, directions = 8)
lsm_l_pd(parnu_branches, directions = 8)
lsm_l_lsi(parnu_branches)
area <- lsm_p_area(parnu_branches, directions = 8)
max(area$value)
#show_lsm(parnu_branches, directions = 8, what = "lsm_p_area_parnu_branches")

lsm_l_lpi(saare_branches, directions = 8)
lsm_l_area_mn(saare_branches, directions = 8)
lsm_l_pd(saare_branches, directions = 8)
lsm_l_lsi(saare_branches)
area <- lsm_p_area(saare_branches, directions = 8)
max(area$value)
#show_lsm(saare_branches, directions = 8, what = "lsm_p_area_saare_branches")

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
  raster <- raster_branches_list[[i]]
  
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
saveWorkbook(wb, "branches_spec_metrics.xlsx", overwrite = TRUE)


