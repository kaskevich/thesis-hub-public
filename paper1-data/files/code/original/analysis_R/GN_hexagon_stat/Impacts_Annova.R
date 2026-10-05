#options(java.parameters = "-Xmx1024m")

library(ggplot2)
library(ggpubr)
library(tidyverse)
library(broom)
library(AICcmodavg)
# library(xlsx)
library(openxlsx)

# set the memory limit to 8 gigabytes (you can adjust this value as needed)
setwd("~/Desktop/ThirtyFourtyDocker/ls_metrics_allstat/GN_hexagon_stat/")

# Define the names of the sheets to read
sheet_names <- c("forest_loss", "abandoned_land", "imperviousness", "roads", "bgi_fragmentation", "cumulative")

# Read in the data from each sheet and store it in a list
impacts_regions_results <- lapply(sheet_names, function(sheet_name) {
  read.xlsx("~/Desktop/ThirtyFourtyDocker/ls_metrics_allstat/GN_hexagon_stat/hexagon_by_regions_gi.xlsx", sheet = sheet_name)
})

# Name each element of the list after the sheet it corresponds to
names(impacts_regions_results) <- sheet_names

# Define the impacts list
impacts_list <- list(
  forest_loss = "for_c_norm",
  abandoned_land = "ab_c_norm",
  imperviousness = "imp_c_norm",
  roads = "road_f_nor",
  bgi_fragmentation = "frag_norm",
  cumulative = "cum_norm"
)

# Read in data from "Impacts" sheet
impacts_regions_results <- read.xlsx("hexagon_by_regions_gi.xlsx", sheet = "forest_loss")

# Load the bestNormalize package
install.packages("bestNormalize")

# Load the required packages
library(bestNormalize)
library(car)

# Apply bestNormalize to the response variable
normalized_response_for <- bestNormalize(impacts_regions_results$for_c_norm)

# Extract the values from the "bestNormalize" object
normalized_response_for <- normalized_response_for$x
hist(normalized_response_for, main = "Histogram of Normalized Response Forest loss", xlab = "Normalized Response")

#Q-Q Plot to compare the quantiles of the data against a theoretical normal distribution when the data points closely follow the reference line, it indicates normality.
qqnorm(normalized_response_for, main = "Histogram of Normalized Response Forest loss", xlab = "Normalized Response")
qqline(normalized_response_for, main = "Histogram of Normalized Response Forest loss", xlab = "Normalized Response")

# Install ggpubr package (if not already installed)
install.packages("ggpubr")

# Load ggpubr package
library(ggpubr)

# Density plot for normality
log_norm_for <- log(normalized_response_for)
ggdensity(normalized_response_for, 
          main = "Density plot of Forest Cover Loss",
          xlab = "forest cover loss")
ggqqplot(normalized_response_for)

# Perform one-way ANOVA test
one.way_forest <- aov(normalized_response_for ~ impacts_regions_results$county, data = impacts_regions_results)

# Print the results
print(summary(one.way_forest))
one.way_forest

# Load the required package
library(stats)

# Extract the residuals from the ANOVA model
residuals <- residuals(one.way_forest)

# Create a histogram of the residuals
hist(residuals, main = "Histogram of Residuals Forest Cover Loss", xlab = "Residuals")

# Perform TukeyHSD for "forest_loss" sheet
forest_tukey <- TukeyHSD(one.way)
forest_tukey

# Get the ANOVA table as a data frame
anova_table_for <- as.data.frame(anova(one.way_forest))

# Write the ANOVA table to an Excel file
library(openxlsx)
write.xlsx(anova_table_for, file = "anova_impacts_forest.xlsx", sheetName = "forest_loss", append = TRUE)

# Extract relevant information from Tukey's HSD results
forest_tukey_df <- as.data.frame(forest_tukey$`impacts_regions_results$county`)

# Add "county" column to the Tukey's HSD results
forest_tukey_df$county <- rownames(forest_tukey_df)

# Write Tukey's HSD results to a CSV file
forest_impact <- "for_c_norm" 
csv_file_name <- paste("tukey_", forest_impact, ".csv", sep = "")
write.csv(forest_tukey_df, file = csv_file_name, row.names = FALSE)

# Write Tukey's HSD results to an Excel file
library(openxlsx)
excel_file_name <- paste("tukey_", forest_impact, ".xlsx", sep = "")
write.xlsx(forest_tukey_df, file = excel_file_name, sheetName = "for_c_norm", append = TRUE)



# Read in data from "abandoned_land" sheet
impacts_regions_results <- read.xlsx("hexagon_by_regions_gi.xlsx", sheet = "abandoned_land")

