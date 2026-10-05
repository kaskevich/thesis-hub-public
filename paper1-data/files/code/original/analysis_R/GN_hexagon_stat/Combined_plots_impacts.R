library(dplyr)
library(tidyr)
library(ggplot2)
library(tidyverse)
library(readxl)
library(knitr)
library(kableExtra)

# Read the data from the Excel file
data <- read_excel("~/Desktop/ThirtyFourtyDocker/ls_metrics_allstat/GN_hexagon_stat/hexagon_by_regions_gi.xlsx", sheet = "hexagon_by_regions_gi")

# Calculate the total meters for each column except "county" grouped by "county"
result <- data %>%
  group_by(county) %>%
  summarize(
    GN_met_total = sum(GN_met),
    forest_met_total = sum(forest_met),
    aband_met_total = sum(aband_met),
    imperv_met_total = sum(imperv_met),
    road_lengh_total = sum(road_lengh),
    frag_gi_m_total = sum(frag_gi_m)
  )

# Conversion factor from square meters to hectares
sqm_to_hectares <- 1 / 10000

# Calculate the totals in hectares and roads in fraction of meters
result <- result %>%
  mutate(
    Coastal_BGI_Total_Ha = GN_met_total * sqm_to_hectares,
    Forest_Loss_Total_Ha = forest_met_total * sqm_to_hectares,
    Abandonedment_Total_Ha = aband_met_total * sqm_to_hectares,
    Imperviousness_Total_Ha = imperv_met_total * sqm_to_hectares,
    Fragmetation_Roads_Total_KM = road_lengh_total/ 1000,
    Fragmetation_BGI_Total_Ha = frag_gi_m_total * sqm_to_hectares
  )

# Define the data for EE_Coast_3km_Total_Ha by region
region_data <- c(
  "Harju maakond" = 432672.3206,
  "Hiiu maakond" = 103257.7929,
  "Ida-Viru maakond" = 297171.5578,
  "Laane maakond" = 181580.9262,
  "Laane-Viru maakond" = 369574.5818,
  "Parnu maakond" = 541938.7997,
  "Saare maakond" = 293799.1351,
  "Tallinn maakond" = 19397.6814
)

# Add the new column before Coastal_BGI_Total_Ha
result <- result %>%
  mutate(EE_Coast_3km_Total_Ha = region_data[as.character(county)])

# Reorder the columns to place EE_Coast_3km_Total_Ha before Coastal_BGI_Total_Ha
result <- result %>%
  select(county, EE_Coast_3km_Total_Ha, Coastal_BGI_Total_Ha, Forest_Loss_Total_Ha, Abandonedment_Total_Ha, Imperviousness_Total_Ha, Fragmetation_Roads_Total_KM, Fragmetation_BGI_Total_Ha)


# Print the updated table
table_output <- result %>%
  kable() %>%
  kable_styling(full_width = FALSE)

table_output

library(ggplot2)
library(dplyr)

# Create a data frame for plotting
plot_data <- result %>%
  select(county, Coastal_BGI_Total_Ha, Forest_Loss_Total_Ha, Abandonedment_Total_Ha, Imperviousness_Total_Ha, Fragmetation_Roads_Total_KM, Fragmetation_BGI_Total_Ha)

# Function to create individual plots
create_individual_plot <- function(data, y_variable, y_label, title) {
  ggplot(data, aes(x = county, y = .data[[y_variable]])) +
    geom_bar(fill = "blue", stat = "identity", position = "dodge") +
    labs(
      x = "County",
      y = y_label,
      title = title
    ) +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
}

# Create individual plots for each variable
coastal_bgi_plot <- create_individual_plot(plot_data, "Coastal_BGI_Total_Ha", "Hectares", "Coastal BGI Total")
forest_loss_plot <- create_individual_plot(plot_data, "Forest_Loss_Total_Ha", "Hectares", "Forest Loss Total")
abandonedment_plot <- create_individual_plot(plot_data, "Abandonedment_Total_Ha", "Hectares", "Abandonedment Total")
imperviousness_plot <- create_individual_plot(plot_data, "Imperviousness_Total_Ha", "Hectares", "Imperviousness Total")
roads_plot <- create_individual_plot(plot_data, "Fragmetation_Roads_Total_KM", "Kilometers", "Fragmentation by Roads Total")
bgi_plot <- create_individual_plot(plot_data, "Fragmetation_BGI_Total_Ha", "Hectares", "Fragmentation BGI Total")

