#!/usr/bin/env Rscript
##!/usr/bin/env Rscript --vanilla
#CellPhy - Mutation mapping plot
#Created by: Alexey Kovlov, Joao M Alves, Alexandros Stamatakis & David Posada - 16 June 2020
#mailto: jalves@uvigo.es

#Load/install required libraries
if (!require('castor')) install.packages('castor',repos='https://cloud.r-project.org'); library('castor')
if (!require('ggplot2')) install.packages('ggplot2',repos='https://cloud.r-project.org'); library('ggplot2')
if (!require('ggtree')) install.packages("BiocManager",repos='https://cloud.r-project.org'); BiocManager::install("ggtree", update=F, ask=T); library('ggtree')
if (!require('ggrepel')) install.packages('ggrepel',repos='https://cloud.r-project.org'); library('ggrepel')

#Read Environment variables:
tree <- Sys.getenv('tree_name')
Out <- Sys.getenv('output_prefix')

#Load Tree and mutation list
tree <- read_tree(file=tree, look_for_edge_labels=T)
data <- read.table("tempList", head=F)
names(data) <- c("edgeID", "NumberOfMutations", "MutationList")

#Replace edges by mutationList
for (i in 1:length(tree$edge.label)) {	
tree$edge.label[i] = as.character(subset(data[,3], data$edge==tree$edge.label[i]))
}

#Text for plotting
edge=data.frame(tree$edge, edge_num=tree$edge.label)
colnames(edge)=c("parent", "node", "edge_muts")
edge$edge_muts <- gsub(",","\n",edge$edge_muts)

#Plot and save
pdf(paste(Out, ".Tree_mapped.pdf", sep=""))
p=ggtree(tree) + geom_tiplab(size=2.5)
p %<+% edge + geom_label_repel(aes(x=branch, label=edge_muts), size=1.1)
dev.off()
