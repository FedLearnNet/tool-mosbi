library(mosbi)

args <- get("args", envir = .GlobalEnv)

if (length(args) < 11) {
    stop("File path and output path are required!", call.=FALSE)
}

file_path <- args[1]
output_path <- args[2]

# parameters for bioclustering network
n_randomizations <- as.integer(args[3])
MARGIN <- args[4]
metric <- as.integer(args[5])
n_steps <- as.integer(args[6])
plot_edge_dist <- as.logical(args[7])
sn_ratio <- as.logical(args[8])
error_threshold <- as.numeric(args[9])
return_plot_data <- as.logical(args[10])
prob_scale <- as.logical(args[11])
prl <- as.logical(args[12])

# Debugging: Print the parameters
cat("File Path:", file_path, "\n")
cat("Output Path:", output_path, "\n")
cat("n_randomizations:", n_randomizations, "\n")
cat("MARGIN:", MARGIN, "\n")
cat("metric:", metric, "\n")
cat("n_steps:", n_steps, "\n")
cat("plot_edge_dist:", plot_edge_dist, "\n")
cat("sn_ratio:", sn_ratio, "\n")
cat("error_threshold:", error_threshold, "\n")
cat("return_plot_data:", return_plot_data, "\n")
cat("prob_scale:", prob_scale, "\n")
cat("prl:", prl, "\n")

if (!dir.exists(output_path)) {
    dir.create(output_path, recursive = TRUE)
    cat("Created directory:", output_path, "\n")
}

## Step 1: Load the Data
data <- read.csv(file_path, header = TRUE, row.names = 1, sep = "\t")
mat <- as.matrix(data)

## Helper functions
z_score <- function(x, margin = 2) {
  z_fun <- function(y) {
    (y - mean(y, na.rm = TRUE)) / sd(y, na.rm = TRUE)
  }
  if (margin == 2) {
    return(apply(x, margin, z_fun))
  } else if (margin == 1) {
    return(t(apply(x, margin, z_fun)))
  }
}

bicluster_histo <- function(biclusters) {
  cols <- mosbi::colhistogram(biclusters)
  rows <- mosbi::rowhistogram(biclusters)

  graphics::par(mfrow = c(1, 2), mar = c(5, 4, 4, 2) + 0.1) # Fix margin issue
  hist(cols, main = "Column size distribution")
  hist(rows, main = "Row size distribution")
}

## Step 2: Perform Biclustering
# Using the FABIA algorithm
fb <- run_fabia(mat)

# ISA2
BCisa <- mosbi::run_isa(mat)

# Plaid
BCplaid <- mosbi::run_plaid(mat)

# QUBIC
BCqubic <- mosbi::run_qubic(mat)

# Merge results of all algorithms
all_bics <- c(fb, BCisa, BCplaid, BCqubic)

# 1) Save histogram of bicluster sizes
png(file = file.path(output_path,"bicluster_histograms.png"), width = 3000, height = 2000, res = 300)
par(mar = c(5, 4, 4, 2) + 0.1) # Adjust margins
bicluster_histo(all_bics)
dev.off()

# 2) Save bicluster network cutoff evaluation plot
png(file = file.path(output_path, "bicluster_network_cutoff_evaluation.png"), width = 3000, height = 2000, res = 300)
par(mar = c(5, 4, 4, 2) + 0.1)

bic_net <- mosbi::bicluster_network(all_bics,
                            mat = mat,
                            n_randomizations = n_randomizations,
                            MARGIN = MARGIN,
                            metric = metric,
                            n_steps = n_steps,
                            plot_edge_dist = plot_edge_dist,
                            sn_ratio = sn_ratio,
                            error_threshold = error_threshold,
                            return_plot_data = return_plot_data,
                            prob_scale = prob_scale,
                            prl = prl)

# 3) Save adjacency heatmap
png(file = file.path(output_path,"bicluster_adjacency_heatmap.png"), width = 3000, height = 3000, res = 300)
par(mar = c(5, 4, 4, 2) + 0.1)
stats::heatmap(get_adjacency(bic_net))
dev.off()

## 4) Save network visualization
png(file = file.path(output_path,"bicluster_network_plot.png"), width = 3000, height = 3000, res = 300)
par(mar = c(5, 4, 4, 2) + 0.1)
plot(bic_net)
dev.off()

## 5) Save network visualization colored by algorithm
png(file = file.path(output_path,"bicluster_network_by_algorithm.png"), width = 3000, height = 2000, res = 300)
par(mar = c(5, 4, 4, 2) + 0.1)
mosbi::plot_algo_network(bic_net, all_bics, vertex.label = NA)
dev.off()
