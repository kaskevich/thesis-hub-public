library(readxl)
library(hexbin)
library(ggplot2)
library(dplyr)
library(gridExtra)

# Set the working directory to the folder containing the Excel file
setwd("~/Desktop/ThirtyFourtyDocker/ls_metrics_allstat/GN_hexagon_stat")

# Read the data from the Excel file
data <- read_excel("hexagon_impacts_gn.xlsx", sheet = "imperviousness")

# Create a hexbin plot of imperviousness by county
ggplot(data, aes(x = county, y = imperv_ha)) +
  geom_hex(bins = 50) +
  labs(x = "County", y = "Imperviousness (hectares)")


# Calculate the total imperviousness for each county
total_impervious <- data %>%
  group_by(county) %>%
  summarize(total_imperv_ha = sum(imperv_ha))

# Create a bar chart of total imperviousness by county
ggplot(total_impervious, aes(x = county, y = total_imperv_ha)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  labs(x = "County", y = "Total Imperviousness (hectares)")

# Create a bar chart of total Imperviousness by county
ggplot(total_impervious, aes(x = county, y = total_imperv_ha, fill = total_imperv_ha)) +
  geom_bar(stat = "identity") +
  scale_fill_gradient(low = "#e3f2fd", high = "#0d47a1") +
  labs(x = "County", y = "Total Imperviousness (hectares)") +
  theme_minimal() +
  theme(legend.position = "none")


# Summarize the data by county for green network loss
data_summary_gn <- data %>%
  group_by(county) %>%
  summarize(total = sum(gn_ha))

# Summarize the data by county for Imperviousness
data_summary_impervious <- data %>%
  group_by(county) %>%
  summarize(total_impervious = sum(imperv_ha))

# create the scatter plots for Imperviousness and GN

p1 <- ggplot(data_summary_gn, aes(x = county, y = total, size = total)) +
  geom_point(color = "darkgreen", alpha = 0.8) +
  labs(title = "Green Network (GN) by County",
       x = "County",
       y = "Hectares",
       size = "Total GN (ha)") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5)) +
  scale_size(range = c(1, 10))

p2 <- ggplot(data_summary_impervious, aes(x = county, y = total_impervious, size = total_impervious)) +
  geom_point(color = "darkorange", alpha = 0.8) +
  labs(title = "Imperviousness by County",
       x = "County",
       y = "Hectares",
       size = "Total Imperviousness (ha)") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5)) +
  scale_size(range = c(1, 10))

# combine the plots
gridExtra::grid.arrange(p1, p2, ncol = 2)

# Get the maximum value between the two y-axis scales
max_y <- max(max(data_summary_impervious$total_impervious), max(data_summary_gn$total))

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

p2 <- ggplot(data_summary_impervious, aes(x = county, y = total_impervious, size = total_impervious)) +
  geom_point(color = "darkorange", alpha = 0.8) +
  labs(title = "Imperviousness by County",
       x = "County",
       y = " Hectares",
       size = "Total Imperviousness(ha)") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5)) +
  scale_size(range = c(1, 10)) +
  scale_y_continuous(limits = c(0, max_y))

# combine the plots
gridExtra::grid.arrange(p1, p2, ncol = 2, widths = c(4, 3))