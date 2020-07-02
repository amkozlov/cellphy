#!/bin/sh
#CellPhy - Mutation mapping plot
#Created by: Alexey Kovlov, Joao M Alves, Alexandros Stamatakis & David Posada - 16 June 2020
#mailto: jalves@uvigo.es

[ $# -eq 0 ] && { printf "Usage: ./cellphy-mutationmapping.sh raxml.mutationMapTree raxml.mutationMapList Output_prefix [geneIDs]\nCreated by: Alexey Kovlov, Joao M Alves, Alexandros Stamatakis & David Posada - 16 June 2020\n*Required files:\n\t-Tree\n\t-Mutation List\n\t-Output Prefix\n\n*Optional:\n\t-Gene IDs (Tab-delimited)\n"; exit 1; }
if [ $# -lt 3 ]; then
  echo 1>&2 "Not enough arguments. Learn usage by typing: ./cellphy-mutationmapping.sh"
  exit 2

elif [ $# -eq 3 ]; then
Tree=$1
Mutation_List=$2
Out=$3

cp $Mutation_List tempList
awk 'BEGIN{FS="\t"}{if ($2=="0") print $1"\t"$2"\tNA"; else print $0}' tempList > temp
mv temp tempList
echo "Generating tree plot..."
export tree_name=$Tree
export output_prefix=$Out

R --quiet --vanilla < cellphy-mutationmapping.R >& /dev/null
rm tempList
echo "Done!"

else 
Tree=$1
Mutation_List=$2
Out=$3
GeneIDs=$4

echo "Converting positions to GeneID..."
cp $Mutation_List tempList

while read -r line
do old=$(echo $line | cut -d " " -f 1)
new=$(echo $line | cut -d " "  -f 2)
gsed -i "s/${old}/${new}/g" tempList
done < $4
awk 'BEGIN{FS="\t"}{if ($2=="0") print $1"\t"$2"\tNA"; else print $0}' tempList > temp
mv temp tempList
echo "Done!"

echo "Generating tree plot..."
export tree_name=$Tree
export output_prefix=$Out

R --quiet --vanilla < cellphy-mutationmapping.R >& /dev/null
rm tempList
echo "Done!"
fi
