# Load necessary libraries
library(ggplot2)
library(reshape2)
library(gridExtra)

# Core Areas Data
core_data <- data.frame(
  Habitat.Type = c("Western Taïga", "Boreal Baltic Coastal Meadows", "Nordic Alvar and Precambrian Calcareous Flatrocks",
                   "Fennoscandian Deciduous Swamp Woods", "Northern Boreal Alluvial Meadows", "Wooded Dunes of the Atlantic, Continental, and Boreal Region",
                   "Bog Woodland", "Fennoscandian Hemiboreal Natural Old Broad-leaved Deciduous Forests", "Fennoscandian Wooded Pastures",
                   "Alkaline Fens", "Active Raised Bogs", "Fennoscandian Wooded Meadows", "Juniperus Communis Formations on Heaths or Calcareous Grasslands",
                   "Lowland Hay Meadows (Alopecurus Pratensis, Sanguisorba Officinalis)", "Semi-natural Dry Grasslands and Scrubland Facies on Calcareous Substrates",
                   "Hydrophilous Tall Herb Fringe Communities of Plains and of the Montane to Alpine Levels", "Fennoscandian Lowland Species-rich Dry to Mesic Grasslands",
                   "Degraded Raised Bogs Still Capable of Natural Regeneration", "Transition Mires and Quaking Bogs", "Calcareous Fens with Cladium Mariscus and Species of the Caricion Davallianae"),
  Habitat.Code = c("9010", "1630", "6280", "9080", "6450", "2180", "91D0", "9020", "9070", "7230", "7110", "6530", "5130", "6510", "6210", "6430", "6270", "7120", "7140", "7210"),
  Harju = c(2000, 100, 1500, 1200, 0, 300, 700, 600, 0, 100, 500, 200, 0, 200, 450, 0, 50, 0, 200, 50),
  Laane_Viru = c(3000, 0, 0, 500, 0, 0, 400, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 200, 0, 0),
  Saare = c(5000, 2900, 4000, 1000, 0, 800, 100, 400, 900, 600, 0, 1100, 1000, 0, 0, 0, 0, 0, 0, 0),
  Hiiu = c(3000, 1200, 800, 900, 0, 1100, 300, 100, 400, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
  Parnu = c(700, 1800, 400, 1000, 1700, 800, 400, 600, 150, 400, 1200, 300, 0, 400, 0, 300, 0, 0, 0, 0),
  Ida_Viru = c(0, 0, 0, 45, 0, 60, 70, 200, 0, 0, 0, 0, 50, 0, 0, 0, 30, 0, 0, 0),
  Laane = c(0, 2500, 250, 2000, 1500, 0, 70, 100, 400, 700, 0, 100, 0, 50, 0, 100, 150, 0, 0, 0)
)

# Melt data to long format
core_data_melt <- melt(core_data, id.vars = c("Habitat.Type", "Habitat.Code"))

# Summarize data by Habitat.Code
core_summary <- aggregate(value ~ Habitat.Code, data = core_data_melt, sum)

# Corridor Areas Data
corridor_data <- data.frame(
  Habitat.Type = c("Boreal Baltic Coastal Meadows", "Nordic Alvar and Precambrian Calcareous Flatrocks", "Western Taïga",
                   "Fennoscandian Deciduous Swamp Woods", "Wooded Dunes of the Atlantic, Continental, and Boreal Region",
                   "Juniperus Communis Formations on Heaths or Calcareous Grasslands", "Lowland Hay Meadows (Alopecurus Pratensis, Sanguisorba Officinalis)",
                   "Alkaline Fens", "Fennoscandian Wooded Pastures", "Calcareous Fens with Cladium Mariscus and Species of the Caricion Davallianae",
                   "Fennoscandian Wooded Meadows", "Fennoscandian Lowland Species-rich Dry to Mesic Grasslands", "Semi-natural Dry Grasslands and Scrubland Facies on Calcareous Substrates",
                   "Fennoscandian Hemiboreal Natural Old Broad-leaved Deciduous Forests", "Tilio-Acerion Forests of Slopes, Screes and Ravines"),
  Habitat.Code = c("1630", "6280", "9010", "9080", "2180", "5130", "6510", "7230", "9070", "7210", "6530", "6270", "6210", "9020", "9180"),
  Harju = c(350, 800, 700, 500, 500, 0, 350, 0, 0, 0, 0, 0, 0, 0, 0),
  Laane_Viru = c(130, 70, 510, 250, 40, 0, 100, 0, 0, 0, 0, 0, 0, 0, 50),
  Saare = c(3200, 3100, 1400, 600, 350, 900, 100, 800, 800, 450, 450, 200, 0, 0, 0),
  Hiiu = c(1800, 300, 400, 300, 70, 0, 30, 0, 0, 0, 0, 0, 0, 0, 0),
  Parnu = c(1600, 400, 400, 350, 480, 270, 400, 100, 0, 200, 0, 200, 300, 150, 0),
  Ida_Viru = c(0, 20, 0, 200, 80, 0, 70, 0, 0, 0, 0, 0, 0, 0, 0),
  Laane = c(1550, 250, 400, 700, 20, 0, 100, 0, 0, 0, 0, 0, 0, 0, 0)
)

# Melt data to long format
corridor_data_melt <- melt(corridor_data, id.vars = c("Habitat.Type", "Habitat.Code"))

# Summarize data by Habitat.Code
corridor_summary <- aggregate(value ~ Habitat.Code, data = corridor_data_melt, sum)

# Branch Areas Data
branch_data <- data.frame(
  Habitat.Type = c("Boreal Baltic Coastal Meadows", "Nordic Alvar and Precambrian Calcareous Flatrocks", 
                   "Juniperus Communis Formations on Heaths or Calcareous Grasslands", "Semi-natural Dry Grasslands and Scrubland Facies on Calcareous Substrates", 
                   "Fennoscandian Deciduous Swamp Woods", "Fennoscandian Wooded Pastures", "Lowland Hay Meadows (Alopecurus Pratensis, Sanguisorba Officinalis)", 
                   "Fennoscandian Wooded Meadows", "Western Taïga", "Alkaline Fens", "Northern Boreal Alluvial Meadows", 
                   "Fennoscandian Hemiboreal Natural Old Broad-leaved Deciduous Forests", "Tilio-Acerion Forests of Slopes, Screes and Ravines"),
  Habitat.Code = c("1630", "6280", "5130", "6210", "9080", "9070", "6510", "6530", "9010", "7230", "6450", "9020", "9180"),
  Harju = c(35, 45, 4, 30, 15, 0, 15, 0, 3, 0, 0, 0, 4),
  Laane_Viru = c(5, 0, 0, 0, 5, 2, 0, 0, 0, 2, 0, 0, 4),
  Saare = c(700, 180, 100, 90, 10, 20, 20, 50, 20, 20, 0, 15, 0),
  Hiiu = c(210, 25, 40, 10, 20, 20, 10, 0, 10, 0, 0, 0, 0),
  Parnu = c(360, 10, 20, 20, 5, 10, 20, 10, 10, 15, 20, 0, 0),
  Ida_Viru = c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
  Laane = c(450, 40, 40, 15, 20, 20, 0, 0, 15, 10, 0, 0, 0)
)

# Melt data to long format
branch_data_melt <- melt(branch_data, id.vars = c("Habitat.Type", "Habitat.Code"))

# Summarize data by Habitat.Code
branch_summary <- aggregate(value ~ Habitat.Code, data = branch_data_melt, sum)

# Merge summaries
merged_summary <- merge(core_summary, corridor_summary, by = "Habitat.Code", all = TRUE)
merged_summary <- merge(merged_summary, branch_summary, by = "Habitat.Code", all = TRUE)
colnames(merged_summary) <- c("Habitat.Code", "Core.Total", "Corridor.Total", "Branch.Total")
merged_summary[is.na(merged_summary)] <- 0

# Core and Corridor plot
p1 <- ggplot() +
  geom_bar(data = merged_summary, aes(x = Habitat.Code, y = Core.Total, fill = "Core Total"), 
           stat = "identity", position = "dodge", alpha = 0.7) +
  geom_bar(data = merged_summary, aes(x = Habitat.Code, y = Corridor.Total, fill = "Corridor Total"), 
           stat = "identity", position = "dodge", alpha = 0.7) +
  labs(title = "Annex I Habitat Types Prevalent in Green Infrastructure Core and Corridor Areas Along Estonian Coast",
       y = "Area (in Hectares)") +
  theme_bw() +
  theme(plot.title = element_text(size = 14),
        axis.title.x = element_blank(),
        axis.title.y = element_text(size = 13),
        axis.text.x = element_text(angle = 90, hjust = 1, size = 13),
        axis.text.y = element_text(size = 13),
        legend.title = element_blank(),
        legend.text = element_text(size = 13),
        legend.position = "top") +
  scale_fill_manual(values = c("Core Total" = "green", "Corridor Total" = "red")) +
  coord_cartesian(ylim = c(0, 15000))

# Branch plot
p2 <- ggplot() +
  geom_bar(data = merged_summary, aes(x = Habitat.Code, y = Branch.Total, fill = "Branch Total"), 
           stat = "identity", position = "dodge", alpha = 0.7) +
  labs(title = "Dominant Annex I Habitat Types in the Branch Areas of Green Infrastructure on the Estonian Coast",
       y = "Area (in Hectares)", x = "Annex I Habitat Type") +
  theme_bw() +
  theme(plot.title = element_text(size = 14),
        axis.title.x = element_text(size = 13),
        axis.title.y = element_text(size = 13),
        axis.text.x = element_text(angle = 90, hjust = 1, size = 13),
        axis.text.y = element_text(size = 13),
        legend.title = element_blank(),
        legend.text = element_text(size = 13),
        legend.position = "top") +
  scale_fill_manual(values = c("Branch Total" = "orange")) +
  coord_cartesian(ylim = c(0, 1800))

# Arrange plots vertically
grid.arrange(p1, p2, ncol = 1)









library(ggplot2)
library(reshape2)
library(gridExtra)

# Core Areas Data
core_data <- data.frame(
  Habitat.Type = c("Western Taïga", "Boreal Baltic Coastal Meadows", "Nordic Alvar and Precambrian Calcareous Flatrocks",
                   "Fennoscandian Deciduous Swamp Woods", "Northern Boreal Alluvial Meadows", "Wooded Dunes of the Atlantic, Continental, and Boreal Region",
                   "Bog Woodland", "Fennoscandian Hemiboreal Natural Old Broad-leaved Deciduous Forests", "Fennoscandian Wooded Pastures",
                   "Alkaline Fens", "Active Raised Bogs", "Fennoscandian Wooded Meadows", "Juniperus Communis Formations on Heaths or Calcareous Grasslands",
                   "Lowland Hay Meadows (Alopecurus Pratensis, Sanguisorba Officinalis)", "Semi-natural Dry Grasslands and Scrubland Facies on Calcareous Substrates",
                   "Hydrophilous Tall Herb Fringe Communities of Plains and of the Montane to Alpine Levels", "Fennoscandian Lowland Species-rich Dry to Mesic Grasslands",
                   "Degraded Raised Bogs Still Capable of Natural Regeneration", "Transition Mires and Quaking Bogs", "Calcareous Fens with Cladium Mariscus and Species of the Caricion Davallianae"),
  Habitat.Code = c("9010", "1630", "6280", "9080", "6450", "2180", "91D0", "9020", "9070", "7230", "7110", "6530", "5130", "6510", "6210", "6430", "6270", "7120", "7140", "7210"),
  Harju = c(2000, 100, 1500, 1200, 0, 300, 700, 600, 0, 100, 500, 200, 0, 200, 450, 0, 50, 0, 200, 50),
  Laane_Viru = c(3000, 0, 0, 500, 0, 0, 400, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 200, 0, 0),
  Saare = c(5000, 2900, 4000, 1000, 0, 800, 100, 400, 900, 600, 0, 1100, 1000, 0, 0, 0, 0, 0, 0, 0),
  Hiiu = c(3000, 1200, 800, 900, 0, 1100, 300, 100, 400, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
  Parnu = c(700, 1800, 400, 1000, 1700, 800, 400, 600, 150, 400, 1200, 300, 0, 400, 0, 300, 0, 0, 0, 0),
  Ida_Viru = c(0, 0, 0, 45, 0, 60, 70, 200, 0, 0, 0, 0, 50, 0, 0, 0, 30, 0, 0, 0),
  Laane = c(0, 2500, 250, 2000, 1500, 0, 70, 100, 400, 700, 0, 100, 0, 50, 0, 100, 150, 0, 0, 0)
)

# Corridor Areas Data
corridor_data <- data.frame(
  Habitat.Type = c("Boreal Baltic Coastal Meadows", "Nordic Alvar and Precambrian Calcareous Flatrocks", "Western Taïga",
                   "Fennoscandian Deciduous Swamp Woods", "Wooded Dunes of the Atlantic, Continental, and Boreal Region",
                   "Juniperus Communis Formations on Heaths or Calcareous Grasslands", "Lowland Hay Meadows (Alopecurus Pratensis, Sanguisorba Officinalis)",
                   "Alkaline Fens", "Fennoscandian Wooded Pastures", "Calcareous Fens with Cladium Mariscus and Species of the Caricion Davallianae",
                   "Fennoscandian Wooded Meadows", "Fennoscandian Lowland Species-rich Dry to Mesic Grasslands", "Semi-natural Dry Grasslands and Scrubland Facies on Calcareous Substrates",
                   "Fennoscandian Hemiboreal Natural Old Broad-leaved Deciduous Forests", "Tilio-Acerion Forests of Slopes, Screes and Ravines"),
  Habitat.Code = c("1630", "6280", "9010", "9080", "2180", "5130", "6510", "7230", "9070", "7210", "6530", "6270", "6210", "9020", "9180"),
  Harju = c(350, 800, 700, 500, 500, 0, 350, 0, 0, 0, 0, 0, 0, 0, 0),
  Laane_Viru = c(130, 70, 510, 250, 40, 0, 100, 0, 0, 0, 0, 0, 0, 0, 50),
  Saare = c(3200, 3100, 1400, 600, 350, 900, 100, 800, 800, 450, 450, 200, 0, 0, 0),
  Hiiu = c(1800, 300, 400, 300, 70, 0, 30, 0, 0, 0, 0, 0, 0, 0, 0),
  Parnu = c(1600, 400, 400, 350, 480, 270, 400, 100, 0, 200, 0, 200, 300, 150, 0),
  Ida_Viru = c(0, 20, 0, 200, 80, 0, 70, 0, 0, 0, 0, 0, 0, 0, 0),
  Laane = c(1550, 250, 400, 700, 20, 0, 100, 0, 0, 0, 0, 0, 0, 0, 0)
)

# Branch Areas Data
branch_data <- data.frame(
  Habitat.Type = c("Boreal Baltic Coastal Meadows", "Nordic Alvar and Precambrian Calcareous Flatrocks", 
                   "Juniperus Communis Formations on Heaths or Calcareous Grasslands", "Semi-natural Dry Grasslands and Scrubland Facies on Calcareous Substrates", 
                   "Fennoscandian Deciduous Swamp Woods", "Fennoscandian Wooded Pastures", "Lowland Hay Meadows (Alopecurus Pratensis, Sanguisorba Officinalis)", 
                   "Fennoscandian Wooded Meadows", "Western Taïga", "Alkaline Fens", "Northern Boreal Alluvial Meadows", 
                   "Fennoscandian Hemiboreal Natural Old Broad-leaved Deciduous Forests", "Tilio-Acerion Forests of Slopes, Screes and Ravines"),
  Habitat.Code = c("1630", "6280", "5130", "6210", "9080", "9070", "6510", "6530", "9010", "7230", "6450", "9020", "9180"),
  Harju = c(35, 45, 4, 30, 15, 0, 15, 0, 3, 0, 0, 0, 4),
  Laane_Viru = c(5, 0, 0, 0, 5, 2, 0, 0, 0, 2, 0, 0, 4),
  Saare = c(700, 180, 100, 90, 10, 20, 20, 50, 20, 20, 0, 15, 0),
  Hiiu = c(210, 25, 40, 10, 20, 20, 10, 0, 10, 0, 0, 0, 0),
  Parnu = c(360, 10, 20, 20, 5, 10, 20, 10, 10, 15, 20, 0, 0),
Ida_Viru = c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
Laane = c(450, 40, 40, 15, 20, 20, 0, 0, 15, 10, 0, 0, 0)
)

# Melt data to long format
core_data_melt <- melt(core_data, id.vars = c("Habitat.Type", "Habitat.Code"))
corridor_data_melt <- melt(corridor_data, id.vars = c("Habitat.Type", "Habitat.Code"))
branch_data_melt <- melt(branch_data, id.vars = c("Habitat.Type", "Habitat.Code"))

# Summarize data by Habitat.Code
core_summary <- aggregate(value ~ Habitat.Code, data = core_data_melt, sum)
corridor_summary <- aggregate(value ~ Habitat.Code, data = corridor_data_melt, sum)
branch_summary <- aggregate(value ~ Habitat.Code, data = branch_data_melt, sum)

# Merge summaries
merged_summary <- merge(core_summary, corridor_summary, by = "Habitat.Code", all = TRUE)
merged_summary <- merge(merged_summary, branch_summary, by = "Habitat.Code", all = TRUE)
colnames(merged_summary) <- c("Habitat.Code", "Core.Total", "Corridor.Total", "Branch.Total")
merged_summary[is.na(merged_summary)] <- 0
# Core and Corridor plot
p1 <- ggplot(merged_summary, aes(x = Habitat.Code)) +
  geom_bar(aes(y = Core.Total, fill = "Core Total"), stat = "identity", position = "dodge", alpha = 0.7) +
  geom_bar(aes(y = Corridor.Total, fill = "Corridor Total"), stat = "identity", position = "dodge", alpha = 0.7) +
  coord_cartesian(ylim = c(0, 9000)) +
  geom_text(aes(y = ifelse(Core.Total > 9000, Core.Total, NA), label = ifelse(Core.Total > 9000, Core.Total, "")), vjust = -0.5, size = 4) +
  geom_text(aes(y = ifelse(Corridor.Total > 9000, Corridor.Total, NA), label = ifelse(Corridor.Total > 9000, Corridor.Total, "")), vjust = -0.5, size = 4) +
  labs(title = "Annex I Habitat Types Prevalent in Green Infrastructure Core and Corridor Areas Along Estonian Coast",
       y = "Area (in Hectares)") +
  theme_bw() +
  theme(plot.title = element_text(size = 18),
        axis.title.x = element_blank(),
        axis.title.y = element_text(size = 16),
        axis.text.x = element_text(angle = 90, hjust = 1, size = 14),
        axis.text.y = element_text(size = 14),
        legend.title = element_blank(),
        legend.text = element_text(size = 14),
        legend.position = "top") +
  scale_fill_manual(values = c("Core Total" = "green", "Corridor Total" = "red"))

# Branch plot
p2 <- ggplot(merged_summary, aes(x = Habitat.Code)) +
  geom_bar(aes(y = Branch.Total, fill = "Branch Total"), stat = "identity", position = "dodge", alpha = 0.7) +
  coord_cartesian(ylim = c(0, 2000)) +
  geom_text(aes(y = ifelse(Branch.Total > 2000, Branch.Total, NA), label = ifelse(Branch.Total > 2000, Branch.Total, "")), vjust = -0.5, size = 4) +
  labs(title = "Dominant Annex I Habitat Types in the Branch Areas of Green Infrastructure on the Estonian Coast",
       y = "Area (in Hectares)", x = "Annex I Habitat Type") +
  theme_bw() +
  theme(plot.title = element_text(size = 18),
        axis.title.x = element_text(size = 16),
        axis.title.y = element_text(size = 16),
        axis.text.x = element_text(angle = 90, hjust = 1, size = 14),
        axis.text.y = element_text(size = 14),
        legend.title = element_blank(),
        legend.text = element_text(size = 14),
        legend.position = "top") +
  scale_fill_manual(values = c("Branch Total" = "orange"))

# Arrange plots vertically
grid.arrange(p1, p2, ncol = 1)