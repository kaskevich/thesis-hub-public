library(dplyr)
library(ggplot2)
library(readxl)
library(scales)
library(stringr)

# Set your working directory
setwd("~/Desktop/ThirtyFourtyDocker/ls_metrics_allstat/bgi_content")

# Read the data from the Excel file
file_path <- "branches_updated.xlsx"
sheet_name <- "branches"
data <- readxl::read_excel(file_path, sheet = sheet_name)

# Check data types of columns
column_types <- sapply(data, class)
print(column_types)

# Filter the data
filtered_data <- data %>%
  filter(!is.na(class) & class == "natura2000" & area > 10000)  # area is in square meters, 1 hectare = 10,000 square meters

# Convert area to hectares
filtered_data$area_hectares <- filtered_data$area / 10000

# Filter and process data for each region
regions <- c("Harju", "Hiiu", "Ida-Viru", "Laane-Viru", "Laane", "Parnu", "Saare")
region_data <- lapply(regions, function(region) {
  region_filtered <- filtered_data %>%
    filter(region == !!region & !is.na(natura_cod))
  region_filtered$natura_cod <- as.character(region_filtered$natura_cod)
  return(region_filtered)
})

names(region_data) <- regions

# Combine data from all regions
combined_data <- bind_rows(region_data)

# Define colors for each natura_cod with a smooth transition
natura_cod_colors <- colorRampPalette(c("#FFA07A", "#FFD700", "#00008B", "#FF69B4", "#FFB6C1", "#006400", "#00FFFF", "#87CEFA", "#008080", "#32CD32", "#8B4513", "#FF6347", "#9400D3", "#8FBC8F", "#778899", "#556B2F", "#D2B48C", "#3CB371", "#00CED1", "#8B0000", "#00BFFF", "#000000"))(length(unique(filtered_data$natura_cod)))

# Define labels for Natura Code
natura_cod_labels <- c(
  "91D0" = "(91D0) Bog woodland",
  "9180" = "(9180) Tilio-Acerion forests of slopes",
  "9080" = "(9080) Fennoscandian deciduous swamp woods",
  "9070" = "(9070) Fennoscandian wooded pastures",
  "9050" = "(9050) Fennoscandian herb-rich forests with Picea abies",
  "9020" = "(9020) Fennoscandian hemiboreal natural old broad-leaved deciduous forests",
  "9010" = "(9010) Western Taïga",
  "7230" = "(7230) Alkaline fens",
  "7210" = "(7210) Calcareous fens with Cladium mariscus & species of the Caricion davallianae",
  "7140"  = "(7140) Transition mires and quaking bogs",
  "7120" = "(7120) Degraded raised bogs still capable of natural regeneration",
  "7110" = "(7110) Active raised bogs",
  "6530" = "(6530) Fennoscandian wooded meadows",
  "6510" = "(6510) Lowland hay meadows (Alopecurus pratensis, Sanguisorba officinalis)",
  "6450" = "(6450) Northern boreal alluvial meadows",
  "6430" = "(6430) Hydrophilous tall herb fringe communities of plains and of the montane to alpine levels",
  "6410" = "(6410) Molinia meadows on calcareous, peaty or clayey-silt-laden soils (Molinion caeruleae)",
  "6280" = "(6280) Nordic alvar and precambrian calcareous flatrocks",
  "6270" = "(6270) Fennoscandian lowland species-rich dry to mesic grasslands",
  "6210" = "(6210) Semi-natural dry grasslands and scrubland facies on calcareous substrates",
  "5130" = "(5130) Juniperus communis formations on heaths or calcareous grasslands",
  "2190" = "(2190) Humid dune slacks",
  "2180" = "(2180) Wooded dunes of the Atlantic, Continental and Boreal region",
  "2130" = "(2130) Fixed coastal dunes with herbaceous vegetation ('grey dunes')",
  "1640" = "(1640) Boreal Baltic sandy beaches with perennial vegetation",
  "1630" = "(1630) Boreal Baltic coastal meadows",
  "1220" = "(1220) Perennial vegetation of stony banks",
  "1620" = "(1620) Boreal Baltic islets and small islands",
  "-"    = "N/A"
)

# Convert 'area' to numeric
filtered_data <- mutate(filtered_data, natura_cod = factor(natura_cod), area = as.numeric(area))

# Create the plot
plot_data <- filtered_data %>%
  group_by(region, natura_cod) %>%
  summarise(area_sum = sum(area)) %>%
  arrange(desc(area_sum)) %>%
  group_by(region) %>%
  top_n(10, wt = area_sum)

# Define breaks and minor breaks for the log scale
breaks <- c(1, 10, 100, 1000, 5000)
minor_breaks <- c(2, 3, 4, 5, 6, 7, 8, 9, 20, 30, 40, 50, 60, 70, 80, 90, 200, 300, 400, 500, 600, 700, 800, 900, 2000, 3000, 4000)

# Create a bar plot for each region and stack them together
ggplot(plot_data, aes(y = area_sum / 10000, x = reorder(natura_cod, -area_sum), fill = natura_cod)) +
  geom_bar(stat = "identity", width = 0.7) +
  geom_text(aes(label = round(area_sum / 10000, 1)), 
            vjust = -0.3, size = 2.5) +  # Move text labels to the top of the bars
  labs(title = "Dominant Natura 2000 habitat types in the branch areas of Green Infrastructure on Estonian coast",
       y = "Area (in Hectares, log scale)",
       x = "Natura Code") +
  theme_minimal(base_size = 12) +
  facet_wrap(~region, scales = "free_x", ncol = 2) +
  scale_fill_manual(
    values = natura_cod_colors,
    labels = natura_cod_labels,
    name = NULL  # Remove the legend title
  ) +
  theme(
    legend.position = "bottom",
    legend.justification = "left",  # Align the legend to the left
    legend.box.just = "left",  # Align the legend box to the left
    legend.text = element_text(size = 12),
    legend.title = element_text(size = 12),
    strip.text = element_text(size = 14),
    axis.title = element_text(size = 14),
    axis.text.x = element_text(size = 12, angle = 90, hjust = 1),  # Rotate x-axis labels vertically
    axis.text.y = element_text(size = 12),  # Keep y-axis labels horizontal
    legend.key.height = unit(0.4, "cm"),  # Adjust the height of the legend keys
    legend.key.width = unit(0.4, "cm")    # Adjust the width of the legend keys
  ) +
  guides(fill = guide_legend(ncol = 1)) +
  scale_y_log10(breaks = breaks, minor_breaks = minor_breaks)
