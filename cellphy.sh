#!/bin/sh
# CellPHY main script 
# Created by: Alexey Kozlov, Joao M Alves, Alexandros Stamatakis & David Posada - July 2020

if [ $# -eq 0 ]; then 
 echo "CellPhy v0.9.0 - 09.07.2020"
 echo "Created by: Alexey Kozlov, Joao M Alves, Alexandros Stamatakis & David Posada"
 echo ""
 echo "Usage: ./cellphy.sh input.VCF [geneIDs]"
 exit 1
fi

msa=$1

root=`dirname $0`
raxml=$root/bin/raxml-ng-cellphy
sc_convert=$root/script/sc-caller-convert.sh
mutmap_viz=$root/script/mutation-map.sh

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

$raxml --all --msa $msa --model $model --msa-format $fmt --bs-metric fbp,tbe --force perf_threads $raxml_args


