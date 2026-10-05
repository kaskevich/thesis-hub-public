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
library(ggspatial)

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

# Compute p-values
p_values <- 2 * (1 - pnorm(abs(localG.values)))

# Classify Results Based on Local G and p-values
hex_subset$classification <- dplyr::case_when(
  localG.values > 0 & p_values <= 0.01 ~ "Very High Impact",
  localG.values > 0 & p_values <= 0.05 ~ "High Impact",
  localG.values > 0 & p_values <= 0.1  ~ "Moderate Impact",
  localG.values < 0 & p_values <= 0.01 ~ "Very Low Impact",
  localG.values < 0 & p_values <= 0.05 ~ "Low Impact",
  localG.values < 0 & p_values <= 0.1  ~ "Slightly Low Impact",
  TRUE ~ "Neutral Impact"
)

# Remove 'Unclassified' entries
hex_subset <- hex_subset %>%
  filter(classification != "Unclassified")

# Convert 'classification' into a Factor for Plotting
hex_subset$classification <- factor(
  hex_subset$classification,
  levels = c("Very High Impact", "High Impact", "Moderate Impact",
             "Neutral Impact", "Slightly Low Impact", "Low Impact", 
             "Very Low Impact")
)

# Define Custom Colors for the Plot
custom_colors <- c(
  "Very High Impact" = "darkred",
  "High Impact" = "red",
  "Moderate Impact" = "lightsalmon",
  "Neutral Impact" = "white",
  "Slightly Low Impact" = "#ADD8E6",
  "Low Impact" = "dodgerblue",
  "Very Low Impact" = "midnightblue"
)

# Highlight strongest hot-spot clusters
strongest_hotspots <- hex_subset %>%
  filter(classification == "Very High Impact")

# Create the Main Plot using ggplot2
main_plot <- ggplot() +
  geom_sf(data = hex_subset, aes(fill = classification), color = NA) +  # Make outline color transparent
  geom_sf(data = strongest_hotspots, fill = "black", size = 0.5) +  # Highlight strongest hotspots
  scale_fill_manual(values = custom_colors) +
  theme_void() +
  labs(
    fill = "Cumulative Impact Classification",
    title = "Cumulative Impact Distribution on Estonian Coast"
  ) +
  theme(
    plot.title = element_text(hjust = 0.5, size = 20),  # Center and size the title
    legend.position = "right",
    legend.title = element_text(size = 12),
    legend.text = element_text(size = 10)
  ) +
  annotation_scale(location = "bl", width_hint = 0.5) +
  annotation_north_arrow(location = "tl", which_north = "true", 
                         pad_x = unit(0.5, "in"), pad_y = unit(0.5, "in"),
                         style = north_arrow_fancy_orienteering)

# Print the plot
print(main_plot)





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
library(ggspatial)

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

# Compute p-values
p_values <- 2 * (1 - pnorm(abs(localG.values)))

# Classify Results Based on Local G and p-values
hex_subset$classification <- dplyr::case_when(
  localG.values > 0 & p_values <= 0.01 ~ "Very High Impact",
  localG.values > 0 & p_values <= 0.05 ~ "High Impact",
  localG.values > 0 & p_values <= 0.1  ~ "Moderate Impact",
  localG.values < 0 & p_values <= 0.01 ~ "Very Low Impact",
  localG.values < 0 & p_values <= 0.05 ~ "Low Impact",
  localG.values < 0 & p_values <= 0.1  ~ "Slightly Low Impact",
  TRUE ~ "Neutral Impact"
)

# Remove 'Unclassified' entries
hex_subset <- hex_subset %>%
  filter(classification != "Unclassified")

# Convert 'classification' into a Factor for Plotting
hex_subset$classification <- factor(
  hex_subset$classification,
  levels = c("Very High Impact", "High Impact", "Moderate Impact",
             "Neutral Impact", "Slightly Low Impact", "Low Impact", 
             "Very Low Impact")
)

