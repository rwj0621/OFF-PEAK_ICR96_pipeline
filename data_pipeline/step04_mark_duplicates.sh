#!/bin/bash
# step04_mark_duplicates.sh - 标记重复序列

PAIRS_FILE="/data/share/liuyuxin_tanrenjie/ICR96/Database/pairs.tsv"
OUTPUT_DIR="/data/renweijie/ICR96/OFF-PEAK-std"
PARALLEL_JOBS=3  # 同时运行的样本数

mkdir -p $OUTPUT_DIR/step04_marked_bams
mkdir -p $OUTPUT_DIR/step04_marked_reports

echo "开始标记重复序列（并行：$PARALLEL_JOBS 个任务）..."

# 并行处理函数
process_sample() {
    local SAMPLE=$1
    echo "标记重复: $SAMPLE"
    
    INPUT_BAM="$OUTPUT_DIR/step03_alignment_bams/${SAMPLE}_sorted.bam"
    OUTPUT_BAM="$OUTPUT_DIR/step04_marked_bams/${SAMPLE}_marked.bam"
    
     picard MarkDuplicates  \
        I=$INPUT_BAM \
        O=$OUTPUT_BAM \
        M=$OUTPUT_DIR/step04_marked_reports/${SAMPLE}_duplicate_metrics.txt \
        ASSUME_SORT_ORDER=coordinate \
        CREATE_INDEX=true \
        REMOVE_DUPLICATES=false
    
    echo "完成: $SAMPLE"
}

export -f process_sample
export OUTPUT_DIR

# 使用parallel并行处理
tail -n +2 $PAIRS_FILE | cut -f1 | \
parallel -j $PARALLEL_JOBS "process_sample {}"

echo "重复标记完成！"
