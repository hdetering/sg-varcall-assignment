# vim: syntax=python tabstop=2 expandtab
# coding: utf-8
#------------------------------------------------------------------------------
# Snakemake rules to map sequencing reads to human reference genome.
#------------------------------------------------------------------------------
# author   : Harald Detering
# email    : harald.detering@gmail.com
# modified : 2023-06-28
#------------------------------------------------------------------------------

# download reference genome
rule get_reference:
  output:
    fasta = config['ref-fasta-path'],
    dbsnp = config['ref-dbsnp-path'],
    onekg = config['ref-1000g-path'],
    mills = config['ref-mills-path']
  log:
    '../log/get_reference.log'
  benchmark:
    '../log/get_reference.perf'
  params:
    url_fasta = config['ref-fasta-url'],
    url_dbsnp = config['ref-dbsnp-url'],
    url_1000g = config['ref-1000g-url'],
    url_mills = config['ref-mills-url']
  shell:
    '''
    (
    gsutil cp {params.url_fasta} {output.fasta} && \
    gsutil cp {params.url_dbsnp} {output.dbsnp} && \
    gsutil cp {params.url_1000g} {output.onekg} && \
    gsutil cp {params.url_mills} {output.mills}
    ) >{log} 2>&1
    '''

# create dictionary for FASTA file
rule picard_dict:
  input:
    '{prefix}.fasta'
  output:
    '{prefix}.dict'
  log:
    '../log/{prefix}.picard_dict.log'
  benchmark:
    '../log/{prefix}.picard_dict.log'
  conda:
    '../envs/picard.yaml'
  shell:
    'picard CreateSequenceDictionary R={input} O={output} >{log} 2>&1'

# create index for VCF files
rule gatk_indexvcf:
  input:
    '{prefix}.vcf'
  output:
    '{prefix}.vcf.idx'
  log:
    '../log/{prefix}.gatk_indexvcf.log'
  benchmark:
    '../log/{prefix}.gatk_indexvcf.perf'
  conda:
    '../envs/gatk.yaml'
  shell:
    'gatk IndexFeatureFile -I {input} >{log} 2>&1'


# index reference genome
rule bwa_index:
  input:
    config['ref-fasta-path']
  output:
    'temp/bwa_index.done'
  log:
    '../log/bwa_index.log'
  benchmark:
    '../log/bwa_index.perf'
  conda:
    '../envs/bwa.yaml'
  shell:
    'bwa index {input} && samtools faidx {input} && touch {output}'

# map sequencing reads against reference genome
rule bwa_mem:
  input:
    ref = config['ref-fasta-path'],
    idx = 'temp/bwa_index.done',
    fq1 = '../data/{sample}_R1.fastq.gz',
    fq2 = '../data/{sample}_R2.fastq.gz'
  output:
    '../results/{sample}.raw.sam'
  log:
    '../log/{sample}.bwa_mem.log'
  benchmark:
    '../log/{sample}.bwa_mem.perf'
  conda:
    '../envs/bwa.yaml'
  shell:
    '''
    bwa mem -R '@RG\\tID:1\\tSM:{wildcards.sample}\\tPL:illumina\\tPU:Lane1\\tLB:Targeted' \
    {input.ref} {input.fq1} {input.fq2} \
    > {output} 2>{log}
    '''

# sort read mappings by genomic coordinates
rule samtools_sort:
  input:
    '../results/{sample}.raw.sam'
  output:
    bam = '../results/{sample}.sorted.bam',
    idx = '../results/{sample}.sorted.bam.bai'
  log:
    '../log/{sample}.samtools_sort.log'
  benchmark:
    '../log/{sample}.samtools_sort.perf'
  conda:
    '../envs/samtools.yaml'
  shell:
    '(samtools sort -O bam {input} > {output.bam} && samtools index {output.bam}) 2>{log}'

# mark duplicate reads (for later filtering)
rule picard_markdup:
  input:
    '../results/{prefix}.sorted.bam'
  output:
    bam = '../results/{prefix}.markdup.bam',
    mtx = '../results/{prefix}.markdup.metrics.txt'
  log:
    '../log/{prefix}.picard_markdup.log'
  benchmark:
    '../log/{prefix}.picard_markdup.perf'
  conda:
    '../envs/picard.yaml'
  shell:
    'picard MarkDuplicates I={input} O={output.bam} M={output.mtx} >{log} 2>&1'

# calculate BQSR recalibration table
rule gatk_baserecalibrator:
  input:
    bam = '../results/{sample}.markdup.bam',
    ref = config['ref-fasta-path'],
    rix = config['ref-index-path'],
    dbsnp = config['ref-dbsnp-path'],
    onekg = config['ref-1000g-path'],
    mills = config['ref-mills-path'],
    dbsnp_idx = f"{config['ref-dbsnp-path']}.idx",
    onekg_idx = f"{config['ref-1000g-path']}.idx",
    mills_idx = f"{config['ref-mills-path']}.idx"
  output:
    '../results/{sample}.recal.table'
  log:
    '../log/{sample}.gatk_baserecalibrator.log'
  benchmark:
    '../log/{sample}.gatk_baserecalibrator.perf'
  conda:
    '../envs/gatk.yaml'
  shell:
    '''
    gatk BaseRecalibrator -I {input.bam} -R {input.ref} \
      --known-sites {input.dbsnp} \
      --known-sites {input.onekg} \
      --known-sites {input.mills} \
      -O {output} \
    >{log} 2>&1
    '''

# recalibrate base quality scores
rule gatk_applybqsr:
  input:
    ref = config['ref-fasta-path'],
    bam = '../results/{sample}.markdup.bam',
    tab = '../results/{sample}.recal.table'
  output:
    '../results/{sample}.recal.bam'
  log:
    '../log/{sample}.gatk_applybqsr.log'
  benchmark:
    '../log/{sample}.gatk_applybqsr.perf'
  conda:
    '../envs/gatk.yaml'
  shell:
    '''
    gatk ApplyBQSR -I {input.bam} -R {input.ref} \
      --bqsr-recal-file {input.tab} \
      -O {output} \
    >{log} 2>&1
    '''
