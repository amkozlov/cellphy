---
title: "CellPhy - Mutation mapping"
author: '[João MF Alves](mailto:jmfernandesalves@gmail.com)'
date: "June 2020"
output:
  html_document:
    highlight: textmate
    keep_md: yes
    number_sections: yes
    theme: cosmo
    toc: yes
---

<br>

#**Introductory Note**
<p style='text-align: justify;'>In the following supporting document, we will go through all steps required to generate the results from  [**Cellphy's**](https://github.com/amkozlov/raxml-ng/tree/cellphy) mutation mapping function. For reproducibility purposes, this step-by-step tutorial contains all information needed to produce the figure 6.A presented in the main manuscript.</p>

***

#**Mapping mutations onto a phylogenetic tree**
<p style='text-align: justify;'>Cancer genomics studies are, for the most part, interested in understanding when "*driver*" mutations appeared in the malignant cell population. Synonymous mutations are generally thought to be functionally silent and evolutionarily neutral, so our focus here will be to solely map the non-synonymous mutations present in our SNV sets. On this basis, we will take as input a thinned VCF only carrying the set of non-synonymous mutations together with the best tree and model estimates from our previous Cellphy run (tree search + bootstrap).</p>


```bash
$ MODEL=CRC24.raxml.bestModel
$ TREE=CRC24.raxml.bestTree

$ raxml-ng --mutmap \
    --msa CRC24.nonsynonymous.vcf \
    --model $MODEL --tree $TREE --opt-branches off \
    --prefix CRC24.non-synonymous_Mapped --threads 1
```


***

#**Visualizing the results**
<p style='text-align: justify;'>Once it's done, Cellphy should output 2 distinct files:.</p>

* **(A)** _CRC24.non-synonymous_Mapped.mutationMapTree_  
   &rarr; Newick tree file with indexed branches
* **(B)** _CRC24.non-synonymous_Mapped.mutationMapList_  
   &rarr; Text file with the number and the list of mutations per branch


<p style='text-align: justify;'>_Cellphy.MutationMapping.sh_ can now be used to plot the mutations onto the inferred phylogenetic tree. If you run it wihtout any parameters, it will show a help message:</p>


```bash
$ ./Cellphy.MutationMapping.sh 
Usage: ./Cellphy.MutationMapping.sh raxml.mutationMapTree raxml.mutationMapList Output_prefix [geneIDs]
Created by: Alexey Kovlov, Joao M Alves, Alexandros Stamatakis & David Posada - 16 June 2020
*Required files:
	-Tree
	-Mutation List
	-Output Prefix

*Optional:
	-Gene IDs (Tab-delimited)
```

<p style='text-align: justify;'>Now let's run it again but this time with the required parameters:</p>

```bash
$ ./Cellphy.MutationMapping.sh CRC24.non-synonymous_Mapped.mutationMapTree CRC24.non-synonymous_Mapped.mutationMapList CRC24.Mapped
Generating tree plot...
Done!
```

<p style='text-align: justify;'>If everything went as expected, you should have generated the following figure, in PDF format (_CRC24.Mapped.Tree_mapped.pdf_), where the mutations are mapped onto the tree branches:</p>
![](/Users/dxjalves/Desktop/2020/3.CellPhy/SUPPMAT/SCRIPTS/CRC24.Mapped.Tree_mapped.jpg)


<p style='text-align: justify;'>If you are interested in plotting the gene names instead, you can provide a tab-delimited file linking the genomic position to its gene ID:</p>


```bash
$ head -n5 CRC24.nonSYNONYMOUS.GeneIDs 
#chr:pos	gene
1:11888572	CLCN6
1:16909192	NBPF1
1:45474248	HECTD3
1:75036916	C1orf173
```

<p style='text-align: justify;'>Afterwards, we can run _Cellphy.MutationMapping.sh_ again, but changing the output prefix so that you don't overwrite the previous results:</p>

```bash
$ ./Cellphy.MutationMapping.sh CRC24.non-synonymous_Mapped.mutationMapTree CRC24.non-synonymous_Mapped.mutationMapList CRC24.GeneID.Mapped CRC24.nonSYNONYMOUS.GeneIDs  
Converting positions to GeneID...
Done!
Generating tree plot...
Done!
```

<p style='text-align: justify;'>You will notice that our tree now has the gene names displayed, instead of the genomic positions:</p>
![](/Users/dxjalves/Desktop/2020/3.CellPhy/SUPPMAT/SCRIPTS/CRC24.GeneID.Mapped.Tree_mapped.jpg)
