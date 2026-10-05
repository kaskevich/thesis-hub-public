# Load necessary libraries
library(ggplot2)
library(dplyr)
library(tidyr)
library(gridExtra)

# Create the data frame based on the provided data
data <- data.frame(
  County = c("Harju", "Hiiu", "Ida-Viru", "Laane", "Laane-Viru", "Parnu", "Saare"),
  Forest_Cores_Ha = c(15190.64, 15044.83, 2180.53, 9140.32, 6888.69, 8392.93, 24606.31),
  Natura2000_Cores_Ha = c(8534.58, 9709.22, 417.08, 9991.53, 5640.56, 10689.0, 23164.81),
  Perm_Cores_Ha = c(0.66, 1.95, 0.05, 2.03, 0.32, 2.16, 9.0),
  Forest_Corridors_Ha = c(11234.11, 9513.88, 2457.32, 9228.92, 3567.59, 8344.86, 24174.41),
  Natura2000_Corridors_Ha = c(5328.15, 4765.32, 540.2, 4438.43, 2048.45, 6410.36, 15676.93),
  Perm_Corridors_Ha = c(8.97, 24.21, 2.59, 19.06, 5.26, 30.01, 11.67),
  Forest_Branches_Ha = c(597.45, 344.5, 182.2, 256.27, 112.03, 516.14, 826.13),
  Natura2000_Branches_Ha = c(252.92, 369.87, 11.34, 658.57, 54.55, 617.11, 1487.05),
  Perm_Branches_Ha = c(2.19, 4.6, 0.75, 4.0, 0.8, 6.07, 26.72)
)

# Convert the data to a long format for easier plotting
data_long <- data %>%
  gather(key = "Category", value = "Area_Ha", -County) %>%
  separate(Category, into = c("Type", "Class"), sep = "_") %>%
  unite("GI_Class", Type, Class, sep = "_", remove = FALSE)

# Define color palette for the different GI classes
colors <- c("Forest" = "#98df8a", "Natura2000" = "#ffbb78", "Perm" = "#f7b6d2")

# Plot for Cores
p1 <- ggplot(data_long %>% filter(Class == "Cores"), aes(x = County, y = Area_Ha, fill = Type)) +
  geom_bar(stat = "identity", position = "stack") +
  scale_fill_manual(values = colors) +
  labs(title = "Distribution of GI Classes in Estonian Coastal Counties - Cores",
       x = NULL, y = "Total Area (hectares)") +
  theme_minimal() +
  coord_flip()

# Plot for Corridors
p2 <- ggplot(data_long %>% filter(Class == "Corridors"), aes(x = County, y = Area_Ha, fill = Type)) +
  geom_bar(stat = "identity", position = "stack") +
  scale_fill_manual(values = colors) +
  labs(title = "Distribution of GI Classes in Estonian Coastal Counties - Corridors",
       x = NULL, y = "Total Area (hectares)") +
  theme_minimal() +
  coord_flip()

# Plot for Branches
p3 <- ggplot(data_long %>% filter(Class == "Branches"), aes(x = County, y = Area_Ha, fill = Type)) +
  geom_bar(stat = "identity", position = "stack") +
  scale_fill_manual(values = colors) +
  labs(title = "Distribution of GI Classes in Estonian Coastal Counties - Branches",
       x = NULL, y = "Total Area (hectares)") +
  theme_minimal() +
  coord_flip()

# Arrange the plots together
grid.arrange(p1, p2, p3, ncol = 1)



# Load necessary libraries
library(ggplot2)
library(dplyr)
library(tidyr)
library(gridExtra)

# Create the data frame based on the provided data
data <- data.frame(
  County = c("Harju", "Hiiu", "Ida-Viru", "Laane", "Laane-Viru", "Parnu", "Saare"),
  Forest_Cores_Ha = c(15190.64, 15044.83, 2180.53, 9140.32, 6888.69, 8392.93, 24606.31),
  Natura2000_Cores_Ha = c(8534.58, 9709.22, 417.08, 9991.53, 5640.56, 10689.0, 23164.81),
  Perm_Cores_Ha = c(0.66, 1.95, 0.05, 2.03, 0.32, 2.16, 9.0),
  Forest_Corridors_Ha = c(11234.11, 9513.88, 2457.32, 9228.92, 3567.59, 8344.86, 24174.41),
  Natura2000_Corridors_Ha = c(5328.15, 4765.32, 540.2, 4438.43, 2048.45, 6410.36, 15676.93),
  Perm_Corridors_Ha = c(8.97, 24.21, 2.59, 19.06, 5.26, 30.01, 11.67),
  Forest_Branches_Ha = c(597.45, 344.5, 182.2, 256.27, 112.03, 516.14, 826.13),
  Natura2000_Branches_Ha = c(252.92, 369.87, 11.34, 658.57, 54.55, 617.11, 1487.05),
  Perm_Branches_Ha = c(2.19, 4.6, 0.75, 4.0, 0.8, 6.07, 26.72)
)

