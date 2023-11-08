#!/usr/bin/env bash

INVESTIGATOR=verneris
PROJECT=2023_06_23_Jessica_B7H3_bead_stim

RAN_ON=$(date +%Y_%m_%d)
NUMBER=0
ADAPTERS=/cluster/software/modules-sw/BBMap/bbmap_38.86/resources
RNASEQ=/beevol/home/hoffmeye/documents/bulk_RNAseq
GENOMES=/beevol/home/hoffmeye/documents/genomes
# SALMON=/beevol/home/phangtzu/Documents/tools/salmon-1.6.0_linux_x86_64/bin
INDEX1=$GENOMES/STAR_indices/human_GRCh38_for_150bp_reads
INDEX2=$GENOMES/Salmon_indices/human_GRCh38_all_cDNAs_index
DATA=$RNASEQ/${INVESTIGATOR}/$PROJECT
SCRIPTS=$DATA/scripts
FASTQ=$DATA/fastq_files
TRIMMED=$DATA/trimmed_fastq_files
SORTED=$DATA/sorted_bam_files_w_STAR
SALMONOUTPUT=$DATA/salmon_output_files
BIGWIG=$DATA/bigwig_files_normalized_w_RPGC
FLAGSTAT=$DATA/flagstat_report_w_STAR

mkdir -p $TRIMMED
mkdir -p $SORTED
mkdir -p $SALMONOUTPUT
mkdir -p $BIGWIG
mkdir -p $FLAGSTAT

cd $FASTQ

for FILE in `ls *R1.fastq.gz | cut -d "." -f 1 # | cut -d "_" -f 1,2,3,4,5`;
#for FILE in `ls MEG_3d_Anti1_S15_L001_R1_001.fastq.gz | cut -d "." -f 1 | cut -d "_" -f 1,2,3,4,5`;
do
echo $FILE
NUMBER=$((${NUMBER}+1))
cat << EOF > $SCRIPTS/${RAN_ON}_${FILE}.sh
#!/usr/bin/env bash

#BSUB -J RNASEQ_$NUMBER
#BSUB -e $SCRIPTS/${RAN_ON}_${FILE}.err
#BSUB -o $SCRIPTS/${RAN_ON}_${FILE}.out
#BSUB -n 12
#BSUB -R "span[hosts=1]"
#BSUB -R "select[mem>40] rusage[mem=40]"

source /etc/profile.d/modules.sh

# module load BBMap/38.8
module load bbtools/39.01
module load bowtie2/2.3.2
module load samtools/1.16.1
module load salmon/1.9.0
#module load gcc/5.4.0
module load STAR/2.7.10a
module load python/2.7.14
module load picard/2.20.1
module load bedtools/2.26.0
module load java/1.8

ADAPTERS=$ADAPTERS
RNASEQ=$RNASEQ
GENOMES=$GENOMES
INDEX1=$INDEX1
INDEX2=$INDEX2
DATA=$DATA
SCRIPTS=$SCRIPTS
FASTQ=$FASTQ
TRIMMED=$TRIMMED
SORTED=$SORTED
SALMONOUTPUT=$SALMONOUTPUT
BIGWIG=$BIGWIG
FLAGSTAT=$FLAGSTAT

# Trim adapter sequences using bbduk from bbtools/BBMap
bbduk.sh -Xmx38g \
    threads=10 \
    in1=$FASTQ/${FILE}.R1.fastq.gz \
    in2=$FASTQ/${FILE}.R2.fastq.gz \
    out1=$TRIMMED/${FILE}_R1.fastq.gz \
    out2=$TRIMMED/${FILE}_R2.fastq.gz \
    ref=$ADAPTERS/truseq.fa.gz \
    ftm=5 \
    ktrim=r k=23 mink=11 hdist=1 \
    minlen=30 qtrim=rl trimq=15 \
    tpe tbo

# Alignment with STAR
# STAR \
#     --genomeDir $INDEX1 \
#     --readFilesIn $TRIMMED/${FILE}_R1.fastq.gz $TRIMMED/${FILE}_R2.fastq.gz \
#     --readFilesCommand zcat \
#     --runThreadN 10 \
#     --outFilterScoreMinOverLread 0.66 \
#     --outFilterMatchNminOverLread 0.66 \
#     --outSAMtype BAM SortedByCoordinate \
#     --outFileNamePrefix $SORTED/${FILE}_ \
#     --quantMode GeneCounts

# Pseudo-alignment with Salmon
salmon quant -i $INDEX2 \
    -p 10 \
    -l A \
    -1 $TRIMMED/${FILE}_R1.fastq.gz \
    -2 $TRIMMED/${FILE}_R2.fastq.gz \
    -o $SALMONOUTPUT/${FILE} \
    --validateMappings  
    --seqBias \
    --gcBias \
    --numGibbsSamples 30 

# The -i argument tells salmon where to find the index 
# The -l A argument tells salmon that it should automatically determine the library type 
# of the sequencing reads (e.g. stranded vs. unstranded etc.). 
# The -1 and -2 arguments tell salmon where to find the left and right reads for this sample

# Index bam files
# samtools index -@ 10 $SORTED/${FILE}_Aligned.sortedByCoord.out.bam

## Convert .bam files into .bw (bigwig) files
# bamCoverage --bam $SORTED/${FILE}_Aligned.sortedByCoord.out.bam \
#     -o $BIGWIG/${FILE}.bw \
#     --numberOfProcessors 10 \
#     --normalizeUsing RPGC \
#     --effectiveGenomeSize 2913022398 # Number to use for human reads when multimapped are kept

#### Count the number of mapped reads if extraction is needed or for general information
# echo "$FILE" >> $FLAGSTAT/${RAN_ON}_${FILE}_report.txt
# samtools flagstat -@ 10 $SORTED/${FILE}_Aligned.sortedByCoord.out.bam >> $FLAGSTAT/${RAN_ON}_${FILE}_report.txt
# echo "" >> $FLAGSTAT/${RAN_ON}_${FILE}_report.txt

EOF

# echo $SCRIPTS/${RAN_ON}_${FILE}.sh 

bsub -q normal < $SCRIPTS/${RAN_ON}_${FILE}.sh


rm -f $SCRIPTS/${RAN_ON}_${FILE}.sh

done