# Apply bestNormalize to the response variable
normalized_response_ab <- bestNormalize(impacts_regions_results$ab_c_norm)$x

# Histogram of Normalized Response
hist(normalized_response_ab, main = "Histogram of Normalized Response Abandoned Land", xlab = "Normalized Response")

# Q-Q Plot
qqnorm(normalized_response_ab, main = "Histogram of Normalized Response Abandoned Land", xlab = "Normalized Response")
qqline(normalized_response_ab, main = "Histogram of Normalized Response Abandoned Land", xlab = "Normalized Response")

# Perform one-way ANOVA test
one.way_ab <- aov(normalized_response_ab ~ county, data = impacts_regions_results)

# Print the results
print(summary(one.way_ab))
one.way_ab

# Extract the residuals from the ANOVA model
residuals <- residuals(one.way_ab)

# Create a histogram of the residuals
hist(residuals, main = "Histogram of Residuals Abandoned Land", xlab = "Residuals")


# Perform TukeyHSD for "abandoned_land" sheet
abandoned_tukey <- TukeyHSD(one.way)

# Write the ANOVA table to an Excel file
anova_table_ab <- as.data.frame(anova(one.way_ab))
write.xlsx(anova_table_ab, file = "anova_impacts_aband.xlsx", sheetName = "abandoned_land", append = TRUE)

# Extract relevant information from Tukey's HSD results
abandoned_tukey_df <- as.data.frame(abandoned_tukey$`county`)
abandoned_tukey_df$county <- rownames(abandoned_tukey_df)

# Write Tukey's HSD results to a CSV file
csv_file_name <- paste("tukey_", "ab_c_norm", ".csv", sep = "")
write.csv(abandoned_tukey_df, file = csv_file_name, row.names = FALSE)

# Write Tukey's HSD results to an Excel file
library(openxlsx)
excel_file_name <- paste("tukey_", "ab_c_norm", ".xlsx", sep = "")
write.xlsx(abandoned_tukey_df, file = excel_file_name, sheetName = "ab_c_norm", append = TRUE)



# Read in data from "imperviousness" sheet
impacts_regions_results <- read.xlsx("hexagon_by_regions_gi.xlsx", sheet = "imperviousness")

# Apply bestNormalize to the response variable
normalized_response_imperv <- bestNormalize(impacts_regions_results$imp_c_norm)$x

# Histogram of Normalized Response
hist(normalized_response_imperv, main = "Histogram of Normalized Response Imperviousness", xlab = "Normalized Response")

# Q-Q Plot
qqnorm(normalized_response_imperv, main = "Histogram of Normalized Response Imperviousness", xlab = "Normalized Response")
qqline(normalized_response_imperv, main = "Histogram of Normalized Response Imperviousness", xlab = "Normalized Response")

# Perform one-way ANOVA test
one.way_imperv <- aov(normalized_response_imperv ~ county, data = impacts_regions_results)
summary(one.way_imperv)

# Perform TukeyHSD for "imperviousness" sheet
imperv_tukey <- TukeyHSD(one.way_imperv)

# Write the ANOVA table to an Excel file
anova_table_imperv <- as.data.frame(anova(one.way_imperv))
write.xlsx(anova_table_imperv, file = "anova_impacts_imperv.xlsx", sheetName = "imperviousness", append = TRUE)

# Extract relevant information from Tukey's HSD results
imperv_tukey_df <- as.data.frame(imperv_tukey$`county`)
imperv_tukey_df$county <- rownames(imperv_tukey_df)

# Write Tukey's HSD results to a CSV file
csv_file_name_imperv <- paste("tukey_", "imp_c_norm", ".csv", sep = "")
write.csv(imperv_tukey_df, file = csv_file_name_imperv, row.names = FALSE)

# Write Tukey's HSD results to an Excel file
library(openxlsx)
excel_file_name <- paste("tukey_", "imp_c_norm", ".xlsx", sep = "")
write.xlsx(imperv_tukey_df, file = excel_file_name, sheetName = "imp_c_norm", append = TRUE)




# Read in data from "roads" sheet
impacts_regions_results <- read.xlsx("hexagon_by_regions_gi.xlsx", sheet = "roads")

# Apply bestNormalize to the response variable
normalized_response_roads <- bestNormalize(impacts_regions_results$road_f_nor)$x

# Histogram of Normalized Response
hist(normalized_response_roads, main = "Histogram of Normalized Response Fragmentation by Roads", xlab = "Normalized Response")

# Q-Q Plot
qqnorm(normalized_response_roads, main = "Histogram of Normalized Response Fragmentation by Roads", xlab = "Normalized Response")
qqline(normalized_response_roads, main = "Histogram of Normalized Response Fragmentation by Roads", xlab = "Normalized Response")

