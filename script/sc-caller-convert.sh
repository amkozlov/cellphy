#!/bin/sh
#SCcaller_conversion script 
#This script will take the FPL field from SC-Caller VCFs and convert them into a standard PL field.
#Created by: Alexey Kozlov, Joao M Alves, Alexandros Stamatakis & David Posada - 16 June 2020
#mailto: jalves@uvigo.es

[ $# -eq 0 ] && { printf "Usage: ./sc-caller-convert.sh inputVCF SamplePrefix\nCreated by: Alexey Kovlov, Joao M Alves, Alexandros Stamatakis & David Posada - June 2020\n"; exit 1; }
if [ $# -lt 2 ]; then
  echo 1>&2 "Not enough arguments. Learn usage by typing: ./sc-caller.conversion.sh"
  exit 2

else 

#define variables
input=$1
prefix=$2

# change sampleID
echo CELL001 $prefix > temp_rename
bcftools reheader -s temp_rename $input -o temp.renamed.vcf

# Remove indels and non-biallelic sites
bcftools view --types snps -f "." temp.renamed.vcf -o temp.snvs.vcf

#correct vcf header and vcf body
grep "#" temp.snvs.vcf > head
sed -i 's/FORMAT=<ID=PL,Number=G/FORMAT=<ID=FPL,Number=4/' head
sed -i '12i##FORMAT=<ID=PL,Number=G,Type=Integer,Description="Normalized, Phred-scaled likelihoods for genotypes as defined in the VCF specification">' head
awk 'BEGIN{FS="\t"}{if ($5 !~ '/.,./') print $0}' temp.snvs.vcf > temp.snvs.bi.vcf
grep -v "#" temp.snvs.bi.vcf | cut -d ":" -f 1-11 | sed 's/PL/FPL:PL/g' > temp

#Create PL field and rejoin
grep -v "#" temp.snvs.bi.vcf | cut -d ":" -f 11 | sed 's/\,/\t/g' | awk 'BEGIN{FS="\t"}{if ($1>=$2) print $2","$3","$4; else print $1","$3","$4}' > tempPL
paste -d ":" temp tempPL > tempF
cat head tempF > $prefix".PL-fixed.vcf"

# remove temp files
rm head
rm temp_rename
rm temp.snvs.vcf
rm temp.snvs.bi.vcf
rm tempPL
rm tempF
fi
