install.packages(c("ggplot2", "ggpubr", "tidyverse", "broom", "AICcmodavg"))
library(ggplot2)
library(ggpubr)
library(tidyverse)
library(broom)
library(AICcmodavg)

setwd("~/Desktop/ThirtyFourtyDocker/ls_metrics_allstat")

# Load the data
ls_patch_metrics_results <- read.csv("~/Desktop/ThirtyFourtyDocker/ls_metrics_allstat/ls_patch_metrics_results.csv")

# Extract county and metric columns and split column names by delimiter "."
colnames <- strsplit(names(ls_patch_metrics_results), "\\.")
county_col <- which(sapply(colnames, function(x) x[5]) == "county") 
counties <- unique(ls_patch_metrics_results[, county_col])
metrics <- c("area", "cai", "circle", "contig", "core", "en", "frac", "gyrate", "ncore", "para", "perim", "shape")

# Perform One-way ANOVA and Tukey test for each metric
for (metric in metrics) {
  # Create a data frame with the selected county and metric
  df <- ls_patch_metrics_results[, c(county_col, which(colnames == metric))]
  colnames(df) <- c("County", "Value")
  
  # Perform One-way ANOVA
  one.way <- aov(Value ~ County, data = df)
  summary(one.way)
  
  # Perform Tukey test
  tukey_test <- TukeyHSD(one.way)
  tukey_test_df <- as.data.frame(tukey_test$`County`)
  
  
  # Export the results to CSV files
  write.csv(df, paste0(metric, "_data.csv"), row.names = FALSE)
  write.csv(tukey_test_df, paste0(metric, "_tukey.csv"), row.names = FALSE)
}
