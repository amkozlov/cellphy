# CellPhy: accurate and fast probabilistic inference of single-cell phylogenies

## Installation

0. Supported operating systems: currently, Linux and macOS only.

1. Clone GitHub repository:

```
git clone https://github.com/amkozlov/cellphy
```

2. Install dependencies

CellPhy is using bundled [RAxML-NG](https://github.com/amkozlov/raxml-ng) to perform tree inference, hence this core functionality is available without installing any dependencies.
However, some additional features (tree visualization, format conversion etc.) rely on external software. So in order to have a fully functional pipeline, it is *highly recommended* to install following packages:

- [bcftools](https://github.com/samtools/bcftools)
- [R environment](https://www.r-project.org/)
- R packages: [ggtree](https://github.com/YuLab-SMU/ggtree) and its dependencies (treeio, ape...)

Your installation options depend on the system:

a) For Ubuntu and RedHat/CentOS Linux with root access, we provide a script for automatic dependency installation:

```
cd cellphy
sudo ./install.sh  
```

b) Under macOS, you can use [homebrew](https://brew.sh/):

```
brew install r
brew install bcftools
```

c) In a cluster environment, chances are the required packages are already installed and can be loaded with the `module` command, e.g.:

```
module load bcftools R
```

3. Check that everything works:

```
./cellphy.sh
```

## Usage

Standard analysis with default parameters:
```
./cellphy.sh input.vcf
```

General syntax:
```
./cellphy.sh [COMMAND] [options] input.vcf
```

COMMAND:
- `FULL`        Full analysis: Thorough tree search + bootstrapping + mutation mapping (default)

- `SEARCH`      Thorough tree search (20 starting trees) + mutation mapping 

- `FAST`        Fast tree search (single starting tree) + mutation mapping

Options:
- `-a`          Use approximate 10-state model (~2x faster)

- `-g FILE`     Tab-delimited list of SNVs for mapping, with respective gene names ([example](https://github.com/amkozlov/cellphy/blob/master/example/CRC24.MutationsMap))

- `-m MODEL`    Evolutionary model definition in [RAxML-NG format](https://github.com/amkozlov/raxml-ng/wiki/Input-data#single-model)<br>
                **NOTE**: partitioned models are not supported at the moment!

- `-o OUTGR`    Outgroup taxon list (comma-separated), e.g. `-o healthy` or `-o H1,H2`

- `-p PREFIX`   Prefix for output files (default: input filename w/o extension)

- `-r`          REDO mode: overwrite all result files

- `-t THREADS`  Number of threads to use (default: autodetect)

- `-y`          Skip mutation mapping          

- `-z`          Skip tree plotting (no PDF/SVG output)

## Tutorial

For some advanced usage examples, please see [tutorial](https://github.com/amkozlov/cellphy/blob/master/doc/CellPhy-Tutorial.pdf).

## Citations

When using CellPhy, please cite this paper:

Alexey Kozlov, João M Alves, Alexandros Stamatakis, and David Posada (2020) **CellPhy: accurate and fast probabilistic inference of single-cell phylogenies.** *bioRxiv preprint* doi: [10.1101/2020.07.31.230292](https://doi.org/10.1101/2020.07.31.230292)

When using tree visualization features (e.g., mutation map), please additionally cite [ggtree](https://github.com/YuLab-SMU/ggtree):

G Yu, DK Smith, H Zhu, Y Guan, TTY Lam (2017) **ggtree: an R package for visualization and annotation of phylogenetic trees with their covariates and other associated data.**
*Methods in Ecology and Evolution*. 2017, 8(1):28-36. doi: [10.1111/2041-210X.12628](https://doi.org/10.1111/2041-210X.12628)