# Arrange and display the plots
library(gridExtra)
grid.arrange(coastal_bgi_plot, forest_loss_plot, abandonedment_plot, imperviousness_plot, roads_plot, bgi_plot, ncol = 2)


library(ggplot2)
library(dplyr)

# Create a data frame for plotting
plot_data <- result %>%
  select(county, Coastal_BGI_Total_Ha, Forest_Loss_Total_Ha, Abandonedment_Total_Ha, Imperviousness_Total_Ha, Fragmetation_Roads_Total_KM, Fragmetation_BGI_Total_Ha)

# Function to create individual plots
create_individual_plot <- function(data, y_variable, y_label, title) {
  ggplot(data, aes(x = reorder(county, .data[[y_variable]]), y = .data[[y_variable]], fill = county)) +
    geom_bar(stat = "identity") +
    labs(
      x = "County",
      y = y_label,
      title = title
    ) +
    scale_fill_brewer(palette = "Set3") +  # Color bars by county
    theme_minimal() +
    theme(
      axis.text.x = element_text(angle = 45, hjust = 1),
      legend.position = "none"
    )
}

# Create individual plots for each variable
coastal_bgi_plot <- create_individual_plot(plot_data, "Coastal_BGI_Total_Ha", "Hectares", "Coastal BGI Total")
forest_loss_plot <- create_individual_plot(plot_data, "Forest_Loss_Total_Ha", "Hectares", "Forest Loss Total")
abandonedment_plot <- create_individual_plot(plot_data, "Abandonedment_Total_Ha", "Hectares", "Abandonedment Total")
imperviousness_plot <- create_individual_plot(plot_data, "Imperviousness_Total_Ha", "Hectares", "Imperviousness Total")
roads_plot <- create_individual_plot(plot_data, "Fragmetation_Roads_Total_KM", "Kilometers", "Fragmentation by Roads Total")
bgi_plot <- create_individual_plot(plot_data, "Fragmetation_BGI_Total_Ha", "Hectares", "Fragmentation BGI Total")


library(patchwork)

# Combine the plots into a single plot
combined_plots <- (coastal_bgi_plot | forest_loss_plot) / 
  (abandonedment_plot | imperviousness_plot) / 
  (roads_plot | bgi_plot) & 
  plot_annotation(title = "Comparison of Impacts on the Esonian Coastal BGI by County")

# Display the combined plot
combined_plots

# Load the required libraries
library(tidyr)
library(ggplot2)

# Impacts data plotting
data <- data.frame(
  County = c("Harju maakond", "Hiiu maakond", "Ida-Viru maakond", "Laane maakond", "Laane-Viru maakond", "Parnu maakond", "Saare maakond", "Tallinn maakond"),
  EE_Coast_3km_Total_Ha = c(432672.32, 103257.79, 297171.56, 181580.93, 369574.58, 541938.80, 293799.14, 19397.68),
  Coastal_BGI_Total_Ha = c(39884.36, 42466.12, 8502.00, 35486.16, 20248.40, 41612.40, 95069.16, 6634.64),
  Forest_Loss_Total_Ha = c(1435.00, 2114.92, 337.92, 1479.92, 779.12, 1644.76, 3659.64, 156.28),
  Abandonedment_Total_Ha = c(1651.68, 1823.92, 6.56, 3074.36, 455.16, 2568.60, 6858.32, 57.44),
  Imperviousness_Total_Ha = c(2.52, 0.84, 7.00, 0.36, 4.28, 3.44, 1.92, 5.40),
  Fragmetation_Roads_Total_M = c(313714.6, 343381.8, 118944.9, 165537.5, 138219.1, 257731.2, 582898.4, 149910.1),
  Fragmetation_BGI_Total_Ha = c(2626.0710, 1329.8013, 1988.7960, 1373.1218, 550.5647, 3985.7246, 3926.5198, 1224.5289)
)

