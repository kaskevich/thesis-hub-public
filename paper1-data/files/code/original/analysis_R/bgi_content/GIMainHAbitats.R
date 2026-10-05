library(dplyr)
library(knitr)

# Define the data frame with habitat types and their corresponding hectares and percentage
habitats <- data.frame(
  HabitatType = c(
    "Forests", "Grasslands", "Total of Annex I Habitats",
    "Western Taïga", "Fennoscandian deciduous swamp woods",
    "Fennoscandian hemiboreal natural old broad-leaved deciduous forests",
    "Fennoscandian wooded pastures", "Boreal Baltic coastal meadows",
    "Semi-natural dry grasslands and scrubland facies on calcareous substrates",
    "Fennoscandian lowland species-rich dry to mesic grasslands",
    "Hydrophilous tall herb fringe communities of plains and of the montane to alpine levels",
    "Northern boreal alluvial meadows", "Lowland hay meadows (Alopecurus pratensis, Sanguisorba officinalis)",
    "Fennoscandian wooded meadows", "Nordic alvar and precambrian calcareous flatrocks",
    "Wooded dunes of the Atlantic, Continental and Boreal region",
    "Juniperus communis formations on heaths or calcareous grasslands",
    "Active raised bogs", "Degraded raised bogs still capable of natural regeneration",
    "Transition mires and quaking bogs", "Calcareous fens with Cladium mariscus and species of the Caricion davallianae",
    "Alkaline fens", "Bog woodland", "Other forested land", "Permanent grasslands"
  ),
  TotalHectares = c(
    41138.5, 39810, 86996,
    17568, 9620, 2165, 2721.5, 18890, 1005, 430, 500, 3220, 1865, 2210,
    12190, 4600, 2424, 1700, 200, 200, 700, 2747.5, 2040, 143009, 164
  ),
  PercentageGI = c(
    14.52, 14.05, 30.71,
    6.2, 3.4, 0.76, 0.96, 6.67, 0.35, 0.15, 0.18, 1.14, 0.66, 0.78,
    4.3, 1.62, 0.86, 0.6, 0.07, 0.07, 0.25, 0.97, 0.72, 50.04, 0.05
  )
)

# Summarize the data for Forests and Grasslands
summary <- habitats %>% 
  slice(1:3) %>% 
  kable(col.names = c("Habitat Type", "Total Hectares", "% of Coastal GI Total"), 
        caption = "Summary of Generalized Habitat Data")

# Detailed data for Annex I Habitats
detailed <- habitats %>% 
  slice(4:n()) %>% 
  kable(col.names = c("Habitat Type", "Total Hectares", "% of Coastal GI Total"), 
        caption = "Detailed Annex I Habitat Data")

# Print the tables
print(summary)
print(detailed)

library(ggplot2)
library(gridExtra)
library(grid)
library(tibble)

# Data preparation
# Using the combined_df data frame from the earlier code
combined_df <- tribble(~"General Category", ~"Total Hectares", ~"Percentage of Coastal GI Total", ~"Specific Habitat Type",
  "Forests", 143009.5, 50.04, "",
  "Permanent grasslands", 164, 0.05, "",
  "Total of Annex I Habitats", 86996, 30.71, "",
  "", 17568, 6.20, "(9010) Western Taïga",
  "", 9620, 3.40, "(9080) Fennoscandian deciduous swamp woods",
  "", 2165, 0.76, "(9020) Fennoscandian hemiboreal natural old broad-leaved deciduous forests",
  "", 2721.5, 0.96, "(9070) Fennoscandian wooded pastures",
  "", 18890, 6.67, "(1630) Boreal Baltic coastal meadows",
  "", 1005, 0.35, "(6210) Semi-natural dry grasslands and scrubland facies on calcareous substrates",
  "", 430, 0.15, "(6270) Fennoscandian lowland species-rich dry to mesic grasslands",
  "", 500, 0.18, "(6430) Hydrophilous tall herb fringe communities of plains and of the montane to alpine levels",
  "", 3220, 1.14, "(6450) Northern boreal alluvial meadows",
  "", 1865, 0.66, "(6510) Lowland hay meadows (Alopecurus pratensis, Sanguisorba officinalis)",
  "", 2210, 0.78, "(6530) Fennoscandian wooded meadows",
  "", 12190, 4.30, "(6280) Nordic alvar and precambrian calcareous flatrocks",
  "", 4600, 1.62, "(2180) Wooded dunes of the Atlantic, Continental and Boreal region",
  "", 2424, 0.86, "(5130) Juniperus communis formations on heaths or calcareous grasslands",
  "", 1700, 0.60, "(7110) Active raised bogs",
  "", 200, 0.07, "(7120) Degraded raised bogs still capable of natural regeneration",
  "", 200, 0.07, "(7140) Transition mires and quaking bogs",
  "", 700, 0.25, "(7210) Calcareous fens with Cladium mariscus and species of the Caricion davallianae",
  "", 2747.5, 0.97, "(7230) Alkaline fens",
  "", 2040, 0.72, "(91D0) Bog woodland"
)

# Convert to data frame for plotting
combined_df <- as.data.frame(combined_df)

# Create a table plot
table_plot <- tableGrob(combined_df)

# Display the table plot
grid.arrange(table_plot)

# Create a table plot without row names
table_plot <- tableGrob(combined_df, rows=NULL, theme=ttheme_default(base_size=10, core=list(fg_params=list(hjust=0, x=0.01), wrap=TRUE)))

# Display the table plot
grid.newpage()
grid.draw(table_plot)





