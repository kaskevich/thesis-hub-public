install.packages("igraph")
library(igraph)


# Load the data from CSV file
gi_data <- read.csv('~/Desktop/ThirtyFourtyDocker/ls_metrics_allstat/bgi_content/gi_data.csv', stringsAsFactors = FALSE)

# Create an empty graph
g <- make_empty_graph(directed = TRUE)

# Define the categories and subcategories
categories <- c("Cores", "Corridors", "Branches")
subcategories <- c("Forest", "Natura2000", "Perm")

# Add the "Total GI" node with a size proportional to the total BGI area
total_gi_size <- sum(gi_data$Coastal_BGI_Total_Ha)
g <- add_vertices(g, 1, name="Total GI", size=total_gi_size)

# Add nodes for each subcategory within each category
# Also, accumulate totals for each main category
category_totals <- setNames(numeric(length(categories)), categories)
for (cat in categories) {
  for (subcat in subcategories) {
    column_name <- paste(subcat, cat, "Ha", sep = "_")
    if (!column_name %in% names(gi_data)) {
      next  # Skip if the column name doesn't exist
    }
    total_area <- sum(gi_data[[column_name]], na.rm = TRUE)
    category_totals[cat] <- category_totals[cat] + total_area
    node_name <- paste(subcat, cat, sep = "_")
    g <- add_vertices(g, nv = 1, name = node_name, size = total_area)
  }
}

# Add the main category nodes and connect them to "Total GI"
for (cat in categories) {
  g <- add_vertices(g, nv = 1, name = cat, size = category_totals[cat])
  g <- add_edges(g, c("Total GI", cat))
}

# Now, connect the subcategory nodes to their respective main category nodes
for (cat in categories) {
  for (subcat in subcategories) {
    node_name <- paste(subcat, cat, sep = "_")
    if (node_name %in% V(g)$name) {
      g <- add_edges(g, c(cat, node_name))
    }
  }
}

# Define new labels for specific nodes
new_labels <- list(
  "Forest_Cores" = "Forest Cores",
  "Natura2000_Cores" = "Natura 2000 Cores",
  "Perm_Cores" = "Permanent Meadows Cores",
  "Forest_Corridors" = "Forest Corridors",
  "Natura2000_Corridors" = "Natura 2000 Corridors",
  "Perm_Corridors" = "Permanent Meadows Corridors",
  "Forest_Branches" = "Forest Branches",
  "Natura2000_Branches" = "Natura 2000 Branches",
  "Perm_Branches" = "Permanent Meadows Branches"
)

# Update the labels of the vertices with new labels
for (v in V(g)) {
  v_name <- V(g)$name[v]
  if (v_name %in% names(new_labels)) {
    V(g)$label[v] <- paste(new_labels[[v_name]], "\n", round(V(g)$size[v]), "ha", sep="")
  } else {
    V(g)$label[v] <- paste(v_name, "\n", round(V(g)$size[v]), "ha", sep="")
  }
}

# Plot the graph with labels that include the sizes
plot(g, vertex.size = V(g)$size / max(V(g)$size) * 30,
     vertex.label = V(g)$label, vertex.color = 'lightgreen',
     edge.arrow.size = 0.5, main = "Green Infrastructure Network in Estonian Coastal Zone")


# Define the color with 50% opacity
green_color <- rgb(0, 1, 0, 0.2)  # Light green with 50% opacity
red_color <- rgb(1, 0, 0, 0.2)    # Light red with 50% opacity

# Update the vertex colors based on the category
V(g)$color <- ifelse(grepl("Corridors", V(g)$name), red_color, green_color)

# Update the labels to put numbers on top
V(g)$label <- sapply(V(g)$name, function(name) {
  size <- round(V(g)$size[V(g)$name == name])
  label <- ifelse(name %in% names(new_labels), new_labels[[name]], name)
  paste(size, "ha\n", label, sep="")
})

# Plot the graph
plot(g, vertex.size = V(g)$size / max(V(g)$size) * 30,
     vertex.label = V(g)$label, 
     vertex.color = V(g)$color,
     edge.arrow.size = 0.5, 
     main = "Green Infrastructure Network in Estonian Coastal Zone")





library(igraph)

# Load the data from CSV file
gi_data <- read.csv('~/Desktop/ThirtyFourtyDocker/ls_metrics_allstat/bgi_content/gi_data.csv', stringsAsFactors = FALSE)

# Create an empty graph
g <- make_empty_graph(directed = TRUE)

# Define the categories and subcategories
categories <- c("Cores", "Corridors", "Branches")
subcategories <- c("Forest", "Natura2000", "Perm")

# Add the "Total GI" node with a size proportional to the total BGI area
total_gi_size <- sum(gi_data$Coastal_BGI_Total_Ha)
g <- add_vertices(g, 1, name="Total GI", size=total_gi_size)

# Add nodes for each subcategory within each category and connect them
category_totals <- setNames(numeric(length(categories)), categories)
for (cat in categories) {
  for (subcat in subcategories) {
    column_name <- paste(subcat, cat, "Ha", sep = "_")
    if (!column_name %in% names(gi_data)) {
      next  # Skip if the column name doesn't exist
    }
    total_area <- sum(gi_data[[column_name]], na.rm = TRUE)
    category_totals[cat] <- category_totals[cat] + total_area
    node_name <- paste(subcat, cat, sep = "_")
    g <- add_vertices(g, nv = 1, name = node_name, size = total_area)
  }
}

# Add the main category nodes and connect them to "Total GI"
for (cat in categories) {
  g <- add_vertices(g, nv = 1, name = cat, size = category_totals[cat])
  g <- add_edges(g, c("Total GI", cat))
}

# Connect subcategory nodes to their respective main category nodes
for (cat in categories) {
  for (subcat in subcategories) {
    node_name <- paste(subcat, cat, sep = "_")
    if (node_name %in% V(g)$name) {
      g <- add_edges(g, c(cat, node_name))
    }
  }
}

# Define new labels for specific nodes
new_labels <- list(
  "Forest_Cores" = "Forest Cores",
  "Natura2000_Cores" = "Natura 2000 Cores",
  "Perm_Cores" = "Permanent Meadows Cores",
  "Forest_Corridors" = "Forest Corridors",
  "Natura2000_Corridors" = "Natura 2000 Corridors",
  "Perm_Corridors" = "Permanent Meadows Corridors",
  "Forest_Branches" = "Forest Branches",
  "Natura2000_Branches" = "Natura 2000 Branches",
  "Perm_Branches" = "Permanent Meadows Branches"
)

# Update the labels of the vertices with new labels
for (v in V(g)) {
  v_name <- V(g)$name[v]
  V(g)$label[v] <- ifelse(v_name %in% names(new_labels), new_labels[[v_name]], v_name)
}

# Create a layout for the graph
layout <- layout_nicely(g)

# Plot the graph with labels
plot(g, layout = layout,
     vertex.size = V(g)$size / max(V(g)$size) * 30,
     vertex.label = V(g)$label, vertex.color = 'lightgreen',
     vertex.label.color = "black",  
     edge.arrow.size = 0.5, main = "Green Infrastructure Network in Estonian Coastal Zone")


