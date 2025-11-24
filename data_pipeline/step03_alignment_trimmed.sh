#!/bin/bash
# step03_alignment_trimmed.sh - 使用修剪后数据进行比对

REF="/data/share/liuyuxin_tanrenjie/ICR96/technology/hg19.fa"
PAIRS_FILE="/data/share/liuyuxin_tanrenjie/ICR96/Database/pairs.tsv"
OUTPUT_DIR="/data/renweijie/ICR96/OFF-PEAK-std"
TRIMMED_DIR="$OUTPUT_DIR/step02_trimmed_fastq"
THREADS=8

mkdir -p $OUTPUT_DIR/step03_alignment_bams

echo "开始序列比对..."

# 处理每个样本
tail -n +2 $PAIRS_FILE | while IFS=$'\t' read -r SAMPLE R1 R2; do
    echo "处理: $SAMPLE"
    
    R1_TRIMMED="$TRIMMED_DIR/${SAMPLE}_R1_trimmed.fastq.gz"
    R2_TRIMMED="$TRIMMED_DIR/${SAMPLE}_R2_trimmed.fastq.gz"
    
    # 比对 + 排序 → 直接得到排序后的BAM
   bwa mem -t $THREADS \
    -R "@RG\tID:${SAMPLE}\tSM:${SAMPLE}\tPL:ILLUMINA" \
    $REF $R1_TRIMMED $R2_TRIMMED 2>/dev/null | \
  samtools sort -@ $THREADS -o $OUTPUT_DIR/step03_alignment_bams/${SAMPLE}_sorted.bam -
    
    # 创建索引
    samtools index $OUTPUT_DIR/step03_alignment_bams/${SAMPLE}_sorted.bam
    
    echo "完成: $SAMPLE"
done

echo "比对完成！"

