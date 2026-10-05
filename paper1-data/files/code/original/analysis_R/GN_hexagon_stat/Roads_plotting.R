library(readxl)
library(hexbin)
library(ggplot2)
library(dplyr)
library(gridExtra)

# Set the working directory to the folder containing the Excel file
setwd("~/Desktop/ThirtyFourtyDocker/ls_metrics_allstat/GN_hexagon_stat")

# Read the data from the Excel file
data <- read_excel("hexagon_impacts_gn.xlsx", sheet = "roads")


# Create a boxplot with fill by county
ggplot(data, aes(x = county, y = log(road_frac), fill = county)) +
  geom_boxplot() +
  labs(title = "Roads impact on Green Infrastructure by County",
       x = "County",
       y = "Roads length by GN area (m/m2) (log scale)",
       fill = "County") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5))

ggplot(data, aes(x = county, y = road_frac, fill = county)) +
  geom_boxplot() +
  labs(title = "Roads impact on Green Infrastructure by County",
       x = "County",
       y = "Roads length by GN area (m/m2)",
       fill = "County") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5))

# Create a violin boxplot with fill by county
ggplot(data, aes(x = county, y = log(road_frac), fill = county)) +
  geom_violin() +
  labs(title = "Roads impact on Green Infrastructure by County",
       x = "County",
       y = "Roads length by GN area (m/m2) (log scale)",
       fill = "County") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5))

# Create a hexbin plot of roads by county
ggplot(data, aes(x = county, y = roads_ha)) +
  geom_hex(bins = 50) +
  labs(x = "County", y = "Fragmentation by roads (hectares)")


# Calculate the total roads for each county
total_roads <- data %>%
  group_by(county) %>%
  summarize(total_roads_ha = sum(roads_ha))

# Create a bar chart of total roads by county
ggplot(total_roads, aes(x = county, y = total_roads_ha)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  labs(x = "County", y = "Total Fragmentation by roads (hectares)")

# Create a bar chart of total roads by county
ggplot(total_roads, aes(x = county, y = total_roads_ha, fill = total_roads_ha)) +
  geom_bar(stat = "identity") +
  scale_fill_gradient(low = "#e3f2fd", high = "#0d47a1") +
  labs(x = "County", y = "Total Fragmentation by roads (hectares)") +
  theme_minimal() +
  theme(legend.position = "none")


# Summarize the data by county for green network loss
data_summary_gn <- data %>%
  group_by(county) %>%
  summarize(total = sum(gn_ha))

# Summarize the data by county for roads
data_summary_roads <- data %>%
  group_by(county) %>%
  summarize(total_roads = sum(roads_ha))

# create the scatter plots for roads and GN

p1 <- ggplot(data_summary_gn, aes(x = county, y = total, size = total)) +
  geom_point(color = "darkgreen", alpha = 0.8) +
  labs(title = "Green Network (GN) by County",
       x = "County",
       y = "Hectares",
       size = "Total GN (ha)") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5)) +
  scale_size(range = c(1, 10))

p2 <- ggplot(data_summary_roads, aes(x = county, y = total_roads, size = total_roads)) +
  geom_point(color = "darkorange", alpha = 0.8) +
  labs(title = "Fragmentation by roads by County",
       x = "County",
       y = "Hectares",
       size = "Total Fragmentation by roads (ha)") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5)) +
  scale_size(range = c(1, 10))

# combine the plots
gridExtra::grid.arrange(p1, p2, ncol = 2)

# Get the maximum value between the two y-axis scales
max_y <- max(max(data_summary_roads$total_roads), max(data_summary_gn$total))

# create the scatter plots for roads and green network 
p1 <- ggplot(data_summary_gn, aes(x = county, y = total, size = total)) +
  geom_point(color = "darkgreen", alpha = 0.8) +
  labs(title = "Green Network (GN) by County",
       x = "County",
       y = "Hectares",
       size = "Total GN (ha)") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5)) +
  scale_size(range = c(1, 10)) +
  scale_y_continuous(limits = c(0, max_y))

p2 <- ggplot(data_summary_roads, aes(x = county, y = total_roads, size = total_roads)) +
  geom_point(color = "darkorange", alpha = 0.8) +
  labs(title = "Fragmentation by roads by County",
       x = "County",
       y = " Hectares",
       size = "Total Fragmentation by roads (ha)") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5)) +
  scale_size(range = c(1, 10)) +
  scale_y_continuous(limits = c(0, max_y))

# combine the plots
gridExtra::grid.arrange(p1, p2, ncol = 2, widths = c(4, 3))

scale_x_discrete(labels = c("Abandoned land", "Forest cover loss", "Fragmentation of GI", "Imperviousness", "Fragmentation by roads"))+
  scale_color_manual(labels = c("Abandoned land", "Forest cover loss", "Fragmentation of GI", "Imperviousness", "Fragmentation by roads"), 
                     values = c("#FDE725FF", "#5DC863FF", "#21908CFF", "#440154FF", "#8B0000")) 

ggplot(data_summary_roads, aes(x = county, y = total_roads, size = total_roads)) +
  geom_point(color = "#8B0000", alpha = 0.8) +
  labs(title = "Fragmentation by roads by County",
       x = "County",
       y = " Hectares",
       size = "Total Fragmentation by roads (ha)") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5)) +
  scale_size(range = c(1, 10)) 
  