# Reshape the data to long format
data_long <- pivot_longer(data, -County, names_to = "Variable", values_to = "Value")

# Create a heatmap
heatmap_plot <- ggplot(data_long, aes(x = County, y = Variable, fill = Value)) +
  geom_tile() +
  scale_fill_gradient(low = "lightblue", high = "darkblue") +
  labs(title = "Impact on Green Infrastructure in Hectares", x = "County", y = "Variable") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Display the heatmap
print(heatmap_plot)


# Load the required libraries
library(tidyr)
library(ggplot2)

# Impacts data in hectares plotting
data <- data.frame(
  County = c("Harju maakond", "Hiiu maakond", "Ida-Viru maakond", "Laane maakond", "Laane-Viru maakond", "Parnu maakond", "Saare maakond", "Tallinn maakond"),
  Forest_Loss_Total_Ha = c(1435.00, 2114.92, 337.92, 1479.92, 779.12, 1644.76, 3659.64, 156.28),
  Abandonedment_Total_Ha = c(1651.68, 1823.92, 6.56, 3074.36, 455.16, 2568.60, 6858.32, 57.44),
  Imperviousness_Total_Ha = c(2.52, 0.84, 7.00, 0.36, 4.28, 3.44, 1.92, 5.40),
  Fragmetation_BGI_Total_Ha = c(2626.0710, 1329.8013, 1988.7960, 1373.1218, 550.5647, 3985.7246, 3926.5198, 1224.5289)
)

# Reshape the data to long format
data_long <- pivot_longer(data, -County, names_to = "Variable", values_to = "Value")

# Create a heatmap
heatmap_plot <- ggplot(data_long, aes(x = County, y = Variable, fill = Value)) +
  geom_tile() +
  geom_text(aes(label = round(Value, 2)), vjust = 1) +  # Display numeric values on the heatmap
  scale_fill_gradient(low = "lightyellow", high = "red") +  # Adjust color scale from light yellow to red
  labs(title = "Impact on Green Infrastructure in Hectares", x = "County", y = "Variable") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Display the heatmap
print(heatmap_plot)


# Fragmentation by roads heatmap plotting 
data_roads <- data.frame(
  County = c("Harju maakond", "Hiiu maakond", "Ida-Viru maakond", "Laane maakond", "Laane-Viru maakond", "Parnu maakond", "Saare maakond", "Tallinn maakond"),
  Fragmetation_Roads_Total_M = c(313714.6, 343381.8, 118944.9, 165537.5, 138219.1, 257731.2, 582898.4, 149910.1)
)

# Convert meters to kilometers
data_roads$Fragmetation_Roads_Total_Km <- data_roads$Fragmetation_Roads_Total_M / 1000

# Reshape the data to long format
data_long <- pivot_longer(data_roads, -County, names_to = "Variable", values_to = "Value")

# Select only the kilometer values
data_long_km <- data_long[data_long$Variable == "Fragmetation_Roads_Total_Km", ]

# Create a heatmap
heatmap_plot <- ggplot(data_long_km, aes(x = County, y = Variable, fill = Value)) +
  geom_tile() +
  geom_text(aes(label = round(Value, 2)), vjust = 1) +  # Display numeric values on the heatmap
  scale_fill_gradient(low = "lightyellow", high = "red") +  # Adjust color scale from light yellow to red
  labs(title = "Impact on Green Infrastructure in Kilometers", x = "County", y = "Variable") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Display the heatmap
print(heatmap_plot)

# Load the required libraries
library(tidyr)
library(ggplot2)

# BGI data plotting
data <- data.frame(
  County = c("Harju maakond", "Hiiu maakond", "Ida-Viru maakond", "Laane maakond", "Laane-Viru maakond", "Parnu maakond", "Saare maakond", "Tallinn maakond"),
  Coastal_BGI_Total_Ha = c(39884.36, 42466.12, 8502.00, 35486.16, 20248.40, 41612.40, 95069.16, 6634.64))

