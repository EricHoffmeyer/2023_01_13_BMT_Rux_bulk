#!/usr/bin/env bash
#test
RAN_ON=$(date +%Y_%m_%d_%H_%M_%S)
NUMBER=0

INVESTIGATOR=verneris
PROJECT=2023_01_04_BMT_Rux_bulk

RNASEQ=/beevol/home/hoffmeye/documents/bulk_RNAseq
DATA=$RNASEQ/${INVESTIGATOR}/$PROJECT
SCRIPTS=$DATA/scripts
FASTQ=$DATA/fastq_files
FASTQC=$DATA/qc_files_before_trimming

mkdir -p $FASTQC
cd $FASTQ

rename "_R1_001" ".R1" *.gz
rename "_R2_001" ".R2" *.gz
rename "_R1" ".R1" *.gz
rename "_R2" ".R2" *.gz

#for FILE in `ls *.fastq.gz | cut -d "." -f 1`; # for single-end sequencing reads
for FILE in `ls *.fastq.gz | cut -d "." -f 1,2`; # for paired-end sequencing reads
do
echo $FILE
NUMBER=$((${NUMBER}+1)) 
cat << EOF > $SCRIPTS/${RAN_ON}_${FILE}_script.sh
#BSUB -J QC_$NUMBER
#BSUB -e $SCRIPTS/${RAN_ON}_${FILE}_QC_before_trimming.err
#BSUB -o $SCRIPTS/${RAN_ON}_${FILE}_QC_before_trimming.out
#BSUB -n 12
#BSUB -R "span[hosts=1]"
#BSUB -R "select[mem>10] rusage[mem=10]"

source /etc/profile.d/modules.sh

module load java/1.8
module load fastqc/0.11.9

FASTQ=$FASTQ
FASTQC=$FASTQC

cd $FASTQ

fastqc -t 10 -o $FASTQC ${FILE}.fastq.gz

EOF

bsub -q normal < $SCRIPTS/${RAN_ON}_${FILE}_script.sh

rm -f $SCRIPTS/${RAN_ON}_${FILE}_script.sh

done

