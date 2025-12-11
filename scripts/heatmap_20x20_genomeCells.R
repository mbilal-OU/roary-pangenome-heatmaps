#!/usr/bin/env Rscript

###############################################################################
# heatmap_20x20_genomeCells.R
#
# Workflow:
#  - Read Roary gene_presence_absence_reps.csv from ./data/
#  - Randomly select 20 genomes (columns)
#  - Select genes with ≥ 50% prevalence across these genomes (up to 20 genes)
#  - Build a 20 × 20 heatmap where:
#       * 0 (absent) = white
#       * 1 (present) = genome-specific color (column-based)
#  - Add hover text: Gene, Genome, Presence
#  - Save interactive HTML to ./figures/
#  - (Optionally) save a static PNG snapshot
###############################################################################

# ------------------------- 1. Packages ---------------------------------------

required_pkgs <- c(
  "tidyverse",
  "heatmaply",
  "htmlwidgets",
  "plotly",
  "RColorBrewer"
)

for (pkg in required_pkgs) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg)
  }
}

suppressPackageStartupMessages({
  library(tidyverse)
  library(heatmaply)
  library(htmlwidgets)
  library(plotly)
  library(RColorBrewer)
})

# ------------------------- 2. Paths & settings -------------------------------

# All paths are relative to the r_project root
input_gpa <- file.path("data", "gene_presence_absence_reps.csv")
out_dir   <- file.path("figures")
if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)

out_html <- file.path(out_dir, "pangenome_heatmap_20x20_genomeCells.html")
out_png  <- file.path(out_dir, "pangenome_heatmap_20x20_genomeCells.png")

n_genomes_target     <- 20
n_genes_target       <- 20
prevalence_threshold <- 0.50   # 50% presence

set.seed(123)  # reproducible sampling

# ------------------------- 3. Read Roary file --------------------------------

message("Reading Roary file: ", input_gpa)
gpa <- readr::read_csv(input_gpa, show_col_types = FALSE)

# Adjust meta_cols if needed (14 is default for Roary)
meta_cols   <- 14
genome_cols <- colnames(gpa)[(meta_cols + 1):ncol(gpa)]

message("Total genomes detected: ", length(genome_cols))

# ------------------------- 4. Randomly select 20 genomes ---------------------

if (length(genome_cols) < n_genomes_target) {
  stop("Requested ", n_genomes_target, " genomes but only ",
       length(genome_cols), " genomes available.")
}

selected_genomes <- sample(genome_cols, size = n_genomes_target, replace = FALSE)
message("Selected 20 genomes:")
print(selected_genomes)

gpa_sub <- gpa %>%
  dplyr::select(Gene, all_of(selected_genomes))

# ------------------------- 5. Build 0/1 presence/absence matrix --------------

pa_df <- gpa_sub %>%
  mutate(across(
    .cols = all_of(selected_genomes),
    .fns  = ~ ifelse(is.na(.x) | .x == "", 0L, 1L)
  ))

pa_mat <- pa_df %>%
  column_to_rownames("Gene") %>%
  as.matrix()

storage.mode(pa_mat) <- "numeric"

message("Matrix size (genes x 20 genomes): ", paste(dim(pa_mat), collapse = " x "))

# ------------------------- 6. Select genes with ≥50% prevalence --------------

gene_prevalence <- rowMeans(pa_mat)
keep_idx        <- which(gene_prevalence >= prevalence_threshold)

message("Genes with ≥50% prevalence: ", length(keep_idx))

if (length(keep_idx) == 0) {
  stop("No genes meet the ≥50% threshold. Try lowering the threshold.")
}

pa_mat_highprev <- pa_mat[keep_idx, , drop = FALSE]

# Keep up to 20 genes
if (nrow(pa_mat_highprev) > n_genes_target) {
  selected_rows <- sample(seq_len(nrow(pa_mat_highprev)), n_genes_target)
  pa_mat_plot   <- pa_mat_highprev[selected_rows, , drop = FALSE]
} else {
  pa_mat_plot   <- pa_mat_highprev
}

message("Final plotting matrix (genes x genomes): ", paste(dim(pa_mat_plot), collapse = " x "))

gene_names   <- rownames(pa_mat_plot)
genome_names <- colnames(pa_mat_plot)
ng           <- length(genome_names)

# ------------------------- 7. Build color-matrix by genome -------------------

# Convert 0/1 to "color index":
# - 0 (absent) -> 0
# - 1 (present in column j) -> j
color_mat <- matrix(
  0,
  nrow = nrow(pa_mat_plot),
  ncol = ncol(pa_mat_plot),
  dimnames = dimnames(pa_mat_plot)
)

for (j in seq_len(ng)) {
  color_mat[, j] <- ifelse(pa_mat_plot[, j] == 1, j, 0)
}

# Build palette:
# - first color = white (absence)
# - next ng colors = distinct genome colors
base_palette    <- brewer.pal(min(8, max(3, ng)), "Set2")
genome_palette  <- colorRampPalette(base_palette)(ng)
full_palette    <- c("#FFFFFF", genome_palette)   # length = ng + 1

# ------------------------- 8. Build custom hover text ------------------------

hover_mat <- matrix(
  nrow = nrow(pa_mat_plot),
  ncol = ncol(pa_mat_plot),
  dimnames = dimnames(pa_mat_plot)
)

for (i in seq_len(nrow(pa_mat_plot))) {
  for (j in seq_len(ncol(pa_mat_plot))) {
    presence_val <- pa_mat_plot[i, j]        # 0 or 1
    presence_txt <- ifelse(presence_val == 1, "Present", "Absent")
    hover_mat[i, j] <- paste0(
      "Gene: ", gene_names[i],
      "<br>Genome: ", genome_names[j],
      "<br>Presence: ", presence_txt, " (", presence_val, ")"
    )
  }
}

# ------------------------- 9. Plot interactive heatmap -----------------------

hm <- heatmaply(
  color_mat,
  scale             = "none",
  colors            = full_palette,
  dendrogram        = "both",
  show_dendrogram   = c(TRUE, TRUE),
  row_dend_left     = TRUE,
  main              = "Genes (≥50% presence) across 20 genomes",
  xlab              = "Genomes",
  ylab              = "Genes",
  fontsize_row      = 8,
  fontsize_col      = 8,
  custom_hovertext  = hover_mat,
  hide_colorbar     = FALSE
)

# Straight axis labels
hm <- hm %>%
  layout(
    xaxis = list(tickangle = 0),
    yaxis = list(tickangle = 0)
  )

# ------------------------- 10. Save interactive HTML -------------------------

message("Saving interactive HTML to: ", out_html)
htmlwidgets::saveWidget(hm, file = out_html, selfcontained = TRUE)

# ------------------------- 11. (Optional) Save static PNG snapshot -----------

# This part requires either webshot2 or orca to be installed.
# If you do not have them, you can comment this section out
# and take a manual screenshot of the HTML.

save_png <- FALSE  # set to TRUE if you configure webshot2/orca

if (save_png) {
  message("Attempting to save PNG snapshot to: ", out_png)
  # Example using orca (Plotly static image export):
  # orca(hm, file = out_png, width = 1200, height = 900)
  #
  # or using webshot2:
  # library(webshot2)
  # webshot(out_html, out_png, vwidth = 1400, vheight = 1000)
}

message("Done.")
