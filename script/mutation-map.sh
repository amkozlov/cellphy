#!/bin/sh
#CellPhy - Mutation mapping plot
#Created by: Alexey Kozlov, Joao M Alves, Alexandros Stamatakis & David Posada - 16 June 2020
#mailto: jalves@uvigo.es

[ $# -eq 0 ] && { printf "Usage: ./cellphy-mutationmapping.sh raxml.mutationMapTree raxml.mutationMapList Outgroup Output_prefix [geneIDs]\nCreated by: Alexey Kozlov, Joao M Alves, Alexandros Stamatakis & David Posada - 16 June 2020\n*Required files:\n\t-Tree\n\t-Mutation List\n\t-Outgroup name\n\t-Output Prefix\n\n*Optional:\n\t-Gene IDs (Tab-delimited)\n"; exit 1; }
if [ $# -lt 4 ]; then
  echo 1>&2 "Not enough arguments. Learn usage by typing: ./cellphy-mutationmapping.sh"
  exit 2

elif [ $# -eq 4 ]; then
Tree=$1
Mutation_List=$2
Outgroup=$3
Out=$4

cp $Mutation_List tempList
awk 'BEGIN{FS="\t"}{if ($2=="0") print $1"\t"$2"\tNA"; else print $0}' tempList > temp
mv temp tempList
echo "Generating tree plot..."
export tree_name=$Tree
export ROOT=$Outgroup
export output_prefix=$Out

R --quiet --vanilla < cellphy-mutationmapping.R >& /dev/null
rm tempList
echo "Done!"

else 

Tree=$1
Mutation_List=$2
Outgroup=$3
Out=$4
GeneIDs=$5

echo "Converting positions to GeneID..."
cp $Mutation_List tempList

awk 'BEGIN{FS="\t"}{print $1":"$2"\t"$3}' $GeneIDs > temp2

while read -r line
do 
old=$(echo $line | cut -d " " -f 1)
new=$(echo $line | cut -d " "  -f 2)
gsed -i "s/${old}/${new}/g" tempList
done < temp2
awk 'BEGIN{FS="\t"}{if ($2=="0") print $1"\t"$2"\tNA"; else print $0}' tempList > temp
mv temp tempList
echo "Done!"

echo "Generating tree plot..."
export tree_name=$Tree
export ROOT=$Outgroup
export output_prefix=$Out

R --quiet --vanilla < cellphy-mutationmapping.R >& /dev/null
rm tempList
rm temp2
echo "Done!"
fi