# Define Custom Colors for the Plot
custom_colors <- c(
  "Very High Impact" = "#8B0000",
  "High Impact" = "red",
  "Moderate Impact" = "lightsalmon",
  "Neutral Impact" = "white",
  "Slightly Low Impact" = "#ADD8E6",
  "Low Impact" = "dodgerblue",
  "Very Low Impact" = "midnightblue"
)

# Create the Main Plot using ggplot2
main_plot <- ggplot(hex_subset, aes(fill = classification)) +
  geom_sf(color = NA) +  # Make outline color transparent
  scale_fill_manual(values = custom_colors) +
  theme_minimal() +
  labs(
    fill = "Cumulative Impact Classification",
    title = "Cumulative Impact Distribution on Estonian Coast"
  ) +
  theme(
    plot.title = element_text(hjust = 0.5, size = 20),  # Center and size the title
    legend.position = "right",
    legend.title = element_text(size = 12),
    legend.text = element_text(size = 10)
  ) +
  annotation_scale(location = "bl", width_hint = 0.5, pad_y = unit(0.3, "in")) +
  annotation_north_arrow(location = "tl", which_north = "true", 
                         pad_x = unit(0.5, "in"), pad_y = unit(0.5, "in"),
                         style = north_arrow_minimal()) +
  coord_sf(expand = TRUE) +  # Show coordinate grid
  theme(
    legend.position = "left",
    legend.key.size = unit(1, "lines"),
    legend.title = element_text(size = 14),
    legend.text = element_text(size = 12)
  )

# Print the plot
print(main_plot)












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
library(ggspatial)

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

# Compute p-values
p_values <- 2 * (1 - pnorm(abs(localG.values)))

# Classify Results Based on Local G and p-values
hex_subset$classification <- dplyr::case_when(
  localG.values > 0 & p_values <= 0.01 ~ "Very High Impact",
  localG.values > 0 & p_values <= 0.05 ~ "High Impact",
  localG.values > 0 & p_values <= 0.1  ~ "Moderate Impact",
  localG.values < 0 & p_values <= 0.01 ~ "Very Low Impact",
  localG.values < 0 & p_values <= 0.05 ~ "Low Impact",
  localG.values < 0 & p_values <= 0.1  ~ "Slightly Low Impact",
  TRUE ~ "Neutral Impact"
)

# Remove 'Unclassified' entries
hex_subset <- hex_subset %>%
  filter(classification != "Unclassified")

# Convert 'classification' into a Factor for Plotting
hex_subset$classification <- factor(
  hex_subset$classification,
  levels = c("Very High Impact", "High Impact", "Moderate Impact",
             "Neutral Impact", "Slightly Low Impact", "Low Impact", 
             "Very Low Impact")
)

# Define Custom Colors for the Plot
custom_colors <- c(
  "Very High Impact" = "#8B0000",
  "High Impact" = "red",
  "Moderate Impact" = "lightsalmon",
  "Neutral Impact" = "white",
  "Slightly Low Impact" = "#ADD8E6",
  "Low Impact" = "dodgerblue",
  "Very Low Impact" = "midnightblue"
)

# Create the Main Plot using ggplot2
main_plot <- ggplot(hex_subset, aes(fill = classification)) +
  geom_sf(color = NA) +  # Make outline color transparent
  scale_fill_manual(values = custom_colors) +
  theme_minimal() +
  labs(
    fill = "Impact Classification",
    title = "Cumulative Impact Distribution on Estonian Coast"
  ) +
  theme(
    plot.title = element_text(hjust = 0.5, size = 20),  # Center and size the title
    legend.position = c(0.9, 0.2),  # Position legend in the bottom right corner
    legend.title = element_text(size = 16),
    legend.text = element_text(size = 14)
  ) +
  annotation_scale(location = "bl", width_hint = 0.5, pad_y = unit(0.3, "in")) +
  annotation_north_arrow(location = "tl", which_north = "true", 
                         pad_x = unit(0.5, "in"), pad_y = unit(0.5, "in"),
                         style = north_arrow_minimal()) +
  coord_sf(expand = TRUE) +  # Show coordinate grid
  theme(
    legend.key.size = unit(1, "lines"),
    legend.title = element_text(size = 14),
    legend.text = element_text(size = 14)
  )

# Print the plot
print(main_plot)