# Reshape the data to long format
data_long <- pivot_longer(data, -County, names_to = "Variable", values_to = "Value")

# Create a heatmap
heatmap_plot <- ggplot(data_long, aes(x = County, y = Variable, fill = Value)) +
  geom_tile() +
  geom_text(aes(label = round(Value, 2)), vjust = 1) +  # Display numeric values on the heatmap
  scale_fill_gradient(low = "lightyellow", high = "green") +  # Adjust color scale from light yellow to red
  labs(title = "Impact on Green Infrastructure in Hectares", x = "County", y = "Variable") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Display the heatmap
print(heatmap_plot)


# Impact data
impact_data <- data.frame(
  County = c("Harju maakond", "Hiiu maakond", "Ida-Viru maakond", "Laane maakond", "Laane-Viru maakond", "Parnu maakond", "Saare maakond", "Tallinn maakond"),
  Forest_Loss_Total_Ha = c(1435.00, 2114.92, 337.92, 1479.92, 779.12, 1644.76, 3659.64, 156.28),
  Abandonedment_Total_Ha = c(1651.68, 1823.92, 6.56, 3074.36, 455.16, 2568.60, 6858.32, 57.44),
  Fragmetation_BGI_Total_Ha = c(2626.0710, 1329.8013, 1988.7960, 1373.1218, 550.5647, 3985.7246, 3926.5198, 1224.5289),
  Fragmetation_Roads_Total_M = c(313714.6, 343381.8, 118944.9, 165537.5, 138219.1, 257731.2, 582898.4, 149910.1),
  Coastal_BGI_Total_Ha = c(39884.36, 42466.12, 8502.00, 35486.16, 20248.40, 41612.40, 95069.16, 6634.64)
)

# Melt the data for plotting
impact_melted <- impact_data %>%
  gather(key = "Variable", value = "Value", -County, -Coastal_BGI_Total_Ha)

# Create a list to store individual impact plots
impact_plots <- list()

# Forest Loss Total Hectares:
forest_loss_plot <- ggplot(impact_melted[impact_melted$Variable == "Forest_Loss_Total_Ha", ], aes(x = County, y = Value, fill = Variable)) +
  geom_bar(stat = "identity", position = "dodge", width = 0.8) +
  labs(title = "Forest Loss in Correlation to Coastal BGI",
       x = "County", y = "Hectares", fill = "Variable") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

print(forest_loss_plot)

#Abandonment Total Hectares:
abandonment_plot <- ggplot(impact_melted[impact_melted$Variable == "Abandonedment_Total_Ha", ], aes(x = County, y = Value, fill = Variable)) +
  geom_bar(stat = "identity", position = "dodge", width = 0.8) +
  labs(title = "Abandonment in Correlation to Coastal BGI",
       x = "County", y = "Hectares", fill = "Variable") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

print(abandonment_plot)

# Fragmentation BGI Total Hectares:
fragmentation_bgi_plot <- ggplot(impact_melted[impact_melted$Variable == "Fragmetation_BGI_Total_Ha", ], aes(x = County, y = Value, fill = Variable)) +
  geom_bar(stat = "identity", position = "dodge", width = 0.8) +
  labs(title = "Fragmentation by BGI in Correlation to Coastal BGI",
       x = "County", y = "Hectares", fill = "Variable") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

print(fragmentation_bgi_plot)

# Melt the data for plotting
impact_melted <- melt(impact_data, id.vars = "County")

# Create a list to store individual impact plots
impact_plots <- list()

# Load necessary libraries
library(ggplot2)

# Create Forest Loss plot with BGI (Dodged bar plot)
forest_loss_plot_dodged <- ggplot(subset(impact_melted, variable %in% c("Forest_Loss_Total_Ha", "Coastal_BGI_Total_Ha")),
                                  aes(x = County, y = value / 1000, fill = variable)) +
  geom_bar(stat = "identity", position = "dodge", width = 0.8) +
  labs(title = "Forest Loss and Coastal BGI",
       x = "County", y = "Thousands of Hectares", fill = "variable") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Create Forest Loss plot (Simple bar plot)
