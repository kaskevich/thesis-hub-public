library(readxl)
library(hexbin)
library(ggplot2)
library(dplyr)
library(gridExtra)
library(tidyr)
# Set the working directory to the folder containing the Excel file
data <- read_excel("~/Desktop/ThirtyFourtyDocker/ls_metrics_allstat/GN_hexagon_stat/hexagon_by_regions_gi.xlsx", sheet = "hexagon_by_regions_gi")

# Read the data from the Excel file
data <- read_excel("hexagon_by_regions_gi.xlsx", sheet = "cumulative")

# Create a boxplot with fill by county
ggplot(data, aes(x = county, y = log(cum_imp), fill = county)) +
  geom_boxplot() +
  labs(title = "Cumulative impact by County",
       x = "County",
       y = "Percentage (log scale)",
       fill = "County") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5))

ggplot(data, aes(x = county, y = cum_imp, fill = county)) +
  geom_boxplot() +
  labs(title = "Cumulative impact by County",
       x = "County",
       y = "Percentage",
       fill = "County") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5))


#plot +table
mean_by_county <- data %>%
  group_by(county) %>%
  summarize(mean_cum_norm = mean(cum_norm)) %>%
  arrange(desc(mean_cum_norm))

mean_by_county
write.csv(mean_by_county, "cum_mean_by_county.csv")

library(knitr)
library(kableExtra)

kable(mean_by_county, format = "html", caption = "Mean Cumulative Normalized Impact by County") %>%
  kable_styling(bootstrap_options = c("striped", "hover"), full_width = F)

library(reshape2)

head(data)
str(data)

ggplot(data, aes(x = county, y = cum_norm, fill = county)) +
  geom_bar(stat = "identity") +
  labs(title = "Normalized Cumulative Impact on Blue-Green Infrastructure by County",
       x = "County",
       y = "Normalized Cumulative Impact")

# Create coastal_data dataframe
coastal_data <- data.frame(
  County = c("Harju maakond", "Hiiu maakond", "Ida-Viru maakond", "Laane maakond", "Laane-Viru maakond", "Parnu maakond", "Saare maakond", "Tallinn maakond"),
  Coastal_BGI_Total_Ha = c(39884.36, 42466.12, 8502.00, 35486.16, 20248.40, 41612.40, 95069.16, 6634.64),
  EE_Coast_3km_Total_Ha = c(432672.32, 103257.79, 297171.56, 181580.93, 369574.58, 541938.80, 293799.14, 19397.68)
)

# Merge data and coastal_data based on the 'County' column
merged_data <- merge(data, coastal_data, by.x = "county", by.y = "County")

# Convert GN_met (BGI) from square meters to hectares
merged_data$GN_met_Ha <- merged_data$GN_met / 10000  # 1 hectare = 10,000 square meters

# Create a new variable representing the ratio of BGI to the total coastal area
merged_data$BGI_to_Coastal_Ratio <- merged_data$GN_met_Ha / merged_data$Coastal_BGI_Total_Ha

# Scatter plot with the ratio variable
ggplot(merged_data, aes(x = BGI_to_Coastal_Ratio, y = cum_norm, size = Coastal_BGI_Total_Ha, color = county)) +
  geom_point(alpha = 0.7) +
  scale_size_continuous(name = "Coastal Area (Ha)", labels = scales::comma) +
  labs(title = "Relationship between BGI to Coastal Area Ratio, Normalized Cumulative Impact, and Coastal Area",
       x = "BGI to Coastal Area Ratio",
       y = "Normalized Cumulative Impact",
       color = "County")


# Scatter plot with separate facets for each county
ggplot(merged_data, aes(x = BGI_to_Coastal_Ratio, y = cum_norm, size = Coastal_BGI_Total_Ha)) +
  geom_point(alpha = 0.7) +
  scale_size_continuous(name = "Coastal Area (Ha)", labels = scales::comma) +
  facet_wrap(~ county, scales = "free") +
  labs(title = "Relationship between BGI to Coastal Area Ratio, Normalized Cumulative Impact, and Coastal Area",
       x = "BGI to Coastal Area Ratio",
       y = "Normalized Cumulative Impact")


# Data
coastal_data <- data.frame(
  County = c("Harju maakond", "Hiiu maakond", "Ida-Viru maakond", "Laane maakond", "Laane-Viru maakond", "Parnu maakond", "Saare maakond", "Tallinn maakond"),
  Coastal_BGI_Total_Ha = c(39884.36, 42466.12, 8502.00, 35486.16, 20248.40, 41612.40, 95069.16, 6634.64),
  EE_Coast_3km_Total_Ha = c(432672.32, 103257.79, 297171.56, 181580.93, 369574.58, 541938.80, 293799.14, 19397.68)
)

