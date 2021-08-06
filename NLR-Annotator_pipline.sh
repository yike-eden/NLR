#!/bin/bash 
# Author: Yi Ke
# time: 2021/8/5
genomelist=$1
chopjar=$2
parserjar=$3
annotatorjar=$4
mast=$5
memexml=$6
threold=$7
flank=$8

if [ $# -ne 8 ]
then
echo " usage: sh  NLR-Annotator_pipline.sh  genome-fasta.list Chopsequence.jar  NLR-Parser3.jar NLR-Annotator.jar mast meme.xml threshold flanking
       -- genome-fasta.list   merge the genome files (absolute paths) of each species into a list
       -- Chopsequence.jar    the jar file(absolute paths)
       -- NLR-Parser3.jar     the jar file(absolute paths)
       -- NLR-Annotator.jar   the jar file(absolute paths)
       -- mast                mast in meme software(absolute paths), eg:/share/nas1/zqd/miniconda/miniconda3/bin/mast
       -- meme.xml            the file of infomation about motifs (absolute paths)
       -- threshold           core numbers
       -- flanking            the length of flanking sequence around the loci
      version: meme 5.1.1(or above); python=3.6.6(or above); java=1.6 or higher
      function: annotation the NLR loci
      principle: 1. dissection of genomic input sequence into overlapping fragments(default:20kb; overlap:5kb) ------by chopsequence.jar; 
                 2. Each fragment is translated in all six reading frames. Amino acid sequences are screened for NLR associated motifs. The
                    positions of motifs are projected back onto their originating 20-kb genomic fragments. Motif-containing genomic fragments are merged, and redundant motif                    resulting from overlaps are removed.  ---------by NLR-Parser3.jar 					
		 3. Motif combinations associated with an NB-ARC domain (inset, right side) are identified in the genomic sequence,Overlapping combinations are
		    merged. The NB-ARC locus is used as a seed to search the DNA sequence upstream and downstream for additional NLR-associated motifs (e.g.those indicative
		    of a coiled coil or LRR). The final NLR locus is reported. ---------by NLR-Annotator.jar";
exit
fi;

# 1.Chopsequence.jar  dissection of genomic input sequence into overlapping fragments(default:20kb; overlap:5kb)
mkdir chopsequence
while read i
do 
java -jar  $chopjar -i $i -o ./chopsequence/${i##*/}.out-chopsequence.fa > ./chopsequence/${i##*/}.log 2>&1
done < $genomelist

# 2. NLR-Parser3.jar
mkdir NLR-Parser3
while read i
do
java -jar  $parserjar -t $threold -y $mast -x $memexml -i ./chopsequence/${i##*/}.out-chopsequence.fa -c ./NLR-Parser3/${i##*/}.nlr.xml > ./NLR-Parser3/${i##*/}.log 2>&1
done < $genomelist

# 3. NLR-Annotator.jar
mkdir NLR-Annotator
mkdir motif_Alignment
mkdir NLR_fasta  
while read i
do
java -jar $annotatorjar -i ./NLR-Parser3/${i##*/}.nlr.xml -g ./NLR-Annotator/${i##*/}.gff -a ./motif_Alignment/${i##*/}.output.nbarkMotifAlignment.fasta -f $i ./NLR_fasta/${i##*/}.out.nlr.fasta  $flank
done < $genomelist