forest_loss_plot_simple <- ggplot(subset(impact_melted, variable == "Forest_Loss_Total_Ha"),
                                  aes(x = County, y = value, fill = variable)) +
  geom_bar(stat = "identity", position = "dodge", width = 0.8) +
  labs(title = "Forest Loss in Correlation to Coastal BGI",
       x = "County", y = "Hectares", fill = "Variable") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Combine both plots using patchwork
combined_plot <- forest_loss_plot_dodged + forest_loss_plot_simple

# Display the combined plot
print(combined_plot)

# Create Abandonment plot with BGI (Dodged bar plot)
abandonment_plot_dodged <- ggplot(subset(impact_melted, variable %in% c("Abandonedment_Total_Ha", "Coastal_BGI_Total_Ha")),
                                  aes(x = County, y = value / 1000, fill = variable)) +
  geom_bar(stat = "identity", position = "dodge", width = 0.8) +
  labs(title = "Abandonment in Correlation to Coastal BGI",
       x = "County", y = "Thousands of Hectares", fill = "variable") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Create Abandonment plot (Simple bar plot)
abandonment_plot_simple <- ggplot(subset(impact_melted, variable == "Abandonedment_Total_Ha"),
                                  aes(x = County, y = value, fill = variable)) +
  geom_bar(stat = "identity", position = "dodge", width = 0.8) +
  labs(title = "Abandonment",
       x = "County", y = "Hectares", fill = "Variable") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Combine both plots using patchwork
combined_abandonment_plot <- abandonment_plot_dodged + abandonment_plot_simple

# Display the combined plot
print(combined_abandonment_plot)

# Create Imperviousness plot (Simple bar plot)
imperviousness_plot <- ggplot(subset(impact_melted, variable == "Imperviousness_Total_Ha"),
                              aes(x = County, y = value, fill = variable)) +
  geom_bar(stat = "identity", position = "dodge", width = 0.8) +
  labs(title = "Imperviousness",
       x = "County", y = "Hectares", fill = "Variable") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Create Fragmetation Roads plot (Simple bar plot)
fragmetation_roads_plot <- ggplot(subset(impact_melted, variable == "Fragmetation_Roads_Total_M"),
                                  aes(x = County, y = value / 1000, fill = variable)) +
  geom_bar(stat = "identity", position = "dodge", width = 0.8) +
  labs(title = "Fragmentation Roads",
       x = "County", y = "Kilometers", fill = "Variable") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Display the plots
print(imperviousness_plot)
print(fragmetation_roads_plot)

# Melt the data for plotting
impact_melted <- melt(impact_data, id.vars = "County")

# Create Fragmentation BGI plot with BGI (Dodged bar plot)
fragmentation_bgi_plot_dodged <- ggplot(subset(impact_melted, variable %in% c("Fragmetation_BGI_Total_Ha", "Coastal_BGI_Total_Ha")),
                                        aes(x = County, y = value, fill = variable)) +
  geom_bar(stat = "identity", position = "dodge", width = 0.8) +
  labs(title = "Fragmentation BGI in Correlation to Coastal BGI",
       x = "County", y = "Hectares", fill = "variable") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Create Fragmentation BGI plot (Simple bar plot)
fragmentation_bgi_plot_simple <- ggplot(subset(impact_melted, variable == "Fragmetation_BGI_Total_Ha"),
                                        aes(x = County, y = value, fill = variable)) +
  geom_bar(stat = "identity", position = "dodge", width = 0.8) +
  labs(title = "Fragmentation BGI",
       x = "County", y = "Hectares", fill = "Variable") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Combine both plots using patchwork
combined_fragmentation_bgi_plot <- fragmentation_bgi_plot_dodged + fragmentation_bgi_plot_simple

# Display the combined plot
print(combined_fragmentation_bgi_plot)

