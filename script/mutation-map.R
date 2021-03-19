#!/usr/bin/env Rscript
# CellPhy - Mutation mapping plot
# Created by: Alexey Kozlov, Joao M Alves, Alexandros Stamatakis & David Posada - 19.03.2021
# mailto: jalves@uvigo.es

# Load required libraries

if (!suppressMessages(require('ggtree', quietly = T))) { 
  message("ERROR: package not found: ggtree\nPlease run install.sh to fix.")
  quit()
}

library(treeio)

#if (!suppressMessages(require('ggrepel', quietly = T))) {
#  message("ERROR: package not found: ggrepel\nPlease run install.sh to fix.")
#  quit()
#}

usage <- function() 
{ 
  message ("CellPhy - Mutation mapping plot - 22.07.2020")
  message ("Created by: Alexey Kozlov, Joao M Alves, Alexandros Stamatakis & David Posada\n")
  message ("Usage: ./mutation-map.R raxml.mutationMapTree raxml.mutationMapList Outgroup Output_prefix [geneIDs]\n")
  message ("*Required files:\n\t-Tree\n\t-Mutation List")
  message ("\t-Outgroup name (comma-delimited list of taxa or NONE)\n\t-Output Prefix")
  message ("\n*Optional:\n\t-Gene IDs (tab-delimited)\n")
}


read.mtree <- function(file) {
  tree_text = readLines(file)
  tree_text = gsub('(:[0-9\\.eE\\+\\-]+)\\[(\\d+)\\]', '\\1\\[&&NHX:N=\\2\\]', tree_text)
  tree_text = gsub(';', '\\[&&NHX:N=-1\\];', tree_text)
#  print(tree_text)
  tree = read.nhx(textConnection(tree_text))
  return(tree)
}

#Parse command line arguments
args = commandArgs(trailingOnly=TRUE)
genef = NA
if (length(args) >= 4) {
  treef = args[1]
  mutf = args[2] 
  outgr = args[3]
  prefix = args[4]
  if (length(args) == 5) {
    genef = args[5]
  }
} else {
  usage()
  quit()
}

#Output dimensions
out_w=8
out_h=12

#Load Tree and mutation list
tree = read.mtree(treef)

data = read.table(mutf, head=F, fill=T, col.names=c("edgeID", "NumberOfMutations", "MutationList"))

gene_names = NULL
if (!is.na(genef)) {
  gene_names = read.table(genef, head=F, fill=T)
  names(gene_names) = c("chr", "pos", "gene")
  gene_names$id = paste(gene_names$chr, gene_names$pos, sep=":") 
  message("Converting positions to GeneID...")
}

#Replace edges by mutationList
for (i in 1:length(tree@data$N)) {	
  if (tree@data$N[i] != -1) {
    mut_label = as.character(subset(data[,3], data$edgeID == tree@data$N[i]))
    if (is.null(gene_names)) {
      mut_label = gsub(",", "\n", mut_label)
    } else if (mut_label != "") {
      muts = strsplit(mut_label, ",")[[1]]
      for (j in 1:length(muts)) {
         muts[j] <- as.character(gene_names[gene_names$id == muts[j], ]$gene)
      }
      mut_label = paste(muts, collapse="\n")
    }
    tree@data$N[i] = mut_label
  } else {
    tree@data$N[i] = ""
  }
}

tree@data = tree@data[tree@data$N != "",]

#Root tree with outgroup
if (outgr != "NONE") {
  outgr_taxa = strsplit(outgr, ",")[[1]]
  tree@phylo = ape::root(tree@phylo, outgroup=outgr_taxa, resolve.root=T)
}

#Plot and save
out_pdf = paste(prefix, ".pdf", sep="")
out_svg = paste(prefix, ".svg", sep="")

message("Generating mutation-mapped tree plot...")

p = ggtree(tree, branch.length='none') + geom_tiplab(size=1.8) 

p = p + geom_label(aes(x=branch, label=N), fill='lightgreen', size=1.1, na.rm=T)
#p = p + geom_label_repel(aes(x=branch, label=N), fill='lightgreen', size=1.0)

pdf(out_pdf, width=out_w, height=out_h)

p

svg(out_svg, width=out_w, height=out_h)

p

dummy = dev.off()

message("Done!")

#warnings()
