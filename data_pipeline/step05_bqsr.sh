#!/bin/bash
# step05_bqsr.sh - 碱基质量重校准

REF="/data/share/liuyuxin_tanrenjie/ICR96/technology/hg19.fa"
PAIRS_FILE="/data/share/liuyuxin_tanrenjie/ICR96/Database/pairs.tsv"
OUTPUT_DIR="/data/renweijie/ICR96/OFF-PEAK-std"
THREADS=4

# 使用现有的已知位点文件
DBSNP="/data/share/liuyuxin_tanrenjie/ICR96/OFF-PEAK_bam/resources/chr/dbsnp_138.hg19.vcf.gz"
KNOWN_INDELS="/data/share/liuyuxin_tanrenjie/ICR96/OFF-PEAK_bam/resources/chr/Mills_and_1000G_gold_standard.indels.hg19.sites.vcf.gz"

mkdir -p $OUTPUT_DIR/step05_bqsr_bams
mkdir -p $OUTPUT_DIR/step05_bqsr_reports

echo "开始碱基质量重校准..."

tail -n +2 $PAIRS_FILE | \
parallel --colsep '\t' -j $THREADS --progress "
    echo 'BQSR处理: {1}'
    
    # 生成重校准表
    gatk BaseRecalibrator \
        -I $OUTPUT_DIR/step04_marked_bams/{1}_marked.bam \
        -R $REF \
        --known-sites $DBSNP \
        --known-sites $KNOWN_INDELS \
        -O $OUTPUT_DIR/step05_bqsr_reports/{1}_recal_data.table
    
    # 应用重校准
    gatk ApplyBQSR \
        -I $OUTPUT_DIR/step04_marked_bams/{1}_marked.bam \
        -R $REF \
        --bqsr-recal-file $OUTPUT_DIR/step05_bqsr_reports/{1}_recal_data.table \
        -O $OUTPUT_DIR/step05_bqsr_bams/{1}_bqsr.bam \
        --create-output-bam-index true
    
    echo '完成: {1}'
"

echo "BQSR完成！"
