library(readxl)
install.packages("hexbin")
library(hexbin)
library(ggplot2)
library(dplyr)
library(gridExtra)

# Set the working directory to the folder containing the Excel file
setwd("~/Desktop/ThirtyFourtyDocker/ls_metrics_allstat/GN_hexagon_stat")

# Read the data from the Excel file
data <- read_excel("hexagon_impacts_gn.xlsx", sheet = "abandoned_land")

# Create a boxplot with fill by county
ggplot(data, aes(x = county, y = log(aband_perc), fill = county)) +
  geom_boxplot() +
  labs(title = "Abandoned Land by County",
       x = "County",
       y = "Percentage (log scale)",
       fill = "County") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5))

ggplot(data, aes(x = county, y = aband_perc, fill = county)) +
  geom_boxplot() +
  labs(title = "Abandoned Land by County",
       x = "County",
       y = "Percentage",
       fill = "County") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5))

# Create a violin boxplot with fill by county
ggplot(data, aes(x = county, y = log(aband_perc), fill = county)) +
  geom_violin() +
  labs(title = "Abandoned Land by County",
       x = "County",
       y = "Percentage (log scale)",
       fill = "County") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5))

# Create a hexbin plot of abandoned land by county
ggplot(data, aes(x = county, y = aband_ha)) +
  geom_hex(bins = 50) +
  labs(x = "County", y = "Abandoned land (hectares)")


# Calculate the total abandoned land for each county
total_abandoned <- data %>%
  group_by(county) %>%
  summarize(total_aband_ha = sum(aband_ha))

# Create a bar chart of total abandoned land by county
ggplot(total_abandoned, aes(x = county, y = total_aband_ha)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  labs(x = "County", y = "Total abandoned land (hectares)")

# Create a simple and clean bar chart of total abandoned land by county
ggplot(total_abandoned, aes(x = county, y = total_aband_ha, fill = total_aband_ha)) +
  geom_bar(stat = "identity") +
  scale_fill_gradient(low = "#e3f2fd", high = "#0d47a1") +
  labs(x = "County", y = "Total abandoned land (hectares)") +
  theme_minimal() +
  theme(legend.position = "none")


# Set the working directory to the folder containing the Excel file
setwd("~/Desktop/ThirtyFourtyDocker/ls_metrics_allstat/GN_hexagon_stat")

# Read the data from the Excel file
data <- read_excel("hexagon_impacts_gn.xlsx", sheet = "abandoned_land")

# Summarize the data by county for green network loss
data_summary_gn <- data %>%
  group_by(county) %>%
  summarize(total = sum(gn_ha))

# Summarize the data by county for abandoned land
data_summary_abandoned <- data %>%
  group_by(county) %>%
  summarize(total_abandoned = sum(aband_ha))

# create the scatter plots for abandoned land and green network 

p1 <- ggplot(data_summary_gn, aes(x = county, y = total, size = total)) +
  geom_point(color = "darkgreen", alpha = 0.8) +
  labs(title = "Green Network (GN) by County",
       x = "County",
       y = "Total GN (ha)",
       size = "Total GN (ha)") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5)) +
  scale_size(range = c(1, 10))

p2 <- ggplot(data_summary_abandoned, aes(x = county, y = total_abandoned, size = total_abandoned)) +
  geom_point(color = "darkorange", alpha = 0.8) +
  labs(title = "Abandoned Land by County",
       x = "County",
       y = "Total Abandoned Land (ha)",
       size = "Total Abandoned Land (ha)") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5)) +
  scale_size(range = c(1, 10))


# combine the plots
gridExtra::grid.arrange(p1, p2, ncol = 2)



# Get the maximum value between the two y-axis scales
max_y <- max(max(data_summary_abandoned$total_abandoned), max(data_summary_gn$total))

# create the scatter plots for abandoned land and green network 
p1 <- ggplot(data_summary_gn, aes(x = county, y = total, size = total)) +
  geom_point(color = "darkgreen", alpha = 0.8) +
  labs(title = "Green Network (GN) by County",
       x = "County",
       y = "Hectares",
       size = "Total GN (ha)") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5)) +
  scale_size(range = c(1, 10)) +
  scale_y_continuous(limits = c(0, max_y))

p2 <- ggplot(data_summary_abandoned, aes(x = county, y = total_abandoned, size = total_abandoned)) +
  geom_point(color = "darkorange", alpha = 0.8) +
  labs(title = "Abandoned Land by County",
       x = "County",
       y = " Hectares",
       size = "Total Abandoned Land (ha)") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5)) +
  scale_size(range = c(1, 10)) +
  scale_y_continuous(limits = c(0, max_y))

# combine the plots
gridExtra::grid.arrange(p1, p2, ncol = 2, widths = c(4, 3))

scale_x_discrete(labels = c("Abandoned land", "Forest cover loss", "Fragmentation of GI", "Imperviousness", "Fragmentation by roads"))+
  scale_color_manual(labels = c("Abandoned land", "Forest cover loss", "Fragmentation of GI", "Imperviousness", "Fragmentation by roads"), 
                     values = c("#FDE725FF", "#5DC863FF", "#21908CFF", "#440154FF", "#8B0000")) 

ggplot(data_summary_abandoned, aes(x = county, y = total_abandoned, size = total_abandoned)) +
  geom_point(color = "#FDE725FF", alpha = 0.8) +
  labs(title = "Abandoned Land by County",
       x = "County",
       y = " Hectares",
       size = "Total Abandoned Land (ha)") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5)) +
  scale_size(range = c(1, 10)) 

