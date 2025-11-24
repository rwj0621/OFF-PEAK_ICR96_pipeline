# 一、环境创建
## 创建环境
    conda create -n ICR96-OFF-PEAK python=3.9 -y
## 激活环境
    conda activate ICR96-OFF-PEAK
# 二、工具安装
## OFF-PEAK工具列表
* BEDTools [Link] (>= v2.25.0)
  
        conda install -c bioconda bedtools=2.30.0 -y 
* mosdepth [Link] (>= v0.3.3)
  
        conda install -c bioconda mosdepth=0.3.3 -y
* R [Link] (>= v3.2.0) with following libraries: optparse, gplots, ExomeDepth, pROC and caTools
  
        conda install -c conda-forge r-base=4.1.0 -y 
        conda install -c conda-forge r-optparse r-gplots r-proc r-catools -y
        conda install -c bioconda r-exomedepth -y
## 序列比对工具列表
* 质量评估与修建
  
        conda install -c bioconda fastqc multiqc -y
        conda install -c bioconda trimmomatic -y
* 处理BAM文件必需
  
        conda install -c bioconda samtools=1.12 -y 
* 序列比对 BWA (v.0.7.17)
  
        conda install -c bioconda bwa=0.7.17 -y 
* 标记重复序列 Picard (v.2.14.0-SNAPSHOT)
  
        conda install -c bioconda picard=2.26.0 -y  
* 碱基质量重校准 GATK (v.4.1.4.1)
  
        conda install -c bioconda gatk4=4.1.4.1 -y
# 三、原始数据处理pipeline
* 数据质控 [step01_fastqc.sh](https://github.com/rwj0621/OFF-PEAK_ICR96_pipeline/blob/main/data_pipeline/step01_fastqc.sh)
* 修剪 [step02_trimming.sh](https://github.com/rwj0621/OFF-PEAK_ICR96_pipeline/blob/main/data_pipeline/step02_trimming.sh)
* 序列比对 [step03_alignment_trimmed.sh](https://github.com/rwj0621/OFF-PEAK_ICR96_pipeline/blob/main/data_pipeline/step03_alignment_trimmed.sh)
* 标记重复  [step04_mark_duplicates.sh](https://github.com/rwj0621/OFF-PEAK_ICR96_pipeline/blob/main/data_pipeline/step04_mark_duplicates.sh)
* 碱基质量重新校对  [step05_bqsr.sh](https://github.com/rwj0621/OFF-PEAK_ICR96_pipeline/blob/main/data_pipeline/step05_bqsr.sh)
# 四、[OFF-PEAK](https://github.com/mquinodo/OFF-PEAK)  pipeline
* 01_targets-processing.sh

        bash 01_targets-processing.sh \
          --genome hg19 \
          --targets /data/renweijie/data/TSCP-target-BED.bed \
          --name ICR96_std_panel \
          --ref /data/share/liuyuxin_tanrenjie/ICR96/technology/hg19.fa 
* 02_coverage-count.sh

        #自动生成并排序两列的list_BAM.txt文件
        find /data/renweijie/ICR96/OFF-PEAK-std/step05_bqsr_bams -name "*_bqsr.bam" | sort | while read bam; do
        sample_id=$(basename "$bam" | sed 's/_bqsr.bam//')
        echo -e "$bam\t$sample_id"
        done > list_BAM.txt

        nohup bash /data/renweijie/ICR96/tools/OFF-PEAK-main/02_coverage-count.sh \
          --listBAM /data/renweijie/ICR96/OFF-PEAK-std/step05_bqsr_bams/list_BAM.txt \
          --mosdepth /data/renweijie/anaconda3/envs/ICR96-OFF-PEAK/bin/mosdepth \
          --work /data/renweijie/ICR96/OFF-PEAK-std/ICR96-OFFPEAK-results/coverage1 \
          --targetsBED /data/renweijie/ICR96/tools/OFF-PEAK-main/data/ICR96_std_panel1.bed > coverage1.log 2>&1 &
* 03_OFF-PEAK.R

        nohup Rscript /data/renweijie/ICR96/tools/OFF-PEAK-main/03_OFF-PEAK.R \
          --output /data/renweijie/ICR96/OFF-PEAK-std/ICR96-OFFPEAK-results/cnv_results_50k \
          --data /data/renweijie/ICR96/OFF-PEAK-std/ICR96-OFFPEAK-results/coverage/ALL.target.tsv \
          --databasefile /data/renweijie/ICR96/tools/OFF-PEAK-main/data/data-hg19.RData \
          --chromosome-plots \
          --genome-plots \
          --nb-plots 20 > cnv_analysis_50k.log 2>&1 &
