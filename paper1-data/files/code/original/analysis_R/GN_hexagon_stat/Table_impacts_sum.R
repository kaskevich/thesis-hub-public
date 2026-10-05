library(ggplot2)
library(reshape2)
library(xfun)
library(kableExtra)
library(dplyr)
library(readxl)

# Load data
impacts_data <- read_excel("~/Desktop/ThirtyFourtyDocker/ls_metrics_allstat/GN_hexagon_stat/hexagon_by_regions_gi.xlsx", sheet = "hexagon_by_regions_gi")

# Create data summaries
data_summary_forest <- impacts_data %>%
  group_by(county) %>%
  summarize(total_loss = sum(forest_met))

data_summary_abandoned <- impacts_data %>%
  group_by(county) %>%
  summarize(total_abandoned = sum(aband_met))

data_summary_impervious <- impacts_data %>%
  group_by(county) %>%
  summarize(total_impervious = sum(imperv_met))

data_summary_roads <- impacts_data %>%
  group_by(county) %>%
  summarize(total_roads = sum(road_lengh))

data_summary_frag_gi<- impacts_data %>%
  group_by(county) %>%
  summarize(total_frag_gi = sum(frag_gi_m))

# Combine data summaries into one table
data_summary_combined <- merge(data_summary_abandoned, data_summary_forest, by = "county")
data_summary_combined <- merge(data_summary_combined, data_summary_impervious, by = "county")
data_summary_combined <- merge(data_summary_combined, data_summary_roads, by = "county")
data_summary_combined <- merge(data_summary_combined, data_summary_frag_gi, by = "county")

# Melt data for heatmap visualization
data_summary_melted <- melt(data_summary_combined, id.vars = "county")

# Create heatmap
ggplot(data_summary_melted, aes(x = county, y = variable, fill = value)) +
  geom_tile(color = "white") +
  scale_fill_gradient(low = "#FDE725FF", high = "#8B0000") +
  labs(title = "Total Impacts by County",
       x = "County",
       y = "Impact Category",
       fill = "Total Area (meters)") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1),
        axis.title.y = element_text(margin = margin(t = 0, r = 20, b = 0, l = 0)),
        plot.title = element_text(hjust = 0.5))


# Define new variable names
new_names <- c("Abandoned land", "Forest cover loss", "Fragmentation of GI", 
               "Imperviousness", "Fragmentation by roads")

# Create heatmap with updated y-axis labels
ggplot(data_summary_melted, aes(x = county, y = variable, fill = value)) +
  geom_tile(color = "white") +
  scale_fill_gradient(low = "#FDE725FF", high = "#8B0000") +
  scale_y_discrete(labels = new_names) +  # Set new variable names for y-axis
  labs(title = "Total Impacts by County",
       x = "County",
       y = "Impact Category",
       fill = "Total Area (meters)") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1),
        axis.title.y = element_text(margin = margin(t = 0, r = 20, b = 0, l = 0)),
        plot.title = element_text(hjust = 0.5))

# Display table
kable(data_summary_combined, format = "html") %>%
  kable_styling(bootstrap_options = "striped", full_width = F)

# Join data summaries into one table
data_summary_combined <- left_join(data_summary_forest, data_summary_abandoned, by = "county")
data_summary_combined <- left_join(data_summary_combined, data_summary_impervious, by = "county")
data_summary_combined <- left_join(data_summary_combined, data_summary_roads, by = "county")
data_summary_combined <- left_join(data_summary_combined, data_summary_frag_gi, by = "county")

# Rename columns
colnames(data_summary_combined)[colnames(data_summary_combined) == "total_loss"] <- "Total Forest Loss in meters"
colnames(data_summary_combined)[colnames(data_summary_combined) == "total_abandoned"] <- "Total Abandoned Land in meters"
colnames(data_summary_combined)[colnames(data_summary_combined) == "total_impervious"] <- "Total Impervious Area in meters"
colnames(data_summary_combined)[colnames(data_summary_combined) == "total_roads"] <- "Total Fragmentation by Roads Area in meters"
colnames(data_summary_combined)[colnames(data_summary_combined) == "total_frag_gi"] <- "Total GI Fragmentation Area in meters"
colnames(data_summary_combined)[colnames(data_summary_combined) == "county"] <- "Estonian county"

# Display table
kable(data_summary_combined, format = "html") %>%
  kable_styling(bootstrap_options = "striped", full_width = F)

# Create the table
table_html <- data_summary_combined %>%
  kable(format = "html", align = "c") %>%
  kable_styling(full_width = FALSE, bootstrap_options = "striped") %>%
  scroll_box(width = "100%", height = "500px")








