library(dplyr)
library(ggplot2)
library(readxl)
library(scales)
library(stringr)

# Set your working directory
setwd("~/Desktop/ThirtyFourtyDocker/ls_metrics_allstat/bgi_content")

# Read the data from the Excel file, skipping the first row
file_path <- "cores_updated.xlsx"
sheet_name <- "cores"
data <- readxl::read_excel(file_path, sheet = sheet_name)

# Check data types of columns
column_types <- sapply(data, class)
print(column_types)

# Filter the data
filtered_data <- data %>%
  filter(!is.na(class) & class == "natura2000" & area > 10000)  # area is in square meters, 1 hectare = 10,000 square meters

str(data)
names(data)

filtered_data 

# Convert area to hectares
filtered_data$area_hectares <- filtered_data$area / 10000

# Filter the data for the Harju region
harju_data <- filtered_data %>%
  filter(region == "Harju")

harju_data <- harju_data %>%
  filter(!is.na(natura_cod))

harju_data$natura_cod <- as.character(harju_data$natura_cod)

ggplot(harju_data, aes(x = area_hectares, y = natura_cod)) +
  geom_bar(stat = "identity", fill = "black", color = "black", na.rm = TRUE) +
  labs(title = "Cores Natura 2000 Sites in Harju Region",
       x = "Area (in Hectares)",
       y = "Natura Code") +
  theme_minimal(base_size = 14)

# Filter the data for the Hiiu region
hiiu_data <- filtered_data %>%
  filter(region == "Hiiu")

hiiu_data <- hiiu_data %>%
  filter(!is.na(natura_cod))

hiiu_data$natura_cod <- as.character(hiiu_data$natura_cod)

# Create a bar plot
ggplot(hiiu_data, aes(x = area / 10000, y = natura_cod)) +
  geom_bar(stat = "identity", fill = "black", color = "black") +
  labs(title = "Cores Natura 2000 Sites in Hiiu Region",
       x = "Area (in Hectares)",
       y = "Natura Code") +
  theme_minimal(base_size = 14)

# Filter the data for the Ida-Viru region
idaviru_data <- filtered_data %>%
  filter(region == "Ida-Viru")

idaviru_data <- idaviru_data %>%
  filter(!is.na(natura_cod))

idaviru_data$natura_cod <- as.character(idaviru_data$natura_cod)

# Create a bar plot
ggplot(idaviru_data, aes(x = area / 10000, y = natura_cod)) +
  geom_bar(stat = "identity", fill = "black", color = "black") +
  labs(title = "Cores Natura 2000 Sites in Ida-Viru Region",
       x = "Area (in Hectares)",
       y = "Natura Code") +
  theme_minimal(base_size = 14)

# Filter the data for the Laane-Viru region
laanelviru_data <- filtered_data %>%
  filter(region == "Laane-Viru")

laanelviru_data <- laanelviru_data %>%
  filter(!is.na(natura_cod))

laanelviru_data$natura_cod <- as.character(laanelviru_data$natura_cod)

# Create a bar plot
ggplot(laanelviru_data, aes(x = area / 10000, y = natura_cod)) +
  geom_bar(stat = "identity", fill = "black", color = "black") +
  labs(title = "Cores Natura 2000 Sites in Laane-Viru Region",
       x = "Area (in Hectares)",
       y = "Natura Code") +
  theme_minimal(base_size = 14)

# Filter the data for the Laane region
laane_data <- filtered_data %>%
  filter(region == "Laane")

laane_data <- laane_data %>%
  filter(!is.na(natura_cod))

laane_data$natura_cod <- as.character(laane_data$natura_cod)

# Create a bar plot
ggplot(laane_data, aes(x = area / 10000, y = natura_cod)) +
  geom_bar(stat = "identity", fill = "black", color = "black") +
  labs(title = "Cores Natura 2000 Sites in Laane Region",
       x = "Area (in Hectares)",
       y = "Natura Code") +
  theme_minimal(base_size = 14)

# Filter the data for the Parnu region
parnu_data <- filtered_data %>%
  filter(region == "Parnu")

parnu_data <- parnu_data %>%
  filter(!is.na(natura_cod))

parnu_data$natura_cod <- as.character(parnu_data$natura_cod)

# Create a bar plot
ggplot(parnu_data, aes(x = area / 10000, y = natura_cod)) +
  geom_bar(stat = "identity", fill = "black", color = "black") +
  labs(title = "Cores Natura 2000 Sites in Parnu Region",
       x = "Area (in Hectares)",
       y = "Natura Code") +
  theme_minimal(base_size = 14)

