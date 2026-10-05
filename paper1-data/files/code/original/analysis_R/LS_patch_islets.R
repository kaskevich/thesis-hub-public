library(rgdal)
library(landscapemetrics)
library(raster)
library(tidyr)
library(dplyr)
library(openxlsx)

setwd("~/Desktop/ThirtyFourtyDocker/ls_metrics_allstat")

# read in the rasters
harju_islets <- raster("~/Desktop/BGI_DP/Islets/Islets_harju.tif")
laane_islets <- raster("~/Desktop/BGI_DP/Islets/Islets_laane.tif")
hiiu_islets <- raster("~/Desktop/BGI_DP/Islets/Islets_hiiu.tif")
idaviru_islets <- raster("~/Desktop/BGI_DP/Islets/Islets_idaviru.tif")
laaneviru_islets <- raster("~/Desktop/BGI_DP/Islets/Islets_laaneviru.tif")
parnu_islets <- raster("~/Desktop/BGI_DP/Islets/Islets_parnu.tif")
saare_islets <- raster("~/Desktop/BGI_DP/Islets/Islets_saare.tif")

raster_islets_list <- list(harju_islets, laane_islets, hiiu_islets, idaviru_islets, laaneviru_islets, parnu_islets, saare_islets)
counties <- c("Harju", "Lääne", "Hiiu", "Ida-Viru", "Lääne-Viru", "Pärnu", "Saare")
names(raster_islets_list) <- counties

# calculate landscape metrics
harju_islets_metrics <- calculate_lsm(harju_islets, level = "landscape")
laane_islets_metrics <- calculate_lsm(laane_islets, level = "landscape")
hiiu_islets_metrics <- calculate_lsm(hiiu_islets, level = "landscape")
idaviru_islets_metrics <- calculate_lsm(idaviru_islets, level = "landscape")
laaneviru_islets_metrics <- calculate_lsm(laaneviru_islets, level = "landscape")
parnu_islets_metrics <- calculate_lsm(parnu_islets, level = "landscape")
saare_islets_metrics <- calculate_lsm(saare_islets, level = "landscape")

# create a list of all the metrics data frames
lsm_islets_list <- list(harju_islets_metrics, laane_islets_metrics, hiiu_islets_metrics, idaviru_islets_metrics, laaneviru_islets_metrics, parnu_islets_metrics, saare_islets_metrics)

# combine the metrics for all counties into a single data frame
lsm_islets_df <- do.call(rbind, lsm_islets_list)
str(lsm_islets_df)
str(lsm_islets_df$metric)
print(lsm_islets_df$metric)

# add a column with the county names
lsm_islets_df$county <- row.names(lsm_islets_df)

# add a region column
lsm_islets_df <- transform(lsm_islets_df, Region = rep(counties, each = nrow(lsm_islets_df)/length(counties)))

#export the results to an excel file
write.xlsx(lsm_islets_df, "landscape_metrics_islets.xlsx")

# Store the LSM values in a list
metrics_islets_list <- list(
  harju_islets_metrics = harju_islets_metrics,
  laane_islets_metrics = laane_islets_metrics,
  hiiu_islets_metrics = hiiu_islets_metrics,
  idaviru_islets_metrics = idaviru_islets_metrics,
  laaneviru_islets_metrics = laaneviru_islets_metrics,
  parnu_islets_metrics = parnu_islets_metrics,
  saare_islets_metrics = saare_islets_metrics
)


# Convert the list to a data frame
metrics_islets_df <- as.data.frame(t(metrics_islets_list))

# Add a column with the region names
metrics_islets_df$region <- row.names(metrics_islets_df)

# Rename the last column to "region"
colnames(metrics_islets_df)[length(colnames(metrics_islets_df))] <- "region"

# View the data frame
metrics_islets_df

str(metrics_islets_df)

# Calculate patch-level landscape metrics for each raster in the list
patch_metrics_islets_list <- lapply(raster_islets_list, function(r) calculate_lsm(r, level = "patch"))

