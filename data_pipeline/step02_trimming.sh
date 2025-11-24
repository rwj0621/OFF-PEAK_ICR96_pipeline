#!/bin/bash
# step02_trimming.sh - ICR96数据修剪

PAIRS_FILE="/data/share/liuyuxin_tanrenjie/ICR96/Database/pairs.tsv"
OUTPUT_DIR="/data/renweijie/ICR96/OFF-PEAK-std/step02_trimmed_fastq"

mkdir -p $OUTPUT_DIR

# 处理每个样本
tail -n +2 $PAIRS_FILE | while IFS=$'\t' read -r SAMPLE R1 R2; do
    echo "处理样本: $SAMPLE"
    
    trimmomatic PE -threads 4 -phred33 \
        $R1 $R2 \
        $OUTPUT_DIR/${SAMPLE}_R1_trimmed.fastq.gz $OUTPUT_DIR/${SAMPLE}_R1_unpaired.fastq.gz \
        $OUTPUT_DIR/${SAMPLE}_R2_trimmed.fastq.gz $OUTPUT_DIR/${SAMPLE}_R2_unpaired.fastq.gz \
        ILLUMINACLIP:/data/renweijie/anaconda3/envs/ICR96-OFF-PEAK/share/trimmomatic-0.40-0/adapters/TruSeq3-PE-2.fa:2:30:10:8:true \
    	LEADING:20 TRAILING:20 \
    	SLIDINGWINDOW:15:20 \
    	MINLEN:50
    echo "完成: $SAMPLE"
done