# Data
coastal_data <- data.frame(
  County = c("Harju maakond", "Hiiu maakond", "Ida-Viru maakond", "Laane maakond", "Laane-Viru maakond", "Parnu maakond", "Saare maakond", "Tallinn maakond"),
  Coastal_BGI_Total_Ha = c(39884.36, 42466.12, 8502.00, 35486.16, 20248.40, 41612.40, 95069.16, 6634.64),
  EE_Coast_3km_Total_Ha = c(432672.32, 103257.79, 297171.56, 181580.93, 369574.58, 541938.80, 293799.14, 19397.68)
)

library(tidyverse)

# Melt the data for plotting
coastal_melted <- melt(coastal_data, id.vars = "County")

# Plot Coastal BGI vs EE_Coast_3km
coastal_plot <- ggplot(coastal_melted, aes(x = County, y = value, fill = variable)) +
  geom_bar(stat = "identity", position = "dodge", width = 0.8) +
  labs(title = "Comparison of Estonian Coastalal Blue-Green Infrastructure and Coastal 3km Buffer Zone",
       x = "County", y = "Hectares", fill = "Variable") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Display the plot
print(coastal_plot)








# Impacts data
data <- data.frame(
  County = c("Harju maakond", "Hiiu maakond", "Ida-Viru maakond", "Laane maakond", "Laane-Viru maakond", 
             "Parnu maakond", "Saare maakond", "Tallinn maakond"),
  EE_Coast_3km_Total_Ha = c(432672.32, 103257.79, 297171.56, 181580.93, 369574.58, 541938.80, 293799.14, 19397.68),
  Coastal_BGI_Total_Ha = c(39884.36, 42466.12, 8502.00, 35486.16, 20248.40, 41612.40, 95069.16, 6634.64),
  Forest_Loss_Total_Ha = c(1435.00, 2114.92, 337.92, 1479.92, 779.12, 1644.76, 3659.64, 156.28),
  Abandonedment_Total_Ha = c(1651.68, 1823.92, 6.56, 3074.36, 455.16, 2568.60, 6858.32, 57.44),
  Imperviousness_Total_Ha = c(2.52, 0.84, 7.00, 0.36, 4.28, 3.44, 1.92, 5.40),
  Fragmetation_Roads_Total_M = c(313714.6, 343381.8, 118944.9, 165537.5, 138219.1, 257731.2, 582898.4, 149910.1),
  Fragmetation_BGI_Total_Ha = c(2626.0710, 1329.8013, 1988.7960, 1373.1218, 550.5647, 3985.7246, 3926.5198, 1224.5289)
)

# Compute ratio of total impact to Coastal_BGI_Total_Ha
data <- data %>%
  mutate(Total_Impact = Forest_Loss_Total_Ha + Abandonedment_Total_Ha + Imperviousness_Total_Ha + 
           Fragmetation_Roads_Total_M + Fragmetation_BGI_Total_Ha,
         Ratio = Total_Impact / Coastal_BGI_Total_Ha)

# Plot
ggplot(data, aes(x = County, y = Ratio)) +
  geom_bar(stat="identity") +
  coord_flip() +  # to make horizontal bars
  labs(title = "Comparison of impacts by counties",
       y = "Ratio of Total Impact to Coastal BGI",
       x = "County") +
  theme_minimal()




# Load necessary libraries
library(ggplot2)
library(dplyr)
library(tidyr)

