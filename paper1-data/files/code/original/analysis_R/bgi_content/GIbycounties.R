library(dplyr)
library(ggplot2)
library(tidyr)
library(scales)

# Define the data with accurate hectares provided
total_area_data <- data.frame(
  County = c("Ida-Viru maakond", "Laane-Viru maakond", "Harju maakond", 
             "Laane maakond", "Parnu maakond", "Hiiu maakond", "Saare maakond"),
  EE_Coast_3km_Total_Ha = c(297171.56, 369574.58, 432672.32, 181580.93, 541938.8, 103257.79, 293799.14),
  Forest_Cores_Ha = c(2180.53, 6888.69, 15190.64, 9140.32, 8392.93, 15044.83, 24606.31),
  Natura2000_Cores_Ha = c(417.08, 5640.56, 8534.58, 9991.53, 10689.0, 9709.22, 23164.81),
  Perm_Cores_Ha = c(0.05, 0.32, 0.66, 2.03, 2.16, 1.95, 9.00),
  Forest_Corridors_Ha = c(2457.32, 3567.59, 11234.11, 9228.92, 8344.86, 9513.88, 24174.41),
  Natura2000_Corridors_Ha = c(540.2, 2048.45, 5328.15, 4438.43, 6410.36, 4765.32, 15676.93),
  Perm_Corridors_Ha = c(2.59, 5.26, 8.97, 19.06, 30.01, 24.21, 11.67),
  Forest_Branches_Ha = c(182.2, 112.03, 597.45, 256.27, 516.14, 344.5, 826.13),
  Natura2000_Branches_Ha = c(11.34, 54.55, 252.92, 658.57, 617.11, 369.87, 1487.05),
  Perm_Branches_Ha = c(0.75, 0.8, 2.19, 4.0, 6.07, 4.6, 26.72)
)

# Convert the data to long format for easier plotting
long_data <- pivot_longer(
  total_area_data,
  cols = -c(County, EE_Coast_3km_Total_Ha),
  names_to = "Category",
  values_to = "Area_Ha"
)

# Manually set the order of counties, ensuring islands are last
long_data$County <- factor(long_data$County, 
                           levels = c("Ida-Viru maakond", "Laane-Viru maakond", "Harju maakond", 
                                      "Laane maakond", "Parnu maakond", "Hiiu maakond", "Saare maakond"))

# Custom colors for Forest, Natura2000, and Permanent Meadows
category_colors <- c("Forest_Cores_Ha" = "lightgreen", 
                     "Natura2000_Cores_Ha" = "orange", 
                     "Perm_Cores_Ha" = "red",
                     "Forest_Corridors_Ha" = "lightgreen",
                     "Natura2000_Corridors_Ha" = "orange",
                     "Perm_Corridors_Ha" = "red",
                     "Forest_Branches_Ha" = "lightgreen",
                     "Natura2000_Branches_Ha" = "orange",
                     "Perm_Branches_Ha" = "red")

# Plot the data using ggplot, only x-axis values are shown, no duplicate numbers inside the bars
ggplot(long_data, aes(x = Area_Ha, y = County, fill = Category)) +
  geom_bar(stat = "identity", color = "black", size = 0.1) +
  scale_fill_manual(values = category_colors) +
  labs(title = "Distribution of GI Classes in Estonian Coastal Counties",
       x = "Total Area (hectares)", y = "County",
       fill = "Category") +
  theme_minimal() +
  theme(legend.position = "bottom") +
  scale_x_continuous(labels = comma) + 
  theme(axis.text.y = element_text(size = 12), axis.title = element_text(size = 14),
        legend.text = element_text(size = 10), plot.title = element_text(size = 14, face = "bold"))

