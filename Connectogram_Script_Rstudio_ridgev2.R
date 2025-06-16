# Clear workspace
rm(list = ls())
setwd("C:/Users/ASUS/My Drive/NTU/Semester/MBE Paper/Workspace BHS")

# Load required packages
library(ggplot2)
library(ggraph)
library(igraph)
library(gridExtra)
library(grid)
library(RColorBrewer)

# Load coefficients (from Python output)
coefs <- read.csv("PythonWorkspace/subsample_ridge_coefs.csv")
# If your CSV has only one row, flatten to vector
if (nrow(coefs) == 1) {
  coef_vals <- as.numeric(coefs)
} else {
  coef_cols <- grep("^coef_", names(coefs), value = TRUE)
  coef_vals <- colMeans(coefs[, coef_cols])
}

#coef_vals[] <- lapply(coef_vals, as.numeric)

# ---- DYNAMIC THRESHOLDING SECTION ----
# Set either top_percent (e.g. 0.10 for top 10%) or top_n (e.g. 7 for top 7 coefficients)
top_n <- 20

# Get absolute values and order
abs_vals <- abs(coef_vals)
sorted_indices <- order(abs_vals, decreasing = TRUE)

# Get top_n indices by magnitude
top_indices <- sorted_indices[1:top_n]

# Create thresholded vector
FCresults_thresholded <- rep(0, length(coef_vals))
FCresults_thresholded[top_indices] <- coef_vals[top_indices]

# Diagnostics
cat("Non-zero before thresholding:", sum(coef_vals != 0), "\n")
cat("Non-zero after thresholding:", sum(FCresults_thresholded != 0), "\n")
sum(FCresults_thresholded != 0)
sum(FCresults_thresholded == 0)

# ---- END THRESHOLDING SECTION ----

# Load labels
labelsFC <- read.csv("labelsFC_schaefer119.csv")
labelsFC$regionlabel <- factor(labelsFC$regionlabel, 
                               levels = c("Visual","Somatomotor","Dorsal Attention","Ventral Attention","Limbic","Frontoparietal","Default mode","Subcortical"))

# Color parameters
colorscheme <- brewer.pal(8, "Spectral")
pos_color <- "#F8766D"
neg_color <- "#00BFC4"

# Reconstruct FC matrix
N <- 119
FC_119x119half <- matrix(0, nrow = N, ncol = N)
FC_119x119half[upper.tri(FC_119x119half, diag = FALSE)] <- FCresults_thresholded
FC_119X119 <- FC_119x119half + t(FC_119x119half)

# Sort and reorder labels according to their respective regions
mat <- data.frame(FC_119X119)
mat$neworder <- labelsFC$neworder
reordered <- mat[order(mat$neworder),]
reordered$neworder <- NULL
reordered <- data.frame(t(reordered))
reordered$neworder <- labelsFC$neworder
reordered <- reordered[order(reordered$neworder),]
reordered$neworder <- NULL

labelsFC <- labelsFC[order(labelsFC$neworder),]
reordered <- data.matrix(reordered)
colnames(reordered) <- labelsFC$labels
rownames(reordered) <- labelsFC$labels
RegionsFC <- labelsFC$regionlabel

# Graph object
graphobjFC <- graph_from_adjacency_matrix(reordered, mode="undirected", diag=FALSE, weighted=TRUE)
EvalFC <- edge_attr(graphobjFC, "weight", index = E(graphobjFC))
posnegFC <- ifelse(EvalFC < 0, "2_neg", "1_pos")
edge_attr(graphobjFC, "weight", index = E(graphobjFC)) <- abs(EvalFC)
edge_attr(graphobjFC, "posFC", index = E(graphobjFC)) <- posnegFC

# Plot
FCplot <- ggraph(graphobjFC, layout = 'linear', circular = TRUE) +  
  geom_edge_arc(aes(color=posFC, alpha=weight), edge_width=0.8, show.legend = TRUE) +
  scale_edge_alpha_continuous(guide="none") +
  scale_edge_color_manual(name="Edges", labels=c("Positive","Negative"), values=c(pos_color,neg_color)) +
  scale_color_manual(values=colorscheme, name="Network") +
  geom_node_point(aes(colour=RegionsFC), size=1, shape=19, show.legend=TRUE) +
  geom_node_text(aes(label=name, x=x*1.03, y=y*1.03,
                     angle=ifelse(atan(-(x/y))*(180/pi) < 0,
                                  90 + atan(-(x/y))*(180/pi),
                                  270 + atan(-x/y)*(180/pi)),
                     hjust=ifelse(x > 0, 0, 1)), size=1) +
  guides(edge_color=guide_legend(override.aes=list(shape=NA)),
         color=guide_legend(override.aes=list(edge_width=NA))) +
  theme_graph(background='white', text_colour='black', bg_text_colour='black') +
  expand_limits(x=c(-1.15, 1.5), y=c(-1.2, 1)) +
  theme(plot.title = element_text(size = 15, face = "bold",hjust = 0.4),
        plot.margin=rep(unit(0,"null"),4),
        legend.title=element_text(size=5,face="bold"),
        legend.text=element_text(size=5),
        legend.position=c(1,0), legend.justification=c(1,0), legend.key.height=unit(c(0,0,0,0),"cm")) +
  ggtitle("Ridge") 

# Export
png(filename="subsample_ridge_coefs_connectogram.png", width=1550, height=1150, res=300)
grid.arrange(FCplot, nrow=1, ncol=1, 
             left=textGrob("Left hemisphere", gp=gpar(fontface=2, fontsize=6), rot=90, hjust=0.5, x=0.5), 
             right=textGrob("Right hemisphere", gp=gpar(fontface=2, fontsize=6), rot=90, hjust=0.5, x=-3))
dev.off()
