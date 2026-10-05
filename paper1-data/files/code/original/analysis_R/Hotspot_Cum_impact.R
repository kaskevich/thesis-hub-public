library(readxl)
library(ggplot2)
library(rstatix)
library(sp)
library(sf)
library(spdep)
library(sfdep)
library(dplyr)
library(hexbin)
library(ggmap)
library(leaflet)
library(dunn.test) 
library(RColorBrewer)

# Read in the Data from the Shapefile
data_path <- "~/Desktop/BGI_DP/BGI_DP_Statistics/GN_hexagon_stat/hexagon_by_regions_gn_nor.shp"
hex_data <- st_read(data_path)

# Visualize the Dataset
# Visualize the first few rows
head(hex_data)

# Histogram of cum_norm
hist(hex_data$cum_norm, 
     main = "Distribution of Cumulative Impact (cum_norm)", 
     xlab = "Cumulative Impact Value", 
     ylab = "Frequency",
     col = "lightblue", 
     border = "black")

# Plot hexagons with cum_norm values
ggplot(hex_data) + 
  geom_sf(aes(fill = cum_norm), color = NA) +  # Remove outline by setting color to NA
  scale_fill_viridis_c() +
  theme_minimal() +
  labs(title = "Spatial Distribution of Cumulative Impact",
       fill = "Cumulative Impact Value")

# Spatial Analysis:
# Create a list of neighbors using queen contiguity
list_nb <- st_contiguity(hex_data)

# Check for and remove polygons with empty neighbor sets
empty_nb <- which(card(list_nb) == 0)
if (length(empty_nb) > 0) {
  hex_subset <- hex_data[-empty_nb, ]
} else {
  hex_subset <- hex_data
}

# Recompute neighbors and weights after removing empty neighbors
hex_nb <- st_contiguity(hex_subset)
hex_w_binary <- nb2listw(hex_nb, style = "B")

# Calculate spatial lag
hex_lag <- lag.listw(hex_w_binary, hex_subset$cum_norm)

# Global G statistic
globalG.result <- globalG.test(hex_subset$cum_norm, hex_w_binary)
print(globalG.result)

# Local Getis-Ord statistic
localG.values <- localG(hex_subset$cum_norm, hex_w_binary)
hex_subset$localG <- localG.values

# Classify Results Based on Local G and p-values
# Compute p-values
p_values <- 2 * (1 - pnorm(abs(localG.values)))

# Classify
hex_subset$classification <- dplyr::case_when(
  localG.values > 0 & p_values <= 0.01 ~ "Very High Impact",
  localG.values > 0 & p_values <= 0.05 ~ "High Impact",
  localG.values > 0 & p_values <= 0.1  ~ "Moderate Impact",
  localG.values < 0 & p_values <= 0.01 ~ "Very Low Impact",
  localG.values < 0 & p_values <= 0.05 ~ "Low Impact",
  localG.values < 0 & p_values <= 0.1  ~ "Slightly Low Impact",
  TRUE ~ "Neutral Impact"
)

# Final Visualization 
# Plot with classifications
ggplot(hex_subset) + 
  geom_sf(aes(fill = classification)) +
  scale_fill_manual(values = brewer.pal(7, "Set1")) +
  theme_minimal() +
  labs(title = "Classification of Cumulative Impact",
       fill = "Impact Level")

# Convert 'classification' into a Factor for Plotting
hex_subset$classification <- factor(
  hex_subset$classification,
  levels = c("Very High Impact", "High Impact", "Moderate Impact",
             "Neutral Impact", "Slightly Low Impact", "Low Impact", 
             "Very Low Impact", "Unclassified")
)

# Define Custom Colors for the Plot
custom_colors <- c(
  "Very High Impact" = "darkred",
  "High Impact" = "red",
  "Moderate Impact" = "lightsalmon",
  "Neutral Impact" = "white",
  "Slightly Low Impact" = "#ADD8E6",
  "Low Impact" = "dodgerblue",
  "Very Low Impact" = "midnightblue",
  "Unclassified" = NA  # Set unclassified as transparent
)

# Create the Main Plot
ggplot(hex_subset, aes(fill = classification)) +
  geom_sf(color = NA) +  # Make outline color transparent
  scale_fill_manual(values = custom_colors) +
  theme_void() +
  labs(
    fill = "Cumulative Impact Classification",
    title = "Cumulative Impact Distribution on Estonian Coast"
  )



