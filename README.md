 # Interactive Roary Gene Presence–Absence Heatmaps for Prokaryotic Pangenomes (R + heatmaply)

This repository provides a complete, reproducible workflow in **R** for generating
interactive, hover-enabled gene presence–absence heatmaps from **Roary** pangenome
outputs. Each genome is assigned a unique color, and genes are filtered based on
prevalence to create compact, interpretable visualizations ideal for microbial
comparative genomics, pangenome exploration, and scientific visualization.

---

## 🔗 Live Interactive Heatmap (GitHub Pages)

If GitHub Pages is enabled and a copy of the heatmap HTML is saved as `index.html`
in the repository root, the interactive heatmap will be available at:

```text
https://mbilal-OU.github.io/roary-pangenome-heatmaps/

(Open in Chrome/Firefox for full interactivity.)
🔍 Features

Direct compatibility with Roary pangenome output (gene_presence_absence*.csv).

Automatically:

Selects 20 genomes.

Selects up to 20 genes with ≥ 50% prevalence.

Converts entries to 0/1 presence–absence.

Color scheme:

0 = White (absent)

1 = Unique genome-specific color (present)

Generates:

Interactive HTML heatmap with hover labels (Gene, Genome, Presence)

Static PNG snapshot for manuscripts, slides, and GitHub previews

Uses open-source R libraries:

tidyverse, heatmaply, plotly, htmlwidgets, RColorBrewer, webshot2

📁 Repository Structure
roary-pangenome-heatmaps/
├── scripts/
│   └── heatmap_20x20_genomeCells.R          # Main script
├── data/
│   └── gene_presence_absence_reps.csv       # NOT tracked (too large for GitHub)
├── figures/
│   ├── pangenome_heatmap_20x20_genomeCells.html   # Interactive output
│   └── pangenome_heatmap_20x20_genomeCells.png    # Static PNG snapshot
├── index.html                                # (Optional) copy of HTML for GitHub Pages
├── .gitignore
└── README.md

⚠️ Large Data Notice (Important)

The file:

data/gene_presence_absence_reps.csv


is approximately 288 MB and exceeds GitHub’s 100 MB upload limit.

Therefore:

It is NOT included in this repository.

It is ignored using .gitignore.

You must provide your own Roary file locally in the data/ directory.

This keeps the repository lightweight and GitHub-compatible.

📥 Input Requirements

Your input must be a standard Roary presence–absence table, for example:

data/gene_presence_absence_reps.csv


Roary typically outputs:

~14 metadata columns (e.g., Gene, Annotation, etc.)

1 column per genome

The script automatically identifies genome columns after the metadata.

🔧 Installation (One-Time R Setup)

Install the required R packages:

install.packages(c(
  "tidyverse",
  "heatmaply",
  "htmlwidgets",
  "plotly",
  "RColorBrewer",
  "webshot2"
))


webshot2 will use your system’s Chrome/Chromium (or another headless browser)
to save PNG snapshots from the HTML widget.

▶️ How to Run the Workflow
1. Clone or download this repository
git clone https://github.com/mbilal-OU/roary-pangenome-heatmaps.git


Or download as a ZIP and extract.

2. Place your Roary file inside data/
roary-pangenome-heatmaps/data/gene_presence_absence_reps.csv

3. Set the working directory in R or RStudio
setwd("path/to/roary-pangenome-heatmaps")


(Replace path/to with your local path.)

4. Run the script
source("scripts/heatmap_20x20_genomeCells.R")

5. View generated outputs
figures/
├── pangenome_heatmap_20x20_genomeCells.html   # Interactive heatmap
└── pangenome_heatmap_20x20_genomeCells.png    # Static PNG snapshot


Open the .html file in your browser to explore the interactive heatmap.

If you also copy the HTML to index.html in the repository root, GitHub Pages
can serve the interactive version online.

🧠 How the Script Works (Pipeline Summary)

The script:

Loads the Roary gene presence–absence file from data/.

Detects all genome columns (after the metadata columns).

Randomly selects 20 genomes.

Converts gene calls to a 0/1 presence–absence matrix:

empty / NA → 0

non-empty → 1

Computes gene prevalence across the 20 genomes and keeps genes with:

≥ 50% presence

up to 20 genes (configurable)

Assigns each genome a unique color.

Builds a color index matrix for visualization:

0 → white (absence)

1..N → genome-specific colors (presence)

Uses heatmaply() to create an interactive heatmap with:

Row and column dendrograms

Straight axis labels

Custom hover text for each cell (Gene, Genome, Presence)

Saves:

An HTML widget (figures/pangenome_heatmap_20x20_genomeCells.html)

A PNG snapshot (figures/pangenome_heatmap_20x20_genomeCells.png) via webshot2::webshot()

Adjustable Parameters

Inside scripts/heatmap_20x20_genomeCells.R, you can modify:

n_genomes_target       # default: 20
n_genes_target         # default: 20
prevalence_threshold   # default: 0.50  (i.e., 50% presence)


to change subset sizes and prevalence cutoffs.

🌐 GitHub Pages (Optional Interactive View)

To host the interactive heatmap online via GitHub Pages:

Ensure you have a copy of the HTML in the repository root named:

index.html


For example, from your local clone:

cp figures/pangenome_heatmap_20x20_genomeCells.html index.html
git add index.html
git commit -m "Add index.html for GitHub Pages"
git push


In the GitHub repository:

Go to Settings → Pages

Under Source, select:

Branch: main

Folder: / (root)

Save.

After a short delay, the page should be available at:

https://mbilal-OU.github.io/roary-pangenome-heatmaps/



👤 Author

Muhammad Bilal
Computational Biologist
Pangenomics · Phylogenomics · Microbial Evolution · Data-Driven Biology

GitHub: https://github.com/mbilal-OU
