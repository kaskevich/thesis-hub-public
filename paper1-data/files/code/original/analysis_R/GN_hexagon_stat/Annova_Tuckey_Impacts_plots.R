# Load required packages
library(readxl)

# Set working directory
setwd("~/Desktop/ThirtyFourtyDocker/ls_metrics_allstat/GN_hexagon_stat/")

# Read ANOVA impact files
anova_impacts_forest <- read_excel("anova_impacts_forest.xlsx")
anova_impacts_aband <- read_excel("anova_impacts_aband.xlsx")
anova_impacts_imperv <- read_excel("anova_impacts_imperv.xlsx")
anova_impacts_roads <- read_excel("anova_impacts_roads.xlsx")
anova_impacts_bgifrag <- read_excel("anova_impacts_bgifrag.xlsx")
anova_impacts_cum <- read_excel("anova_impacts_cum.xlsx")

# Read Tukey test files
tukey_for_c_norm <- read_excel("tukey_for_c_norm.xlsx")
tukey_ab_c_norm <- read_excel("tukey_ab_c_norm.xlsx")
tukey_imp_c_norm <- read_excel("tukey_imp_c_norm.xlsx")
tukey_frag_norm <- read_excel("tukey_frag_norm.xlsx")
tukey_road_m_nor <- read_excel("tukey_road_m_nor.xlsx")
tukey_cum_norm <- read_excel("tukey_cum_norm.xlsx")

library(ggplot2)
library(tidyr)

# Load Forest cover loss data
tukey_for_c_norm <- read_excel("tukey_for_c_norm.xlsx")

# Boxplot
ggplot(tukey_for_c_norm, aes(x = diff, y = county)) +
  geom_boxplot() +
  xlab("Difference") +
  ylab("") +
  ggtitle("Tukey Test: Forest Cover vs. County") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5)) +
  coord_flip()

# run the tukey_for_norm function
tukey_results <- tukey_for_norm(my_data, dependent_var, factor_var)

# print the first 50 rows of the output
print(tukey_for_c_norm, n = 50)


# Load Abandoned Land data
tukey_ab_c_norm <- read_excel("tukey_ab_c_norm.xlsx")

# Boxplot
ggplot(tukey_ab_c_norm, aes(x = diff, y = county)) +
  geom_boxplot() +
  xlab("Difference") +
  ylab("") +
  ggtitle("Tukey Test: Abandoned Land vs. County") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5)) +
  coord_flip()

# print the first 50 rows of the output
print(tukey_ab_c_norm, n = 50)

# Load Impervious Area data
tukey_imp_c_norm <- read_excel("tukey_imp_c_norm.xlsx")

# Boxplot
ggplot(tukey_imp_c_norm, aes(x = diff, y = county)) +
  geom_boxplot() +
  xlab("Difference") +
  ylab("") +
  ggtitle("Tukey Test: Impervious Area vs. County") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5)) +
  coord_flip()

# print the first 50 rows of the output
print(tukey_imp_c_norm, n = 50)

# Load Fragmentation by Roads data
tukey_road_m_nor <- read_excel("tukey_road_m_nor.xlsx") 

# Boxplot
ggplot(tukey_road_m_nor, aes(x = diff, y = county)) +
  geom_boxplot() +
  xlab("Difference") +
  ylab("") +
  ggtitle("Tukey Test: Fragmentation by Roads vs. County") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5)) +
  coord_flip()

# print the first 50 rows of the output
print(tukey_road_m_nor, n = 50)

# Load Fragmentation of GI data
tukey_frag_norm <- read_excel("tukey_frag_norm.xlsx")

# Boxplot
ggplot(tukey_frag_norm, aes(x = diff, y = county)) +
  geom_boxplot() +
  xlab("Difference") +
  ylab("") +
  ggtitle("Tukey Test: Fragmentation of GI vs. County") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5)) +
  coord_flip()

# print the first 50 rows of the output
print(tukey_frag_norm, n = 50)

# Load Cumulative Impact data
tukey_cum_norm <- read_excel("tukey_cum_norm.xlsx")

# Boxplot
ggplot(tukey_cum_norm, aes(x = diff, y = county)) +
  geom_boxplot() +
  xlab("Difference") +
  ylab("") +
  ggtitle("Tukey Test: Cumulative Impact vs. County") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5)) +
  coord_flip()

# print the first 50 rows of the output
print(tukey_cum_norm, n = 50)


