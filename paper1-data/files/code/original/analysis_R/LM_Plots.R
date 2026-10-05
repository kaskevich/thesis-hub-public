library(ggplot2)
library(dplyr)
library(gridExtra)
library(grid)

# Read the data
data <- read.csv('~/Desktop/ThirtyFourtyDocker/ls_metrics_allstat/LSM_stat/landscape_statistics.csv')

# Define the color with opacity
color <- rgb(144/255, 238/255, 144/255, 0.5) # Light green with 50% opacity

# Create individual plots with specified aesthetics
plot_largest_patch <- ggplot(data, aes(x=region, y=largest_patch_ha)) +
  geom_bar(stat='identity', fill=color) + theme_minimal() +
  labs(title='Estonian Coastal Regions - Largest Patch Area', y='Largest Patch (ha)', x="none") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1), legend.position = "none")

plot_mean_patch <- ggplot(data, aes(x=region, y=mean_patch_ha)) +
  geom_bar(stat='identity', fill=color) + theme_minimal() +
  labs(title='Estonian Coastal Regions - Mean Patch Area', y='Mean Patch (ha)', x="none") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1), legend.position = "none")

plot_patch_index <- ggplot(data, aes(x=region, y=patch_index)) +
  geom_bar(stat='identity', fill=color) + theme_minimal() +
  labs(title='Estonian Coastal Regions - Largest Patch Index', y='Largest Patch Index', x="none") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1), legend.position = "none")

plot_shape_index <- ggplot(data, aes(x=region, y=shape_index)) +
  geom_bar(stat='identity', fill=color) + theme_minimal() +
  labs(title='Estonian Coastal Regions - Largest Shape Index', y='Largest Shape Index', x="none") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1), legend.position = "none")

plot_patch_density <- ggplot(data, aes(x=region, y=patch_density_per_sq_km)) +
  geom_bar(stat='identity', fill=color) + theme_minimal() +
  labs(title='Estonian Coastal Regions - Patch Density', y='Patch Density (per sq km)', x="none") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1), legend.position = "none")

# Combine the plots into a single image with a title
combined_plot <- grid.arrange(plot_largest_patch, plot_mean_patch, plot_patch_index, plot_shape_index, plot_patch_density, 
                              ncol=2, top=textGrob("Comparison of Landscape Metrics Across Estonian Coastal Regions", 
                                                   gp=gpar(fontsize=14, fontface="plain", lineheight=2.8)))

# Save the combined plot
ggsave('combined_landscape_metrics.png', combined_plot, width = 8, height = 20)