# Melt the data for easier plotting
coastal_data_long <- tidyr::gather(coastal_data, key = "Variable", value = "Area", -County)

# Grouped bar plot
ggplot(coastal_data_long, aes(x = County, y = Area, fill = Variable)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Comparison of Coastal BGI Total Area and Coast_3km_Total_Ha by County",
       x = "County",
       y = "Total Area (Ha)",
       fill = "Variable") +
  theme_minimal()  # Optional: Adjust the theme as needed

# Calculate the ratio of Coastal BGI Total Area to Coast_3km_Total_Ha
coastal_data$BGI_to_Coastal_Ratio <- coastal_data$Coastal_BGI_Total_Ha / coastal_data$EE_Coast_3km_Total_Ha

ggplot(coastal_data, aes(x = County, y = BGI_to_Coastal_Ratio, fill = County)) +
  geom_bar(stat = "identity") +
  labs(title = "Ratio of Coastal BGI Total Area to Coast_3km_Total_Ha by County",
       x = "County",
       y = "BGI to Coastal Ratio",
       fill = "County") +
  theme_minimal() 

# Calculate the mean cum_norm by county
mean_cum_norm_by_county <- data %>%
  group_by(county) %>%
  summarise(mean_cum_norm = mean(cum_norm, na.rm = TRUE))

# Print the result
print(mean_cum_norm_by_county)

# Calculate the meaian cum_norm by county
median_cum_norm_by_county <- data %>%
  group_by(county) %>%
  summarise(median_cum_norm = median(cum_norm, na.rm = TRUE))

# Print the result
print(median_cum_norm_by_county)

# Extract the relevant columns and match the order
coastal_data <- data.frame(
  County = c("Harju maakond", "Hiiu maakond", "Ida-Viru maakond", "Laane maakond", "Laane-Viru maakond", "Parnu maakond", "Saare maakond", "Tallinn maakond"),
  Coastal_BGI_Total_Ha = c(39884.36, 42466.12, 8502.00, 35486.16, 20248.40, 41612.40, 95069.16, 6634.64),
  EE_Coast_3km_Total_Ha = c(432672.32, 103257.79, 297171.56, 181580.93, 369574.58, 541938.80, 293799.14, 19397.68),
  BGI_to_Coastal_Ratio = c(0.0922, 0.4119, 0.0286, 0.1953, 0.0548, 0.0767, 0.3237, 0.3415),
  cum_norm_mean = c(0.103, 0.0789, 0.202, 0.0935, 0.0670, 0.141, 0.0927, 0.209),
  cum_norm_median = c(0.0275, 0.026, 0.11, 0.031, 0.016, 0.0565, 0.037, 0.095)
  )

ggplot(coastal_data, aes(x = County, y = cum_norm_mean, fill = BGI_to_Coastal_Ratio)) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_fill_gradient(low = "red", high = "darkgreen") +
  labs(title = "Mean Cumulative Impact by County",
       x = "County",
       y = "Mean Cumulative Impact",
       fill = "BGI to Coastal Ratio") +
  theme_minimal()

# Ensure tidyverse is loaded
library(tidyverse)

# Ensure tidyverse is loaded
library(tidyverse)

# Your data
coastal_data <- data.frame(
  County = c("Harju maakond", "Hiiu maakond", "Ida-Viru maakond", "Laane maakond", "Laane-Viru maakond", "Parnu maakond", "Saare maakond", "Tallinn maakond"),
  BGI_to_Coastal_Ratio = c(0.0922, 0.4119, 0.0286, 0.1953, 0.0548, 0.0767, 0.3237, 0.3415),
  cum_norm_mean = c(0.103, 0.0789, 0.202, 0.0935, 0.0670, 0.141, 0.0927, 0.209),
  cum_norm_median = c(0.0275, 0.026, 0.11, 0.031, 0.016, 0.0565, 0.037, 0.095)
)

# Reshape the data for plotting
coastal_data_long <- coastal_data %>%
  gather(key = "Variable", value = "Value", -County)

# Convert BGI_to_Coastal_Ratio to factor
coastal_data_long$`BGI to Coastal Ratio` <- as.factor(coastal_data_long$`BGI_to_Coastal_Ratio`)

# Plotting
ggplot(coastal_data_long, aes(x = Variable, y = Value, fill = `BGI to Coastal Ratio`)) +
  geom_bar(stat = "identity", position = "dodge") +
  facet_wrap(~County, scales = "free_y") +
  scale_fill_gradient(low = "red", high = "darkgreen") +
  labs(title = "Comparison by County",
       x = "Variable",
       y = "Value",
       fill = "BGI to Coastal Ratio") +
  theme_minimal()






