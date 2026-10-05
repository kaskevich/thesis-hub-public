library(readxl)
library(hexbin)
library(ggplot2)
library(dplyr)
library(gridExtra)

# Set the working directory to the folder containing the Excel file
setwd("~/Desktop/ThirtyFourtyDocker/ls_metrics_allstat/GN_hexagon_stat")

# Read the data from the Excel file
data <- read_excel("hexagon_impacts_gn.xlsx", sheet = "bgi_fragmentation")


# Create a boxplot with fill by county
ggplot(data, aes(x = county, y = log(frag_gi_pr), fill = county)) +
  geom_boxplot() +
  labs(title = "Impact of Fragmentation in Green Infrastructure by County",
       x = "County",
       y = "Percentage (log scale)",
       fill = "County") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5))

ggplot(data, aes(x = county, y = frag_gi_pr, fill = county)) +
  geom_boxplot() +
  labs(title = "Impact of Fragmentation in Green Infrastructure by County",
       x = "County",
       y = "Percentage",
       fill = "County") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5))

# Create a violin boxplot with fill by county
ggplot(data, aes(x = county, y = log(frag_gi_pr), fill = county)) +
  geom_violin() +
  labs(title = "Impact of Fragmentation in Green Infrastructure by County",
       x = "County",
       y = "Percentage (log scale)",
       fill = "County") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5))

# Create a hexbin plot of BGI fragmentation by county
ggplot(data, aes(x = county, y = frag_gi_ha)) +
  geom_hex(bins = 50) +
  labs(x = "County", y = "BGI Fragmentation (hectares)")


# Calculate the total BGI fragmentation for each county
total_frag_gi_ha <- data %>%
  group_by(county) %>%
  summarize(total_frag_gi_ha = sum(frag_gi_ha))

# Create a bar chart of total BGI fragmentation by county
ggplot(total_frag_gi_ha, aes(x = county, y = total_frag_gi_ha)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  labs(x = "County", y = "Total BGI Fragmentation (hectares)")

# Create a bar chart of total BGI fragmentation by county
ggplot(total_frag_gi_ha, aes(x = county, y = total_frag_gi_ha, fill = total_frag_gi_ha)) +
  geom_bar(stat = "identity") +
  scale_fill_gradient(low = "#e3f2fd", high = "#0d47a1") +
  labs(x = "County", y = "Total BGI Fragmentation (hectares)") +
  theme_minimal() +
  theme(legend.position = "none")


# Summarize the data by county for green network loss
data_summary_gn <- data %>%
  group_by(county) %>%
  summarize(total = sum(gn_ha))

# Summarize the data by county for BGI fragmentation
data_summary_frag_gi_ha <- data %>%
  group_by(county) %>%
  summarize(total_frag_gi_ha = sum(frag_gi_ha))

# create the scatter plots for BGI fragmentation and GN
p1 <- ggplot(data_summary_gn, aes(x = county, y = total, size = total)) +
  geom_point(color = "darkgreen", alpha = 0.8) +
  labs(title = "Green Network (GN) by County",
       x = "County",
       y = "Hectares",
       size = "Total GN (ha)") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5)) +
  scale_size(range = c(1, 10))

p2 <- ggplot(data_summary_frag_gi_ha, aes(x = county, y = total_frag_gi_ha, size = total_frag_gi_ha)) +
  geom_point(color = "darkorange", alpha = 0.8) +
  labs(title = " BGI Fragmentation by County",
       x = "County",
       y = "Hectares",
       size = "Total BGI Fragmentation (ha)") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5)) +
  scale_size(range = c(1, 10))

# combine the plots
gridExtra::grid.arrange(p1, p2, ncol = 2)

# Get the maximum value between the two y-axis scales
max_y <- max(max(data_summary_frag_gi_ha$total_frag_gi_ha), max(data_summary_gn$total))

# create the scatter plots for BGI fragmentation and green network 
p1 <- ggplot(data_summary_gn, aes(x = county, y = total, size = total)) +
  geom_point(color = "darkgreen", alpha = 0.8) +
  labs(title = "Green Network (GN) by County",
       x = "County",
       y = "Hectares",
       size = "Total GN (ha)") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5)) +
  scale_size(range = c(1, 10)) +
  scale_y_continuous(limits = c(0, max_y))

p2 <- ggplot(data_summary_frag_gi_ha, aes(x = county, y = total_frag_gi_ha, size = total_frag_gi_ha)) +
  geom_point(color = "darkorange", alpha = 0.8) +
  labs(title = "BGI Fragmentation by County",
       x = "County",
       y = " Hectares",
       size = "Total BGI Fragmentation (ha)") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5)) +
  scale_size(range = c(1, 10)) +
  scale_y_continuous(limits = c(0, max_y))

# combine the plots
gridExtra::grid.arrange(p1, p2, ncol = 2, widths = c(4, 3))


scale_x_discrete(labels = c("Abandoned land", "Forest cover loss", "Fragmentation of GI", "Imperviousness", "Fragmentation by roads"))+
  scale_color_manual(labels = c("Abandoned land", "Forest cover loss", "Fragmentation of GI", "Imperviousness", "Fragmentation by roads"), 
                     values = c("#FDE725FF", "#5DC863FF", "#21908CFF", "#440154FF", "#8B0000")) 

ggplot(data_summary_frag_gi_ha, aes(x = county, y = total_frag_gi_ha, size = total_frag_gi_ha)) +
  geom_point(color = "#21908CFF", alpha = 0.8) +
  labs(title = "GI Fragmentation by County",
       x = "County",
       y = " Hectares",
       size = "Total GI Fragmentation (ha)") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5)) +
  scale_size(range = c(1, 10))