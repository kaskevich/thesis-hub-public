library(rgdal)
library(landscapemetrics)
library(raster)
library(tidyr)
library(dplyr)
library(openxlsx)

setwd("~/Desktop/ThirtyFourtyDocker/ls_metrics_allstat")

# read in the rasters
harju <- raster("~/Desktop/ThirtyFourtyDocker/ls_metrics_allstat/Harju_cores.tif")
laane <- raster("~/Desktop/ThirtyFourtyDocker/ls_metrics_allstat/Laane_cores.tif")
hiiu <- raster("~/Desktop/ThirtyFourtyDocker/ls_metrics_allstat/Hiiu_cores.tif")
idaviru <- raster("~/Desktop/ThirtyFourtyDocker/ls_metrics_allstat/Ida-Viru_cores.tif")
laaneviru <- raster("~/Desktop/ThirtyFourtyDocker/ls_metrics_allstat/Lääne-Viru_cores.tif")
parnu <- raster("~/Desktop/ThirtyFourtyDocker/ls_metrics_allstat/Pärnu_cores1.tif")
saare <- raster("~/Desktop/ThirtyFourtyDocker/ls_metrics_allstat/Saare_cores.tif")

raster_list <- list(harju, laane, hiiu, idaviru, laaneviru, parnu, saare)
counties <- c("Harju", "Lääne", "Hiiu", "Ida-Viru", "Lääne-Viru", "Pärnu", "Saare")

# calculate landscape metrics
harju_metrics <- calculate_lsm(harju, level = "landscape")
laane_metrics <- calculate_lsm(laane, level = "landscape")
hiiu_metrics <- calculate_lsm(hiiu, level = "landscape")
idaviru_metrics <- calculate_lsm(idaviru, level = "landscape")
laaneviru_metrics <- calculate_lsm(laaneviru, level = "landscape")
parnu_metrics <- calculate_lsm(parnu, level = "landscape")
saare_metrics <- calculate_lsm(saare, level = "landscape")

# create a list of all the metrics data frames
lsm_cores_list <- list(harju_metrics, laane_metrics, hiiu_metrics, idaviru_metrics, laaneviru_metrics, parnu_metrics, saare_metrics)

# combine the metrics for all counties into a single data frame
lsm_cores_df <- do.call(rbind, lsm_cores_list)
str(lsm_cores_df)
str(lsm_cores_df$metric)
print(lsm_cores_df$metric)

# add a column with the county names
lsm_cores_df$county <- row.names(lsm_cores_df)

# add a region column
lsm_cores_df <- transform(lsm_cores_df, Region = rep(counties, each = nrow(lsm_cores_df)/length(counties)))

# Install the required package
install.packages("writexl")

# Load required library
library(openxlsx)

#export the results to an excel file
write.xlsx(lsm_cores_df, "landscape_metrics_cores.xlsx")

# Store the LSM values in a list
metrics_cores_list <- list(
  harju_metrics = harju_metrics,
  laane_metrics = laane_metrics,
  hiiu_metrics = hiiu_metrics,
  idaviru_metrics = idaviru_metrics,
  laaneviru_metrics = laaneviru_metrics,
  parnu_metrics = parnu_metrics,
  saare_metrics = saare_metrics
)

# Convert the list to a data frame
metrics_cores_df <- as.data.frame(t(metrics_cores_list))

# Add a column with the region names
metrics_cores_df$region <- row.names(metrics_cores_df)

# Rename the last column to "region"
colnames(metrics_cores_df)[length(colnames(metrics_cores_df))] <- "region"

# Calculate patch-level landscape metrics for each raster in the list
patch_metrics_cores_list <- lapply(raster_list, function(r) calculate_lsm(r, level = "patch"))

# Combine patch metrics data from all counties into a single data frame
patch_metrics_cores_df <- do.call(rbind, patch_metrics_cores_list)

# Write patch-level landscape metrics to a CSV file
write.csv(patch_metrics_cores_df, file = "patch_metrics_cores.csv", row.names = FALSE)

# Combine patch metrics data from all counties into a single data frame
patch_metrics_cores_df <- do.call(rbind, patch_metrics_cores_list)

# Add a Region column
patch_metrics_cores_df$Region <- rep(counties, length.out = nrow(patch_metrics_cores_df))

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
  metric <- patch_metrics_cores_df[patch_metrics_cores_df$metric == metric_name, ]
  
  # Create a new sheet for the current metric
  addWorksheet(wb, metrics_list[[metric_name]])
  
  # Write the data to the current sheet
  writeData(wb, sheet = metrics_list[[metric_name]], x = metric)
}

# Save the workbook to an Excel file
saveWorkbook(wb, "patch_metrics_cores.xlsx")

# calculate specific metrics for each raster
lsm_l_lpi(harju, directions = 8)
lsm_l_area_mn(harju, directions = 8)
lsm_l_pd(harju, directions = 8)
lsm_l_lsi(harju)
area <- lsm_p_area(harju, directions = 8)
max(area$value)
#show_lsm(harju, directions = 8, what = "lsm_p_area")

lsm_l_lpi(laane, directions = 8)
lsm_l_area_mn(laane, directions = 8)
lsm_l_pd(laane, directions = 8)
lsm_l_lsi(laane)
area <- lsm_p_area(laane, directions = 8)
max(area$value)
#show_lsm(laane, directions = 8, what = "lsm_p_area")

lsm_l_lpi(hiiu, directions = 8)
lsm_l_area_mn(hiiu, directions = 8)
lsm_l_pd(hiiu, directions = 8)
lsm_l_lsi(hiiu)
area <- lsm_p_area(hiiu, directions = 8)
max(area$value)
#show_lsm(hiiu, directions = 8, what = "lsm_p_area")

lsm_l_lpi(idaviru, directions = 8)
lsm_l_area_mn(idaviru, directions = 8)
lsm_l_pd(idaviru, directions = 8)
lsm_l_lsi(idaviru)
area <- lsm_p_area(idaviru, directions = 8)
max(area$value)
#show_lsm(idaviru, directions = 8, what = "lsm_p_area")

lsm_l_lpi(laaneviru, directions = 8)
lsm_l_area_mn(laaneviru, directions = 8)
lsm_l_pd(laaneviru, directions = 8)
lsm_l_lsi(laaneviru)
area <- lsm_p_area(laaneviru, directions = 8)
max(area$value)
#show_lsm(laaneviru, directions = 8, what = "lsm_p_area")

lsm_l_lpi(parnu, directions = 8)
lsm_l_area_mn(parnu, directions = 8)
lsm_l_pd(parnu, directions = 8)
lsm_l_lsi(parnu)
area <- lsm_p_area(parnu, directions = 8)
max(area$value)
#show_lsm(parnu, directions = 8, what = "lsm_p_area")

lsm_l_lpi(saare, directions = 8)
lsm_l_area_mn(saare, directions = 8)
lsm_l_pd(saare, directions = 8)
lsm_l_lsi(saare)
area <- lsm_p_area(saare, directions = 8)
max(area$value)
#show_lsm(saare, directions = 8, what = "lsm_p_area")

library(lsm)
library(raster)
library(writexl)

# define the counties and corresponding rasters
counties <- c("Harju", "Lääne", "Hiiu", "Ida-Viru", "Lääne-Viru", "Pärnu", "Saare")
raster_list <- list(harju, laane, hiiu, idaviru, laaneviru, parnu, saare)

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
  raster <- raster_list[[i]]
  
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
saveWorkbook(wb, "cores_spec_metrics.xlsx", overwrite = TRUE)











