library(ggplot2)
library(ggpubr)
library(tidyverse)
library(broom)
library(AICcmodavg)
library(xlsx)
library(openxlsx)

# set the memory limit to 8 gigabytes (you can adjust this value as needed)
options(java.parameters = "-Xmx8g") 

setwd("~/Desktop/ThirtyFourtyDocker/ls_metrics_allstat/")

# Define the names of the sheets to read
sheet_names <- c("forest_loss", "abandoned_land", "imperviousness", "roads", "bgi_fragmentation", "cumulative")

# Read in the data from all sheets and store it in a list
impacts_regions_results <- lapply(sheet_names, function(sheet_name) {
  read.xlsx2("hexagon_regions_land.xlsx", sheetName = sheet_name)
})

# Name each element of the list after the sheet it corresponds to
names(impacts_regions_results) <- sheet_names

# Define the metrics list
metrics_list <- list(
  "forest_loss" = "for_c_norm_value",
  "abandoned_land" = "ab_c_norm_value",
  "imperviousness" = "imp_c_norm_value",
  "roads" = "road_m_nor_value",
  "bgi_fragmentation" = "frag_norm_value",
  "cumulative" = "cum_norm_value",
)

# Loop over the sheets to perform the ANOVA analysis and write the results to separate files
for (i in seq_along(sheet_names)) {
  sheet_name <- sheet_names[i]
  data <- impacts_regions_results[[i]]
  metric <- metrics_list[[sheet_name]]
  
  # Perform ANOVA
  model <- aov(as.formula(paste0(metric, " ~ county")), data = data)
  summary(model)
  tukey <- TukeyHSD(model)
  tukey
  
  # Get the ANOVA table as a data frame
  anova_table <- as.data.frame(anova(model))
  
  # Write the ANOVA table to an Excel file
  write.xlsx(anova_table, file = paste0("anova_impacts_regions_results_", sheet_name, ".xlsx"), sheetName = sheet_name, append = TRUE)
}
