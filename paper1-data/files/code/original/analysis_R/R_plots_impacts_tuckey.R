library(tidyverse)
library(readr)
library(multcomp)

file_path <- "~/Desktop/ThirtyFourtyDocker/ls_metrics_allstat/GN_hexagon_stat"
tukey_files <- c("tukey_for_c_norm.csv", "tukey_ab_c_norm.csv", 
                 "tukey_imp_c_norm.csv", "tukey_road_m_nor.csv", 
                 "tukey_frag_norm.csv", "tukey_cum_norm.csv")

library(writexl)

file_path <- "~/Desktop/ThirtyFourtyDocker/ls_metrics_allstat/GN_hexagon_stat"
tukey_files <- c("tukey_for_c_norm.csv", "tukey_ab_c_norm.csv", 
                 "tukey_imp_c_norm.csv", "tukey_road_m_nor.csv", 
                 "tukey_frag_norm.csv", "tukey_cum_norm.csv")

for (i in 1:length(tukey_files)) {
  df <- read.csv(paste(file_path, tukey_files[i], sep = "/"))
  write_xlsx(df, paste0(file_path, "/", gsub(".csv", ".xlsx", tukey_files[i])))
}

# Load necessary libraries
library(readxl)

# Load data from Excel
df <- read_excel("~/Desktop/ThirtyFourtyDocker/ls_metrics_allstat/GN_hexagon_stat/tukey_cum_norm.xlsx")

# Rename column names
colnames(df) <- c("diff", "lwr", "upr", "p_adj", "county")

# access the "diff" column 
diff_col <- df$diff

# filter the data based on a condition on the "p_adj" column 
filtered_df <- subset(df, p_adj < 0.05)

# compute summary statistics for the "diff" column 
summary_diff <- summary(df$diff)


# a scatter plot of "diff" against "lwr" using the "ggplot2" library
library(ggplot2)
ggplot(df, aes(x = diff, y = county)) + geom_point()

colnames(df)

# Extract significant comparisons
significant_comparisons <- filtered_df  
significant_comparisons
# Create boxplot or violin plot to visualize comparisons
library(stringr)

ggplot(df, aes(x = str_wrap(county, width = 1), y = diff)) +
  geom_boxplot() +
  labs(title = "Boxplot of Cumulative Impact by County",
       x = "County Description",
       y = "Cumulative Impact Description") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5))



library(tidyverse)
library(readxl)

df <- read_excel("~/Desktop/ThirtyFourtyDocker/ls_metrics_allstat/GN_hexagon_stat/tukey_cum_norm.xlsx")


#Create separate data frames for Harju maakond and other counties
df_harju <- df %>%
  filter(county == "Harju maakond")

df_others <- df %>%
  filter(county != "Harju maakond")


ggplot(df_harju, aes(x = county, y = diff)) +
  geom_boxplot() +
  labs(x = "County", y = "Difference", title = "Difference in O Tuckey test for Harju maakond")

unique(df_harju$county)
colnames(df_harju)