# Filter the data for the Saare region
saare_data <- filtered_data %>%
  filter(region == "Saare")

saare_data <- saare_data %>%
  filter(!is.na(natura_cod))

saare_data$natura_cod <- as.character(saare_data$natura_cod)

# Create a bar plot
ggplot(saare_data, aes(x = area / 10000, y = natura_cod)) +
  geom_bar(stat = "identity", fill = "black", color = "black") +
  labs(title = "Cores Natura 2000 Sites in Saare Region",
       x = "Area (in Hectares)",
       y = "Natura Code") +
  theme_minimal(base_size = 14)

# Define colors for each natura_cod with better differentiation
natura_cod_colors <- c(
  "91D0" = "#FFA07A",  # LightSalmon
  "9080" = "#FFD700",  # Gold
  "9070" = "#00008B",  # Blue
  "9050" = "#FF69B4",  # HotPink
  "9020" = "#FFB6C1",  # LightPink
  "9010" = "#006400",  # Dark Green
  "7230" = "#00FFFF",  # Aqua
  "7210" = "#87CEFA",  # LightSkyBlue
  "140"  = "#008080",  # Teal
  "7120" = "#32CD32",  # LimeGreen
  "7110" = "#8B4513",  # SaddleBrown
  "6530" = "#FF6347",  # Tomato
  "6450" = "#9400D3",  # DarkViolet
  "6430" = "#8FBC8F",  # LightGreen
  "6280" = "#778899",  # LightSlateGray
  "6270" = "#556B2F",  # DarkOliveGreen
  "6210" = "#D2B48C",  # Tan
  "5130" = "#3CB371",  # MediumSeaGreen
  "2190" = "#00CED1",  # DarkTurquoise
  "2180" = "#8B0000",  # Dark red
  "1630" = "#00BFFF",  # DeepSkyBlue
  "-"    = "#000000"   # Black
)

# Define labels for Natura Code
natura_cod_labels <- c(
  "91D0" = "(91D0) Bog woodland",
  "9080" = "(9080) Fennoscandian deciduous swamp woods",
  "9070" = "(9070) Fennoscandian wooded pastures",
  "9050" = "(9050) Fennoscandian herb-rich forests with Picea abies",
  "9020" = "(9020) Fennoscandian hemiboreal natural old broad-leaved deciduous forests",
  "9010" = "(9010) Western Taïga",
  "7230" = "(7230) Alkaline fens",
  "7210" = "(7210) Calcareous fens with Cladium mariscus and species of the Caricion davallianae",
  "7140"  = "(7140) Transition mires and quaking bogs",
  "7120" = "(7120) Degraded raised bogs still capable of natural regeneration",
  "7110" = "(7110) Active raised bogs",
  "6530" = "(6530) Fennoscandian wooded meadows",
  "6450" = "(6450) Northern boreal alluvial meadows",
  "6430" = "(6430) Hydrophilous tall herb fringe communities of plains and of the montane to alpine levels",
  "6280" = "(6280) Nordic alvar and precambrian calcareous flatrocks",
  "6270" = "(6270) Fennoscandian lowland species-rich dry to mesic grasslands",
  "6210" = "(6210) Semi-natural dry grasslands and scrubland facies on calcareous substrates",
  "5130" = "(5130) Juniperus communis formations on heaths or calcareous grasslands",
  "2190" = "(2190) Humid dune slacks",
  "2180" = "(2180) Wooded dunes of the Atlantic, Continental and Boreal region",
  "1630" = "(1630) Boreal Baltic coastal meadows",
  "-"    = "N/A"
)

# Convert 'area' to numeric
filtered_data <- mutate(filtered_data, natura_cod = factor(natura_cod), area = as.numeric(area))

plot_data <- filtered_data %>%
  group_by(region, natura_cod) %>%
  summarise(area_sum = sum(area)) %>%
  arrange(desc(area_sum)) %>%
  group_by(region) %>%
  top_n(10, wt = area_sum)