# Additional library needed for inset maps

library(tmaptools)

library(tmap)

# Set the bounding box for the inset map (replace with your actual coordinates for the hotspot)
box_inset <- st_bbox(c(xmin = 377981.971, xmax = 730623.360, 
                       ymin = 6408983.666, ymax = 6598338.334), 
                     crs = st_crs(hex_subset))

# Create the main map
main_map <- tm_shape(hex_subset) +
  tm_polygons("classification", id = "id", palette = custom_colors) +
  tm_layout(main.title = "Cumulative Impact Distribution on Estonian Coast",
            main.title.position = "center",
            legend.position = c("right", "bottom")) +
  tm_scale_bar(breaks = c(0, 10, 20), position = c("left", "bottom")) +
  tm_compass(type = "arrow", position = c("left", "top"))

custom_colors <- c(
  "Very High Impact" = "darkred",
  "High Impact" = "red",
  "Moderate Impact" = "lightsalmon",
  "Neutral Impact" = NA, # or "transparent" for no fill
  "Slightly Low Impact" = "#ADD8E6",
  "Low Impact" = "dodgerblue",
  "Very Low Impact" = "midnightblue",
)

# Adjust alpha for transparency in tm_polygons and ensure the legend is properly displayed
main_map <- tm_shape(hex_subset) +
  tm_polygons("classification", palette = custom_colors, border.col = "transparent", border.alpha = 0) +
  tm_layout(
    title = "Cumulative Impact Distribution on Estonian Coast",
    title.position = c("left", "top"),
    legend.position = c("left", "bottom"),
    legend.bg.color = "white",
    legend.bg.alpha = 0.7,
    frame = FALSE
  ) +
  tm_scale_bar(position = c("left", "bottom")) +
  tm_compass(type = "arrow", position = c("left", "top"))

# Print the map
print(main_map)


# Create the inset map
# Define the bounding box coordinates for Pärnu County directly
bbox_parnu <- st_bbox(c(
  xmin = 457862.705, ymin = 6411654.244,  # Bottom-left coordinates
  xmax = 582975.653, ymax = 6512555.519   # Top-right coordinates
), crs = st_crs(hex_subset))

# Convert the bbox to an sfc object
bbox_parnu_sfc <- st_as_sfc(bbox_parnu)

# Check the bbox object
print(bbox_parnu)

library(sf)
library(grid)

# Convert the bounding box to an sf geometry
bbox_parnu_sf <- st_as_sfc(bbox_parnu)

# Use st_intersects to find the indices of hexagons within the bounding box
intersects_list <- st_intersects(hex_subset, bbox_parnu_sf)

# Extract the indices from the list
# We're looking for non-empty list elements, which indicate intersection
indices_within <- which(lengths(intersects_list) > 0)

# Subset the data for Pärnu County using the indices
parnu_subset <- hex_subset[indices_within, ]


# Create the main map
main_map <- tm_shape(hex_subset) +
  tm_polygons("classification", palette = custom_colors, border.col = NA) +
  tm_layout(
    title = "Cumulative Impact Distribution on Estonian Coast",
    frame = FALSE
  ) +
  tm_scale_bar(position = c("left", "bottom")) +
  tm_compass(type = "arrow", position = c("left", "top"))

print(main_map)

# Subset the data for Pärnu County using the bounding box
parnu_subset <- hex_subset[hex_subset %within% st_as_sfc(bbox_parnu), ]

# Create the close-up map for Pärnu County
closeup_map <- tm_shape(parnu_subset) +
  tm_polygons("classification", palette = custom_colors) +
  tm_layout(frame = FALSE)

# Plot the main map
print(main_map)

# Create a viewport for the inset map (close-up of Pärnu County)
vp <- viewport(
  x = 0.8, y = 0.2, 
  width = 0.4, height = 0.4, 
  just = c("left", "bottom")
)

# Print the close-up map in the viewport
print(closeup_map, vp = vp)

# Write the modified hexagon data to a new shapefile
output_path <- "~/Desktop/BGI_DP/hexagon_analysis_hotspots.shp"
st_write(hex_subset, output_path)


# Create a Zoomed-in Plot
# Define bounding box coordinates
bbox_coords <- c(
  xmin = 513072.383, ymin = 6560239.821,
  xmax = 607673.778, ymax = 6635729.823
)

