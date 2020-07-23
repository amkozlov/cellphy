#!/usr/bin/env Rscript
# CellPhy - Install R packages
# Created by: Alexey Kozlov, Joao M Alves, Alexandros Stamatakis & David Posada - 09.07.2020
# mailto: jalves@uvigo.es

# Install required libraries

if (!require('ggtree', quietly = T)) { 
  install.packages("BiocManager",repos='https://cloud.r-project.org'); 
  BiocManager::install("ggtree", update=F, ask=F); 
}

#if (!require('ggrepel', quietly = T)) {
#  install.packages("ggrepel",repos='https://cloud.r-project.org');
#}