# Perform one-way ANOVA test
one.way_roads <- aov(normalized_response_roads ~ county, data = impacts_regions_results)
summary(one.way_roads)

# Perform TukeyHSD for "roads" sheet
roads_tukey <- TukeyHSD(one.way_roads)

# Write the ANOVA table to an Excel file
anova_table_roads <- as.data.frame(anova(one.way_roads))
write.xlsx(anova_table_roads, file = "anova_impacts_roads.xlsx", sheetName = "roads", append = TRUE)

# Extract relevant information from Tukey's HSD results
roads_tukey_df <- as.data.frame(roads_tukey$`county`)
roads_tukey_df$county <- rownames(roads_tukey_df)

# Write Tukey's HSD results to a CSV file
csv_file_name_roads <- paste("tukey_", "road_f_nor", ".csv", sep = "")
write.csv(roads_tukey_df, file = csv_file_name_roads, row.names = FALSE)

# Write Tukey's HSD results to an Excel file
library(openxlsx)
excel_file_name_roads <- paste("tukey_", "road_f_nor", ".xlsx", sep = "")
write.xlsx(roads_tukey_df, file = excel_file_name_roads, sheetName = "road_f_nor", append = TRUE)





# Read in data from "bgi_fragmentation" sheet
impacts_regions_results <- read.xlsx("hexagon_by_regions_gi.xlsx", sheet = "bgi_fragmentation")

# Apply bestNormalize to the response variable
normalized_response_frag <- bestNormalize(impacts_regions_results$frag_norm)$x

# Histogram of Normalized Response
hist(normalized_response_frag, main = "Histogram of Normalized Response BGI_fragmentation", xlab = "Normalized Response")

# Q-Q Plot
qqnorm(normalized_response_frag, main = "Histogram of Normalized Response BGI_fragmentation", xlab = "Normalized Response")
qqline(normalized_response_frag, main = "Histogram of Normalized Response BGI_fragmentation", xlab = "Normalized Response")

# Perform one-way ANOVA test
one.way_frag <- aov(normalized_response_frag ~ county, data = impacts_regions_results)
summary(one.way_frag)

# Perform TukeyHSD for "bgi_fragmentation" sheet
frag_tukey <- TukeyHSD(one.way_frag)

# Write the ANOVA table to an Excel file
anova_table_frag <- as.data.frame(anova(one.way_frag))
write.xlsx(anova_table_frag, file = "anova_impacts_bgifrag.xlsx", sheetName = "bgi_fragmentation", append = TRUE)

# Extract relevant information from Tukey's HSD results
frag_tukey_df <- as.data.frame(frag_tukey$`county`)
frag_tukey_df$county <- rownames(frag_tukey_df)

# Write Tukey's HSD results to a CSV file
csv_file_name_frag <- paste("tukey_", "frag_norm", ".csv", sep = "")
write.csv(frag_tukey_df, file = csv_file_name_frag, row.names = FALSE)

# Write Tukey's HSD results to an Excel file
library(openxlsx)
excel_file_name_frag <- paste("tukey_", "frag_norm", ".xlsx", sep = "")
write.xlsx(frag_tukey_df, file = excel_file_name_frag, sheetName = "frag_norm", append = TRUE)


# Read in data from "cumulative" sheet
impacts_regions_results <- read.xlsx("hexagon_by_regions_gi.xlsx", sheet = "cumulative")

# Apply bestNormalize to the response variable
normalized_response_cum <- bestNormalize(impacts_regions_results$cum_norm)$x

# Histogram of Normalized Response
hist(normalized_response_cum, main = "Histogram of Normalized Response Cumulative impact", xlab = "Normalized Response")

# Q-Q Plot
qqnorm(normalized_response_cum, main = "Histogram of Normalized Response Cumulative impact", xlab = "Normalized Response")
qqline(normalized_response_cum, main = "Histogram of Normalized Response Cumulative impact", xlab = "Normalized Response")

# Perform one-way ANOVA test
one.way_cum <- aov(normalized_response_cum ~ county, data = impacts_regions_results)
summary(one.way_cum)

# Perform TukeyHSD for "cumulative" sheet
cum_tukey <- TukeyHSD(one.way_cum)

# Write the ANOVA table to an Excel file
anova_table_cum <- as.data.frame(anova(one.way_cum))
write.xlsx(anova_table_cum, file = "anova_impacts_cum.xlsx", sheetName = "cumulative", append = TRUE)

# Extract relevant information from Tukey's HSD results
cum_tukey_df <- as.data.frame(cum_tukey$`county`)
cum_tukey_df$county <- rownames(cum_tukey_df)