# Define the reversed specific order for the counties (from Ida-Viru to Saare)
county_order <- c("Ida-Viru", "Laane-Viru", "Harju", "Laane", "Parnu", "Hiiu", "Saare")

# Convert County column to a factor with the specified levels in reverse order
data$County <- factor(data$County, levels = rev(county_order))

# Convert the data to a long format for easier plotting
data_long <- data %>%
  gather(key = "Category", value = "Area_Ha", -County) %>%
  separate(Category, into = c("Type", "Class"), sep = "_") %>%
  unite("GI_Class", Type, Class, sep = "_", remove = FALSE)

# Define color palette for the different GI classes
colors <- c("Forest" = "#98df8a", "Natura2000" = "#ffbb78", "Perm" = "#f7b6d2")

# Plot for Cores
p1 <- ggplot(data_long %>% filter(Class == "Cores"), aes(x = County, y = Area_Ha, fill = Type)) +
  geom_bar(stat = "identity", position = "stack") +
  scale_fill_manual(values = colors) +
  labs(title = "Distribution of GI Classes in Estonian Coastal Counties - Cores",
       x = NULL, y = "Total Area (hectares)") +
  theme_minimal() +
  coord_flip()

# Plot for Corridors
p2 <- ggplot(data_long %>% filter(Class == "Corridors"), aes(x = County, y = Area_Ha, fill = Type)) +
  geom_bar(stat = "identity", position = "stack") +
  scale_fill_manual(values = colors) +
  labs(title = "Distribution of GI Classes in Estonian Coastal Counties - Corridors",
       x = NULL, y = "Total Area (hectares)") +
  theme_minimal() +
  coord_flip()

# Plot for Branches
p3 <- ggplot(data_long %>% filter(Class == "Branches"), aes(x = County, y = Area_Ha, fill = Type)) +
  geom_bar(stat = "identity", position = "stack") +
  scale_fill_manual(values = colors) +
  labs(title = "Distribution of GI Classes in Estonian Coastal Counties - Branches",
       x = NULL, y = "Total Area (hectares)") +
  theme_minimal() +
  coord_flip()

# Arrange the plots together
grid.arrange(p1, p2, p3, ncol = 1)






# Load necessary libraries
library(ggplot2)
library(dplyr)
library(tidyr)
library(gridExtra)

# Create the data frame based on the provided data
data <- data.frame(
  County = c("Harju", "Hiiu", "Ida-Viru", "Laane", "Laane-Viru", "Parnu", "Saare"),
  Forest_Cores_Ha = c(15190.64, 15044.83, 2180.53, 9140.32, 6888.69, 8392.93, 24606.31),
  Natura2000_Cores_Ha = c(8534.58, 9709.22, 417.08, 9991.53, 5640.56, 10689.0, 23164.81),
  Perm_Cores_Ha = c(0.66, 1.95, 0.05, 2.03, 0.32, 2.16, 9.0),
  Forest_Corridors_Ha = c(11234.11, 9513.88, 2457.32, 9228.92, 3567.59, 8344.86, 24174.41),
  Natura2000_Corridors_Ha = c(5328.15, 4765.32, 540.2, 4438.43, 2048.45, 6410.36, 15676.93),
  Perm_Corridors_Ha = c(8.97, 24.21, 2.59, 19.06, 5.26, 30.01, 11.67),
  Forest_Branches_Ha = c(597.45, 344.5, 182.2, 256.27, 112.03, 516.14, 826.13),
  Natura2000_Branches_Ha = c(252.92, 369.87, 11.34, 658.57, 54.55, 617.11, 1487.05),
  Perm_Branches_Ha = c(2.19, 4.6, 0.75, 4.0, 0.8, 6.07, 26.72)
)

# Define the reversed specific order for the counties (from Ida-Viru to Saare)
county_order <- c("Ida-Viru", "Laane-Viru", "Harju", "Laane", "Parnu", "Hiiu", "Saare")

# Convert County column to a factor with the specified levels in reverse order
data$County <- factor(data$County, levels = rev(county_order))

# Convert the data to a long format for easier plotting
data_long <- data %>%
  gather(key = "Category", value = "Area_Ha", -County) %>%
  separate(Category, into = c("Type", "Class"), sep = "_") %>%
  unite("GI_Class", Type, Class, sep = "_", remove = FALSE)

# Define color palette for the different GI classes
colors <- c("Forest" = "#98df8a", "Natura2000" = "#ff9999", "Perm" = "#ffbb78")

# Define a common y-axis limit (assuming maximum value is around 50000 hectares)
y_axis_limit <- c(0, 50000)