#data
data <- data.frame(
  County = c("Harju maakond", "Hiiu maakond", "Ida-Viru maakond", "Laane maakond", "Laane-Viru maakond", 
             "Parnu maakond", "Saare maakond", "Tallinn maakond"),
  EE_Coast_3km_Total_Ha = c(432672.32, 103257.79, 297171.56, 181580.93, 369574.58, 541938.80, 293799.14, 19397.68),
  Coastal_BGI_Total_Ha = c(39884.36, 42466.12, 8502.00, 35486.16, 20248.40, 41612.40, 95069.16, 6634.64),
  Forest_Loss_Total_Ha = c(1435.00, 2114.92, 337.92, 1479.92, 779.12, 1644.76, 3659.64, 156.28),
  Abandonedment_Total_Ha = c(1651.68, 1823.92, 6.56, 3074.36, 455.16, 2568.60, 6858.32, 57.44),
  Imperviousness_Total_Ha = c(2.52, 0.84, 7.00, 0.36, 4.28, 3.44, 1.92, 5.40),
  Fragmetation_Roads_Total_M = c(313714.6, 343381.8, 118944.9, 165537.5, 138219.1, 257731.2, 582898.4, 149910.1),
  Fragmetation_BGI_Total_Ha = c(2626.0710, 1329.8013, 1988.7960, 1373.1218, 550.5647, 3985.7246, 3926.5198, 1224.5289)
)

# Compute ratio and normalize each impact by it
data <- data %>%
  mutate(Ratio_BGI_Buffer = Coastal_BGI_Total_Ha / EE_Coast_3km_Total_Ha) %>%
  mutate_at(vars(Forest_Loss_Total_Ha, Abandonedment_Total_Ha, Imperviousness_Total_Ha, Fragmetation_Roads_Total_M, Fragmetation_BGI_Total_Ha), 
            ~ . / Ratio_BGI_Buffer)

# Reshape to long format for ggplot
data_long <- data %>%
  select(County, Forest_Loss_Total_Ha, Abandonedment_Total_Ha, Imperviousness_Total_Ha, Fragmetation_Roads_Total_M, Fragmetation_BGI_Total_Ha) %>%
  gather(key="Impact_Type", value="Normalized_Value", -County)

# Plot without custom font settings
ggplot(data_long_without_roads, aes(x = County, y = Normalized_Value, fill = Impact_Type)) +
  geom_bar(stat="identity", position="dodge") +
  coord_flip() +
  labs(title = "Comparison of normalized impacts by counties (Excluding Road Fragmentation)",
       y = "Normalized Impact Value (in hectares)",
       x = "County") +
  theme_minimal()

g <- ggplot(data_long_without_roads, aes(x = County, y = Normalized_Value, fill = Impact_Type)) +
  geom_bar(stat="identity", position="dodge") +
  coord_flip() +
  labs(title = "Comparison of normalized impacts by counties (Excluding Road Fragmentation)",
       y = "Normalized Impact Value (in hectares)",
       x = "County") +
  theme_minimal()
plot (g)
# Save the plot
ggsave(filename = "output_plot.png", plot = g, width = 10, height = 6)

# Extract data for Fragmetation_Roads_Total_M
data_roads <- data %>%
  select(County, Fragmetation_Roads_Total_M)

# Plot
ggplot(data_roads, aes(x = County, y = Fragmetation_Roads_Total_M)) +
  geom_bar(stat="identity", fill = "darkred") +
  coord_flip() +
  labs(title = "Fragmentation by Roads",
       y = "Fragmentation Length (in meters)",
       x = "County") +
  theme_minimal()

# Convert meters to kilometers
data$Fragmetation_Roads_Total_KM <- data$Fragmetation_Roads_Total_M / 1000

# Extract data for Fragmetation_Roads_Total_KM
data_roads_km <- data %>%
  select(County, Fragmetation_Roads_Total_KM)

# Plot
ggplot(data_roads_km, aes(x = County, y = Fragmetation_Roads_Total_KM)) +
  geom_bar(stat="identity", fill = "darkred") +
  coord_flip() +
  labs(title = "Fragmentation by Roads",
       y = "Fragmentation Length (in kilometers)",
       x = "County") +
  theme_minimal()


# Prepare the long format data
data_long_all_impacts <- data %>%
  select(County, Forest_Loss_Total_Ha, Abandonedment_Total_Ha, Imperviousness_Total_Ha, 
         Fragmetation_Roads_Total_KM, Fragmetation_BGI_Total_Ha) %>%
  gather(key="Impact_Type", value="Normalized_Value", -County)

