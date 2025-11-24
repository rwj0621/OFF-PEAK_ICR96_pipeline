#!/bin/bash
# step01_fastqc.sh - ICR96数据质控脚本

# 设置工作目录
DATABASE_DIR="/data/share/liuyuxin_tanrenjie/ICR96/Database"
OUTPUT_DIR="/data/renweijie/ICR96/OFF-PEAK-std/reports/fastqc_raw"

# 创建输出目录
mkdir -p $OUTPUT_DIR

# 查找所有fastq文件并运行FastQC
find $DATABASE_DIR -name "*.fastq.gz" -type f | \
xargs -I {} -P 4 fastqc {} -o $OUTPUT_DIR

# 运行MultiQC汇总报告
multiqc $OUTPUT_DIR -o $OUTPUT_DIR/../multiqc_report