# Create a bar plot for each region and stack them together
ggplot(plot_data, aes(x = area_sum / 10000, y = natura_cod, fill = natura_cod)) +
  geom_bar(stat = "identity") +
  labs(title = "Top 10 Cores Natura 2000 Sites in Estonian coast",
       x = "Area (in Hectares)",
       y = "Natura Code") +
  theme_minimal(base_size = 15) +
  facet_wrap(~region, scales = "free_y", ncol = 2) +
  scale_fill_manual(
    values = natura_cod_colors,
    labels = natura_cod_labels,
    name = "Natura Code"
  ) +
  theme(legend.position = "bottom", 
        legend.text = element_text(size = 14),
        legend.title = element_text(size = 16),
        strip.text = element_text(size = 14),
        axis.title = element_text(size = 16),
        axis.text = element_text(size = 14))

# Define colors for each natura_cod with a smooth transition
natura_cod_colors <- colorRampPalette(c("#FFA07A", "#FFD700", "#00008B", "#FF69B4", "#FFB6C1", "#006400", "#00FFFF", "#87CEFA", "#008080", "#32CD32", "#8B4513", "#FF6347", "#9400D3", "#8FBC8F", "#778899", "#556B2F", "#D2B48C", "#3CB371", "#00CED1", "#8B0000", "#00BFFF", "#000000"))(length(unique(filtered_data$natura_cod)))

# Define labels for Natura Code
natura_cod_labels <- c(
  "91D0" = "(91D0) Bog woodland",
  "9180" = "(9180) Tilio-Acerion forests of slopes",
  "9080" = "(9080) Fennoscandian deciduous swamp woods",
  "9070" = "(9070) Fennoscandian wooded pastures",
  "9050" = "(9050) Fennoscandian herb-rich forests 
  with Picea abies",
  "9020" = "(9020) Fennoscandian hemiboreal natural 
  old broad-leaved deciduous forests",
  "9010" = "(9010) Western Taïga",
  "7230" = "(7230) Alkaline fens",
  "7210" = "(7210) Calcareous fens with Cladium 
  mariscus & species of the Caricion davallianae",
  "7140"  = "(7140) Transition mires and quaking bogs",
  "7120" = "(7120) Degraded raised bogs 
  still capable of natural regeneration",
  "7110" = "(7110) Active raised bogs",
  "6530" = "(6530) Fennoscandian wooded meadows",
  "6510" = "(6510) Lowland hay meadows 
  (Alopecurus pratensis, Sanguisorba officinalis)",
  "6450" = "(6450) Northern boreal alluvial meadows",
  "6430" = "(6430) Hydrophilous tall herb fringe communities of plains 
  and of the montane to alpine levels",
  "6410" = "(6410) Molinia meadows on calcareous, peaty or 
  clayey-silt-laden soils (Molinion caeruleae)",
  "6280" = "(6280) Nordic alvar and precambrian calcareous flatrocks",
  "6270" = "(6270) Fennoscandian lowland species-rich dry 
  to mesic grasslands",
  "6210" = "(6210) Semi-natural dry grasslands and scrubland facies 
  on calcareous substrates",
  "5130" = "(5130) Juniperus communis formations on heaths or 
  calcareous grasslands",
  "2190" = "(2190) Humid dune slacks",
  "2180" = "(2180) Wooded dunes of the Atlantic, Continental 
  and Boreal region",
  "2130" = "(2130) Fixed coastal dunes with herbaceous vegetation ('grey dunes')",
  "1640" = "(1640) Boreal Baltic sandy beaches with perennial vegetation",
  "1630" = "(1630) Boreal Baltic coastal meadows",
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

# Create a bar plot for each region and stack them together
ggplot(plot_data, aes(x = area_sum / 10000, y = natura_cod, fill = natura_cod)) +
  geom_bar(stat = "identity") +
  labs(title = "Dominant Natura 2000 habitat types in the core areas of Green Infrastructure on Estonian coast",
       x = "Area (in Hectares)",
       y = "Natura Code") +
  theme_minimal(base_size = 13.5) +
  facet_wrap(~region, scales = "free_y", ncol = 2) +
  scale_fill_manual(
    values = natura_cod_colors,
    labels = natura_cod_labels,
    name = NULL  # Remove the legend title
  ) +
  theme(legend.position = "bottom", ,
        legend.justification = "left",  # Align the legend to the left
        legend.box.just = "left",  # Align the legend box to the left
        legend.text = element_text(size = 13.5),
        legend.title = element_text(size = 13.5),
        strip.text = element_text(size = 13),
        axis.title = element_text(size = 13),
        axis.text = element_text(size = 13)) +
  guides(fill = guide_legend(ncol = 2))+
  coord_cartesian(xlim = c(0, 5100))  # Set x-axis limit


