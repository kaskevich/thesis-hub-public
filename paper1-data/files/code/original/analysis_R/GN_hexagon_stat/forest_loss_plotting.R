library(readxl)
library(ggplot2)

# Read data from the Excel file
data <- read_excel("~/Desktop/ThirtyFourtyDocker/ls_metrics_allstat/GN_hexagon_stat/hexagon_by_regions_gi.xlsx", sheet = "hexagon_by_regions_gi")

# Create a boxplot with fill by county
ggplot(data, aes(x = county, y = perc_for, fill = county)) +
  geom_boxplot() +
  labs(title = "Distribution of Forest Loss by County",
       x = "County",
       y = "Percentage",
       fill = "County") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5))

ggplot(data, aes(x = county, y = for_c_norm, fill = county)) +
  geom_boxplot() +
  labs(title = "Distribution of Forest Loss by County",
       x = "County",
       y = "Percentage",
       fill = "County") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5))

ggplot(data, aes(x = county, y = for_c_norm, fill = county)) +
  geom_boxplot() +
  labs(title = "Distribution of Forest Loss by County",
       x = "County",
       y = "Normalised",
       fill = "County") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5))

ggplot(data, aes(x = county, y = log(for_c_norm), fill = county)) +
  geom_boxplot() +
  labs(title = "Distribution of Forest Loss by County",
       x = "County",
       y = "Log",
       fill = "County") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5))

# Create a violin boxplot with fill by county
ggplot(data, aes(x = county, y = log(perc_for), fill = county)) +
  geom_violin() +
  labs(title = "Distribution of Forest Loss by County",
       x = "County",
       y = "Percentage",
       fill = "County") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5))


library(dplyr)

# summarize the data by county
data_summary_gn <- data %>%
  group_by(county) %>%
  summarize(total = sum(gn_ha))

data_summary_forest <- data %>%
  group_by(county) %>%
  summarize(total_loss = sum(perc_for))

# create the scatter plots
p1 <- ggplot(data_summary_gn, aes(x = county, y = total, size = total)) +
  geom_point(color = "darkgreen", alpha = 0.8) +
  labs(title = "Green Network (GN) by County",
       x = "County",
       y = "Percentage",
       size = "Total GN (ha)") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5)) +
  scale_size(range = c(1, 10))

p2 <- ggplot(data_summary_forest, aes(x = county, y = total_loss, size = total_loss)) +
  geom_point(color = "#5DC863FF", alpha = 0.8) +
  labs(title = "Forest cover loss by County",
       x = "County",
       y = "Percentage",
       size = "Total Forest Loss (ha)") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5)) +
  scale_size(range = c(1, 10))

# combine the plots
gridExtra::grid.arrange(p1, p2, ncol = 2)

scale_x_discrete(labels = c("Abandoned land", "Forest cover loss", "Fragmentation of GI", "Imperviousness", "Fragmentation by roads"))+
  scale_color_manual(labels = c("Abandoned land", "Forest cover loss", "Fragmentation of GI", "Imperviousness", "Fragmentation by roads"), 
                     values = c("#FDE725FF", "#5DC863FF", "#21908CFF", "#440154FF", "#8B0000")) 


ggplot(data_summary_forest, aes(x = county, y = total_loss, size = total_loss)) +
  geom_point(color = "#5DC863FF", alpha = 0.8) +
  labs(title = "Forest cover loss by County",
       x = "County",
       y = "Percentage",
       size = "Total Forest Loss (ha)") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5)) +
  scale_size(range = c(1, 10))



data_summary_gn




