# Convert to sf object
bbox_sf <- st_as_sfc(st_bbox(bbox_coords, crs = st_crs(hex_subset)))

# Create the zoomed-in plot of Tallinn area
ggplot() +
  geom_sf(data = hex_subset, aes(fill = classification), color = "black", lwd = 0.1) +
  geom_sf(data = bbox_sf, fill = NA, color = "red", lwd = 1) +  # This draws the bounding box for visual reference.
  coord_sf(xlim = c(bbox_coords["xmin"], bbox_coords["xmax"]), ylim = c(bbox_coords["ymin"], bbox_coords["ymax"]), expand = FALSE) +
  scale_fill_manual(values = custom_colors) +
  theme_void() +
  labs(
    fill = "Cumulative Impact Classification",
    title = "Zoomed Cumulative Impact Distribution on Estonian Coast"
  )


# Define bounding box coordinates of Saare region
bbox_coords <- c(
  xmin = 356357.604, ymin = 6416581.483,  # Bottom-left coordinates
  xmax = 481344.878, ymax = 6516640.547   # Top-right coordinates
)

# Convert to sf object
bbox_sf <- st_as_sfc(st_bbox(bbox_coords, crs = st_crs(hex_subset)))

# Create the zoomed-in plot
ggplot() +
  geom_sf(data = hex_subset, aes(fill = classification), color = "black", lwd = 0.1) +
  geom_sf(data = bbox_sf, fill = NA, color = "red", lwd = 1) +  # This draws the bounding box for visual reference.
  coord_sf(xlim = c(bbox_coords["xmin"], bbox_coords["xmax"]), ylim = c(bbox_coords["ymin"], bbox_coords["ymax"]), expand = FALSE) +
  scale_fill_manual(values = custom_colors) +
  theme_void() +
  labs(
    fill = "Cumulative Impact Classification",
    title = "Zoomed Cumulative Impact Distribution on Estonian Coast. Saare Island"
  )

# Define bounding box coordinates of Hiiu region
bbox_coords <- c(
  xmin = 385739.846, ymin = 6500159.468,  # Bottom-left coordinates
  xmax = 454236.733, ymax = 6555020.108   # Top-right coordinates
)

# Convert to sf object
bbox_sf <- st_as_sfc(st_bbox(bbox_coords, crs = st_crs(hex_subset)))

# Create the zoomed-in plot
ggplot() +
  geom_sf(data = hex_subset, aes(fill = classification), color = "black", lwd = 0.1) +
  geom_sf(data = bbox_sf, fill = NA, color = "red", lwd = 1) +  # This draws the bounding box for visual reference.
  coord_sf(xlim = c(bbox_coords["xmin"], bbox_coords["xmax"]), ylim = c(bbox_coords["ymin"], bbox_coords["ymax"]), expand = FALSE) +
  scale_fill_manual(values = custom_colors) +
  theme_void() +
  labs(
    fill = "Cumulative Impact Classification",
    title = "Zoomed Cumulative Impact Distribution on Estonian Coast. Hiiu Island"
  )

# Define bounding box coordinates of Ida-Viru region
bbox_coords <- c(
  xmin = 652172.421, ymin = 6533348.728,  # Bottom-left coordinates
  xmax = 740880.369, ymax = 6604347.880   # Top-right coordinates
)

# Convert to sf object
bbox_sf <- st_as_sfc(st_bbox(bbox_coords, crs = st_crs(hex_subset)))

# Create the zoomed-in plot
ggplot() +
  geom_sf(data = hex_subset, aes(fill = classification), color = "black", lwd = 0.1) +
  geom_sf(data = bbox_sf, fill = NA, color = "red", lwd = 1) +  # This draws the bounding box for visual reference.
  coord_sf(xlim = c(bbox_coords["xmin"], bbox_coords["xmax"]), ylim = c(bbox_coords["ymin"], bbox_coords["ymax"]), expand = FALSE) +
  scale_fill_manual(values = custom_colors) +
  theme_void() +
  labs(
    fill = "Cumulative Impact Classification",
    title = "Zoomed Cumulative Impact Distribution on Estonian Coast. Ida-Viru region"
  )