# Write Tukey's HSD results to a CSV file
csv_file_name_cum <- paste("tukey_", "cum_norm", ".csv", sep = "")
write.csv(cum_tukey_df, file = csv_file_name_cum, row.names = FALSE)

# Write Tukey's HSD results to an Excel file
library(openxlsx)
excel_file_name_cum <- paste("tukey_", "cum_norm", ".xlsx", sep = "")
write.xlsx(cum_tukey_df, file = excel_file_name_cum, sheetName = "cum_norm", append = TRUE)



















# Read in data from "bgi_fragmentation" sheet
impacts_regions_results <- read.xlsx("hexagon_by_regions_gi.xlsx", sheet = "bgi_fragmentation")

# Perform ANOVA for "bgi_fragmentation" sheet
one.way <- aov(frag_norm ~ county, data = impacts_regions_results)
summary(one.way)
frag_tukey <- TukeyHSD(one.way)
frag_tukey

# Fit the ANOVA model
model <- aov(frag_norm ~ county, data = impacts_regions_results)

# Get the ANOVA table as a data frame
anova_table <- as.data.frame(anova(model))

# Write the ANOVA table to an Excel file
write.xlsx(anova_table, file = "anova_impacts_bgifrag.xlsx", sheetName = "bgi_fragmentation", append = TRUE)

# Extract relevant information from Tukey's HSD results
frag_tukey_df <- as.data.frame(frag_tukey$`county`)

# Add "county" column to the Tukey's HSD results
frag_tukey_df$county <- rownames(frag_tukey_df)

# Write Tukey's HSD results to a CSV file
frag_impact <- "frag_norm" 
csv_file_name <- paste("tukey_", frag_impact, ".csv", sep = "")
write.csv(frag_tukey_df, file = csv_file_name, row.names = FALSE)

# Read in data from "cumulative" sheet
impacts_regions_results <- read.xlsx("hexagon_by_regions_gi.xlsx", sheet = "cumulative")

# Perform ANOVA for "cumulative" sheet
one.way <- aov(cum_norm ~ county, data = impacts_regions_results)
summary(one.way)
cum_tukey <- TukeyHSD(one.way)
cum_tukey

# Fit the ANOVA model
model <- aov(cum_norm ~ county, data = impacts_regions_results)

# Get the ANOVA table as a data frame
anova_table <- as.data.frame(anova(model))

# Write the ANOVA table to an Excel file
write.xlsx(anova_table, file = "anova_impacts_cum.xlsx", sheetName = "cumulative", append = TRUE)

# Extract relevant information from Tukey's HSD results
cum_tukey_df <- as.data.frame(cum_tukey$`county`)

# Add "county" column to the Tukey's HSD results
cum_tukey_df$county <- rownames(cum_tukey_df)

# Write Tukey's HSD results to a CSV file
cum_impact <- "cum_norm" 
csv_file_name <- paste("tukey_", cum_impact, ".csv", sep = "")
write.csv(cum_tukey_df, file = csv_file_name, row.names = FALSE)

library(openxlsx)

# Create a new workbook
new_workbook <- createWorkbook()

# List of file names
file_names <- c("anova_impacts_forest.xlsx", "anova_impacts_aband.xlsx", "anova_impacts_imperv.xlsx", 
                "anova_impacts_roads.xlsx", "anova_impacts_bgifrag.xlsx", "anova_impacts_cum.xlsx")

# Loop through the files and add each sheet to the new workbook
for (i in seq_along(file_names)) {
  # Get sheet name from file name
  sheet_name <- tools::file_path_sans_ext(basename(file_names[i]))
  
  # Read in data from sheet
  sheet_data <- read.xlsx(file_names[i], sheet = 1)
  
  # Add sheet to new workbook
  addWorksheet(new_workbook, sheet_name)
  writeData(new_workbook, sheet_name, sheet_data)
}

# Save the new workbook
saveWorkbook(new_workbook, "impacts_annova_data.xlsx")

# Loop through each impact and save Tukey test results to Excel or CSV file
for (impact in names(impacts_list)) {
  
  # Get the ANOVA model
  model <- aov(as.formula(paste(impacts_list[[impact]], "~ county")), data = impacts_regions_results[[impact]])
  
  # Perform Tukey test
  tukey <- TukeyHSD(model)
  
  # Convert Tukey test results to data frame
  tukey_df <- as.data.frame(tukey)
  
  # Write Tukey test results to Excel or CSV file
  if (file.exists(paste("tukey_", impact, ".xlsx", sep = ""))) {
    file.remove(paste("tukey_", impact, ".xlsx", sep = ""))
  }
}
write.xlsx(tukey_df, file = paste("tukey_", impact, ".xlsx", sep = ""), sheetName = impact, append = TRUE)

