# Combine patch metrics data from all counties into a single data frame
patch_metrics_islets_df <- do.call(rbind, patch_metrics_islets_list)

# Write patch-level landscape metrics to a CSV file
write.csv(patch_metrics_islets_df, file = "islets_patch_metrics.csv", row.names = FALSE)

# Combine patch metrics data from all counties into a single data frame
patch_metrics_islets_df <- do.call(rbind, patch_metrics_islets_list)

# Add a Region column
patch_metrics_islets_df$Region <- rep(counties, each = nrow(patch_metrics_islets_df)/length(counties), length.out = nrow(patch_metrics_islets_df))

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
  metric <- patch_metrics_islets_df[patch_metrics_islets_df$metric == metric_name, ]
  
  # Create a new sheet for the current metric
  addWorksheet(wb, metrics_list[[metric_name]])
  
  # Write the data to the current sheet
  writeData(wb, sheet = metrics_list[[metric_name]], x = metric)
}

# Save the workbook to an Excel file
saveWorkbook(wb, "islets_patch_metrics.xlsx")

# calculate specific metrics for each raster
lsm_l_lpi(harju_islets, directions = 8)
lsm_l_area_mn(harju_islets, directions = 8)
lsm_l_pd(harju_islets, directions = 8)
lsm_l_lsi(harju_islets)
area <- lsm_p_area(harju_islets, directions = 8)
max(area$value)
#show_lsm(harju_islets, directions = 8, what = "lsm_p_area_harju_islets")

lsm_l_lpi(laane_islets, directions = 8)
lsm_l_area_mn(laane_islets, directions = 8)
lsm_l_pd(laane_islets, directions = 8)
lsm_l_lsi(laane_islets)
area <- lsm_p_area(laane_islets, directions = 8)
max(area$value)
#show_lsm(laane_islets, directions = 8, what = "lsm_p_area_laane_islets")

lsm_l_lpi(hiiu_islets, directions = 8)
lsm_l_area_mn(hiiu_islets, directions = 8)
lsm_l_pd(hiiu_islets, directions = 8)
lsm_l_lsi(hiiu_islets)
area <- lsm_p_area(hiiu_islets, directions = 8)
max(area$value)
#show_lsm(hiiu_islets, directions = 8, what = "lsm_p_area_hiiu_islets")

lsm_l_lpi(idaviru_islets, directions = 8)
lsm_l_area_mn(idaviru_islets, directions = 8)
lsm_l_pd(idaviru_islets, directions = 8)
lsm_l_lsi(idaviru_islets)
area <- lsm_p_area(idaviru_islets, directions = 8)
max(area$value)
#show_lsm(idaviru_islets, directions = 8, what = "lsm_p_area_idaviru_islets")

lsm_l_lpi(laaneviru_islets, directions = 8)
lsm_l_area_mn(laaneviru_islets, directions = 8)
lsm_l_pd(laaneviru_islets, directions = 8)
lsm_l_lsi(laaneviru_islets)
area <- lsm_p_area(laaneviru_islets, directions = 8)
max(area$value)
#show_lsm(laaneviru_islets, directions = 8, what = "lsm_p_area_laaneviru_islets")

lsm_l_lpi(parnu_islets, directions = 8)
lsm_l_area_mn(parnu_islets, directions = 8)
lsm_l_pd(parnu_islets, directions = 8)
lsm_l_lsi(parnu_islets)
area <- lsm_p_area(parnu_islets, directions = 8)
max(area$value)
#show_lsm(parnu_islets, directions = 8, what = "lsm_p_area_parnu_islets")

lsm_l_lpi(saare_islets, directions = 8)
lsm_l_area_mn(saare_islets, directions = 8)
lsm_l_pd(saare_islets, directions = 8)
lsm_l_lsi(saare_islets)
area <- lsm_p_area(saare_islets, directions = 8)
max(area$value)
#show_lsm(saare_islets, directions = 8, what = "lsm_p_area_saare_islets")

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
  raster <- raster_islets_list[[i]]
  
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
saveWorkbook(wb, "islets_spec_metrics.xlsx", overwrite = TRUE)