# Define bounding box coordinates of Laane-Viru region
bbox_coords <- c(
  xmin = 600936.821, ymin = 6571905.284,  # Bottom-left coordinates
  xmax = 665978.806, ymax = 6623722.466   # Top-right coordinates
)

# Convert to sf object
bbox_sf <- st_as_sfc(st_bbox(bbox_coords, crs = st_crs(hex_subset)))

# Create the zoomed-in plot
ggplot() +
  geom_sf(data = hex_subset, aes(fill = classification), color = "black", lwd = 0.1) +
  geom_sf(data = bbox_sf, fill = NA, color = "red", lwd = 1) +  # This draws the bounding box for visual reference.
  coord_sf(xlim = c(bbox_coords["xmin"], bbox_coords["xmax"]), ylim = c(bbox_coords["ymin"], bbox_coords["ymax"]), expand = FALSE) +
  scale_fill_manual(values = custom_colors) +
  theme_void() +
  labs(
    fill = "Cumulative Impact Classification",
    title = "Zoomed Cumulative Impact Distribution on Estonian Coast. Laane-Viru region"
  )

# Define bounding box coordinates of Harju region
bbox_coords <- c(
  xmin = 484714.706, ymin = 6528043.432,  # Bottom-left coordinates
  xmax = 615833.659, ymax = 6633376.468  # Top-right coordinates
)

# Convert to sf object
bbox_sf <- st_as_sfc(st_bbox(bbox_coords, crs = st_crs(hex_subset)))

# Create the zoomed-in plot
ggplot() +
  geom_sf(data = hex_subset, aes(fill = classification), color = "black", lwd = 0.1) +
  geom_sf(data = bbox_sf, fill = NA, color = "red", lwd = 1) +  # This draws the bounding box for visual reference.
  coord_sf(xlim = c(bbox_coords["xmin"], bbox_coords["xmax"]), ylim = c(bbox_coords["ymin"], bbox_coords["ymax"]), expand = FALSE) +
  scale_fill_manual(values = custom_colors) +
  theme_void() +
  labs(
    fill = "Cumulative Impact Classification",
    title = "Zoomed Cumulative Impact Distribution on Estonian Coast. Harju region"
  )

# Define bounding box coordinates of Laane region
bbox_coords <- c(
  xmin = 438716.799, ymin = 6507058.936,  # Bottom-left coordinates
  xmax = 519444.986, ymax = 6572378.111  # Top-right coordinates
)

# Convert to sf object
bbox_sf <- st_as_sfc(st_bbox(bbox_coords, crs = st_crs(hex_subset)))

# Create the zoomed-in plot
ggplot() +
  geom_sf(data = hex_subset, aes(fill = classification), color = "black", lwd = 0.1) +
  geom_sf(data = bbox_sf, fill = NA, color = "red", lwd = 1) +  # This draws the bounding box for visual reference.
  coord_sf(xlim = c(bbox_coords["xmin"], bbox_coords["xmax"]), ylim = c(bbox_coords["ymin"], bbox_coords["ymax"]), expand = FALSE) +
  scale_fill_manual(values = custom_colors) +
  theme_void() +
  labs(
    fill = "Cumulative Impact Classification",
    title = "Zoomed Cumulative Impact Distribution on Estonian Coast. Laane region"
  )

# Define bounding box coordinates of Parnu region
bbox_coords <- c(
  xmin = 457862.705, ymin = 6411654.244,  # Bottom-left coordinates
  xmax = 582975.653, ymax = 6512555.519  # Top-right coordinates
)

# Convert to sf object
bbox_sf <- st_as_sfc(st_bbox(bbox_coords, crs = st_crs(hex_subset)))

# Create the zoomed-in plot
ggplot() +
  geom_sf(data = hex_subset, aes(fill = classification), color = "black", lwd = 0.1) +
  geom_sf(data = bbox_sf, fill = NA, color = "red", lwd = 1) +  # This draws the bounding box for visual reference.
  coord_sf(xlim = c(bbox_coords["xmin"], bbox_coords["xmax"]), ylim = c(bbox_coords["ymin"], bbox_coords["ymax"]), expand = FALSE) +
  scale_fill_manual(values = custom_colors) +
  theme_void() +
  labs(
    fill = "Cumulative Impact Classification",
    title = "Zoomed Cumulative Impact Distribution on Estonian Coast. Parnu region"
  )