# Plot for Cores
p1 <- ggplot(data_long %>% filter(Class == "Cores"), aes(x = County, y = Area_Ha, fill = Type)) +
  geom_bar(stat = "identity", position = "stack") +
  scale_fill_manual(values = colors) +
  labs(title = "Distribution of GI Classes in Estonian Coastal Counties - Cores",
       x = NULL, y = "Total Area (hectares), % to the total coastal area of the county") +
  theme_minimal() +
  coord_flip() +
  ylim(y_axis_limit)

# Plot for Corridors
p2 <- ggplot(data_long %>% filter(Class == "Corridors"), aes(x = County, y = Area_Ha, fill = Type)) +
  geom_bar(stat = "identity", position = "stack") +
  scale_fill_manual(values = colors) +
  labs(title = "Distribution of GI Classes in Estonian Coastal Counties - Corridors",
       x = NULL, y = "Total Area (hectares), % to the total coastal area of the county") +
  theme_minimal() +
  coord_flip() +
  ylim(y_axis_limit)

# Plot for Branches
p3 <- ggplot(data_long %>% filter(Class == "Branches"), aes(x = County, y = Area_Ha, fill = Type)) +
  geom_bar(stat = "identity", position = "stack") +
  scale_fill_manual(values = colors) +
  labs(title = "Distribution of GI Classes in Estonian Coastal Counties - Branches",
       x = NULL, y = "Total Area (hectares), % to the total coastal area of the county") +
  theme_minimal() +
  coord_flip() +
  ylim(y_axis_limit)

# Arrange the plots together
grid.arrange(p1, p2, p3, ncol = 1)





# Load necessary libraries
library(ggplot2)
library(dplyr)
library(tidyr)
library(gridExtra)

# Create the data frame based on the provided data
data_permanent_meadows <- data.frame(
  County = c("Harju", "Hiiu", "Ida-Viru", "Laane", "Laane-Viru", "Parnu", "Saare"),
  Perm_Cores_Ha = c(0.66, 1.95, 0.05, 2.03, 0.32, 2.16, 9.0),
  Perm_Corridors_Ha = c(8.97, 24.21, 2.59, 19.06, 5.26, 30.01, 11.67),
  Perm_Branches_Ha = c(2.19, 4.6, 0.75, 4.0, 0.8, 6.07, 26.72)
)

# Define the specific order for the counties in reverse (from Saare to Ida-Viru)
county_order <- c("Saare", "Hiiu", "Parnu", "Laane", "Laane-Viru", "Harju", "Ida-Viru")

# Convert County column to a factor with the reversed order
data_permanent_meadows$County <- factor(data_permanent_meadows$County, levels = county_order)

# Convert the data to a long format for easier plotting
data_long_perm_meadows <- data_permanent_meadows %>%
  gather(key = "Class", value = "Area_Ha", -County)

# Define color for Permanent Meadows (light red)
perm_meadows_color <- "#ffbb78"  # Light red color for consistency

# Define a common x-axis limit (assuming maximum value is around 35 hectares)
x_axis_limit <- c(0, 35)

# Plot for Cores
p1_perm <- ggplot(data_long_perm_meadows %>% filter(Class == "Perm_Cores_Ha"), aes(x = Area_Ha, y = County, fill = Class)) +
  geom_bar(stat = "identity", position = "stack", fill = perm_meadows_color) +
  labs(title = "Permanent Meadows in Estonian Coastal Counties - Cores",
       x = "Total Area (hectares), % to the total coastal area of the county", y = NULL) +
  theme_minimal() +
  xlim(x_axis_limit)

# Plot for Corridors
p2_perm <- ggplot(data_long_perm_meadows %>% filter(Class == "Perm_Corridors_Ha"), aes(x = Area_Ha, y = County, fill = Class)) +
  geom_bar(stat = "identity", position = "stack", fill = perm_meadows_color) +
  labs(title = "Permanent Meadows in Estonian Coastal Counties - Corridors",
       x = "Total Area (hectares), % to the total coastal area of the county", y = NULL) +
  theme_minimal() +
  xlim(x_axis_limit)

# Plot for Branches
p3_perm <- ggplot(data_long_perm_meadows %>% filter(Class == "Perm_Branches_Ha"), aes(x = Area_Ha, y = County, fill = Class)) +
  geom_bar(stat = "identity", position = "stack", fill = perm_meadows_color) +
  labs(title = "Permanent Meadows in Estonian Coastal Counties - Branches",
       x = "Total Area (hectares), % to the total coastal area of the county", y = NULL) +
  theme_minimal() +
  xlim(x_axis_limit)

# Arrange the plots together
grid.arrange(p1_perm, p2_perm, p3_perm, ncol = 1)




