#!/bin/sh
# CellPHY main script 
# Created by: Alexey Kozlov, Joao M Alves, Alexandros Stamatakis & David Posada - July 2021

version() 
{
  echo "CellPhy v0.9.2 - 08.07.2021 - https://github.com/amkozlov/cellphy"
  echo "Created by: Alexey Kozlov, Joao M Alves, Alexandros Stamatakis & David Posada"
  echo "Support: https://groups.google.com/forum/#!forum/raxml\n"
}

usage() 
{
  echo "Usage: ./cellphy.sh [COMMAND] [options] input.VCF"
  echo "\nCOMMAND:"
  echo "\tFULL         Tree search+bootstrapping+mutation mapping (default)"
  echo "\tSEARCH       Thorough tree search (20 starting trees) "
  echo "\tFAST         Fast tree search from a single starting tree"
  echo "\nOptions:"
  echo "\t-a           Use approximate 10-state model (~2x faster)"
  echo "\t-g FILE      Tab-delimited list of SNVs for mapping, with respective gene names"
  echo "\t-m MODEL     Evolutionary model definition (RAxML-NG syntax)"
  echo "\t-o OUTGR     Outgroup taxon list (comma-separated)"
  echo "\t-p PREFIX    Prefix for output files"
  echo "\t-r           REDO mode: overwrite all result files"
  echo "\t-t THREADS   Number of threads to use (default: autodetect)"

  echo "\nExpert usage: ./cellphy.sh RAXML [raxml options]\n"
}

version

if [ $# -eq 0 ]; then 
  usage
  exit 1
fi

root=`dirname $0`
raxml_stem=$root/bin/raxml-ng-cellphy
sc_convert=$root/script/sc-caller-convert.sh
support_viz=$root/script/support-map.R
mutmap_viz=$root/script/mutation-map.R

# detect OS
os=`uname -s`
case "$os" in
  'Linux')
     raxml=${raxml_stem}-linux
     ;;
  'Darwin')
     raxml=${raxml_stem}-osx
     ;;
  *)
     echo "Unsupported operating system: ", $os
     exit 1
esac

do_mutmap=1
do_mutfilter=0
do_viz=1
gene_names=
outgroup=NONE
verbose=0
redo=0
use_gt10=0
model=
raxml_args="--force perf_threads"
raxml_search_args=
bs_args="--bs-tree autoMRE{200} --bs-metric fbp,tbe"

# check for run mode
case "$1" in
  'RAXML')
     shift
     $raxml $@
     exit
     ;;
  'FULL')
     shift
     mode="--all"
     raxml_search_args="$raxml_search_args $bs_args"
     ;;
  'SEARCH')
     shift
     mode="--search"
     ;;
  'FAST')
     shift
     mode="--search"
     raxml_search_args="$raxml_search_args --tree pars{1}"
     ;;
   *)
     mode="--all"
     raxml_search_args="$raxml_search_args $bs_args"
esac

OPTIND=1

# parse options
while getopts "h?vag:o:p:rm:t:yz" opt; do
    case "$opt" in
    h|\?)
        usage
        exit 0
        ;;
    v)  verbose=1
        ;;
    a)  use_gt10=1
        ;;
    g)  gene_names=$OPTARG
        do_mutfilter=1
        ;;
    o)  outgroup=$OPTARG
        ;;
    p)  prefix=$OPTARG
        ;;
    r)  redo=1
        ;;
    m)  model=$OPTARG
        ;;
    t)  threads=$OPTARG
        ;;
    y)  do_mutmap=0
        ;;
    z)  do_viz=0
        ;;
    esac
done

shift $((OPTIND-1))

[ "${1:-}" = "--" ] && shift

if [ $# -eq 0 ]; then
  usage
  exit 1
fi

msa=$1

if [ $use_gt10 -eq 1 ]; then
  gt_model=GT10+FO+E
  vcf_model=GT10+FO
else
  gt_model=GT16+FO+E
  vcf_model=GT16+FO
fi

vcf_magic='##fileformat=VCFv4.'
sccaller_magic='##source=SCcallerV2.0.0'
sciphi_magic='##source=SCATE'
sciphi2_magic='##source=SCIPhI'

if [ `zgrep -c "$vcf_magic" $msa` -gt 0 ]; then
  echo "VCF input detected"
  fmt=vcf

  if [ `zgrep -c "$sccaller_magic" $msa` -gt 0 ]; then
    # SCCaller VCF is non-standard and requires conversion
    $sc_convert $msa
    amodel=$vcf_model
  elif [ `zgrep -c -e "$sciphi_magic" -e "$sciphi2_magic" $msa` -gt 0 ]; then
    # SciPhI VCF is non-standard and can only be used in EP17 mode
    amodel=$gt_model
    raxml_args="$raxml_args --prob-msa off"
  else
    # hopefully standard VCF
    amodel=$vcf_model
  fi
else
  echo "non-VCF input detected"
  fmt=auto
  amodel=$gt_model
fi  

[ -z $model ] && model=$amodel
[ -z $prefix ] && prefix=$msa
[ ! -z $threads ] && raxml_args="$raxml_args --threads $threads"
[ $redo -eq 1 ] && raxml_args="$raxml_args --redo"

$raxml $mode --msa $msa --model $model --msa-format $fmt --prefix $prefix  $raxml_search_args $raxml_args

mltree=$prefix.raxml.bestTree
bstree=$prefix.raxml.support

# temp hack, TODO: FBP+TBE in one file
if [ -f ${bstree}FBP ]; then
  bstree=${bstree}FBP
fi

if [ $do_viz -eq 1 ] && [ -f $bstree ]; then
  $support_viz $bstree $outgroup
fi

if [ $do_mutmap -eq 1 ]; then
  
  if [ $do_mutfilter -eq 1 ]; then
    mutmap_msa="$msa.filtered"
    bcftools view -T $gene_names $msa -O v -o $mutmap_msa
  else
    mutmap_msa=$msa
  fi

  mutmap_prefix="$prefix.Mapped"

  $raxml --mutmap --msa $mutmap_msa --model $model --tree $mltree --opt-branches off --prefix $mutmap_prefix $raxml_args

  if [ $do_viz -eq 1 ]; then
    mutmap_tree=$mutmap_prefix.raxml.mutationMapTree
    mutmap_list=$mutmap_prefix.raxml.mutationMapList
    $mutmap_viz $mutmap_tree $mutmap_list $outgroup $mutmap_prefix $gene_names
  fi
fi

echo "Done!"
