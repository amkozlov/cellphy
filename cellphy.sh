#!/bin/sh
# CellPHY main script 
# Created by: Alexey Kozlov, Joao M Alves, Alexandros Stamatakis & David Posada - July 2020

usage() 
{
  echo "CellPhy v0.9.0 - 16.07.2020"
  echo "Created by: Alexey Kozlov, Joao M Alves, Alexandros Stamatakis & David Posada\n"
  echo "Usage: ./cellphy.sh input.VCF [geneIDs]"
}

if [ $# -eq 0 ]; then 
  usage
  exit 1
fi

do_mutmap=1
do_mutfilter=0
do_viz=1
gene_names=
outgroup=NONE

if [ $# -gt 1 ]; then
  arg_mutmap=$2
  if [ $arg_mutmap -eq "MAPALL" ]; then
    do_mutfilter=0
  elif [ $arg_mutmap -eq "MAPNONE" ]; then
    do_mutmap=0
  else
    do_mutfilter=1
    gene_names=$arg_mutmap 
  fi
fi

msa=$1
prefix=`echo "$msa" | cut -f 1 -d '.'`

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

gt_model=GTGTR4+FO+E
vcf_model=GTGTR4+FO
raxml_args=
#raxml_args="$raxml_args --nofiles"

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
    model=$vcf_model
  elif [ `zgrep -c -e "$sciphi_magic" -e "$sciphi2_magic" $msa` -gt 0 ]; then
    # SciPhI VCF is non-standard and can only be used in EP17 mode
    model=$gt_model
    raxml_args="$raxml_args --prob-msa off"
  else
    # hopefully standard VCF
    model=$vcf_model
  fi
else
  echo "non-VCF input detected"
  fmt=auto
  model=$gt_model
fi  

$raxml --all --msa $msa --model $model --msa-format $fmt --bs-tree autoMRE{200} --bs-metric fbp,tbe --force perf_threads --prefix $prefix  $raxml_args

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

  $raxml --mutmap --msa $mutmap_msa --model $model --tree $mltree --opt-branches off --prefix $mutmap_prefix --force perf_threads

  if [ $do_viz -eq 1 ]; then
    mutmap_tree=$mutmap_prefix.raxml.mutationMapTree
    mutmap_list=$mutmap_prefix.raxml.mutationMapList
    $mutmap_viz $mutmap_tree $mutmap_list $outgroup $mutmap_prefix $gene_names
  fi
fi

echo "Dnne!"