# Overlay the ratio line
ggplot(data_long_all_impacts, aes(x = County, y = Normalized_Value)) +
  geom_bar(aes(fill = Impact_Type), stat="identity", position="dodge") +
  geom_line(data=data, aes(x=County, y=10000*Ratio_BGI_Buffer, group=1), color="red", linewidth=1.2) +
  coord_flip() +
  labs(title = "Comparison of normalized impacts by counties with Coastal BGI/Total Buffer ratio",
       y = "Normalized Impact Value",
       x = "County",
       caption = "Red line represents the Coastal BGI/Total Buffer ratio (scaled for visibility)") +
  facet_wrap(~ Impact_Type, scales="free", ncol=1) +
  theme_minimal() +
  theme(legend.position = "bottom")

# Overlay the ratio line
ggplot(data_long_all_impacts, aes(x = County, y = Normalized_Value)) +
  geom_bar(aes(fill = Impact_Type), stat="identity", position="dodge") +
  geom_line(data=data, aes(x=County, y=10000*Ratio_BGI_Buffer, group=1), color="red", linewidth=1.2) +
  coord_flip() +
  labs(title = "Impacts by counties with Coastal BGI/Total Buffer ratio",
       y = "Normalized Impact Value",
       x = "County",
       caption = "Red line represents the Coastal BGI/Total Buffer ratio (scaled for visibility)") +
  facet_wrap(~ Impact_Type, scales="free", ncol=1) +
  theme_minimal() +
  guides(fill = guide_legend(ncol = 2)) +
  theme(legend.position = "bottom")



# Convert the "Fragmetation_Roads_Total_M" to "Fragmetation_Roads_Total_KM"
data$Fragmetation_Roads_Total_KM <- data$Fragmetation_Roads_Total_M / 1000

# Melt data into long format
data_long_all_impacts <- data %>%
  select(County, EE_Coast_3km_Total_Ha, Coastal_BGI_Total_Ha, Forest_Loss_Total_Ha,
         Abandonedment_Total_Ha, Imperviousness_Total_Ha, Fragmetation_Roads_Total_KM, 
         Fragmetation_BGI_Total_Ha) %>%
  gather(key="Impact_Type", value="Normalized_Value", -County)

# Re-level the Impact_Type factor
data_long_all_impacts$Impact_Type <- factor(data_long_all_impacts$Impact_Type, 
                                            levels = c("EE_Coast_3km_Total_Ha", "Coastal_BGI_Total_Ha", "Forest_Loss_Total_Ha", 
                                                       "Abandonedment_Total_Ha", "Imperviousness_Total_Ha", 
                                                       "Fragmetation_Roads_Total_KM", "Fragmetation_BGI_Total_Ha"),
                                            labels = c("Total Buffer Area (Ha)", "Coastal BGI (Ha)", "Forest Loss (Ha)", 
                                                       "Abandonedment (Ha)", "Imperviousness (Ha)", 
                                                       "Fragmentation by Roads (KM)", "Fragmentation by BGI (Ha)"))

# Exclude the Total Buffer Area and Coastal BGI impacts for the plot
data_long_selected_impacts <- data_long_all_impacts %>% 
  filter(!Impact_Type %in% c("Total Buffer Area (Ha)", "Coastal BGI (Ha)"))

# Plot
ggplot(data_long_selected_impacts, aes(x = County, y = Normalized_Value)) +
  geom_bar(aes(fill = Impact_Type), stat="identity", position="dodge") +
  geom_line(data=data, aes(x=County, y=10000*Ratio_BGI_Buffer, group=1), color="red", linewidth=1.2) +
  coord_flip() +
  labs(title = "Impacts by counties with Coastal BGI/Total Buffer ratio",
       y = "Normalized Impact Value",
       x = "County",
       fill = "Impact Categories",
       caption = "Red line represents the Coastal BGI/Total Buffer ratio (scaled for visibility)") +
  facet_wrap(~ Impact_Type, scales="free", ncol=2) +
  theme_minimal() +
  guides(fill = guide_legend(ncol = 2)) +
  theme(legend.position = "bottom")








