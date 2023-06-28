# vim: syntax=python tabstop=2 expandtab
# coding: utf-8
#------------------------------------------------------------------------------
# Snakemake rules to perform quality control steps.
#------------------------------------------------------------------------------
# author   : Harald Detering
# email    : harald.detering@gmail.com
# modified : 2023-06-24
#------------------------------------------------------------------------------

rule fastqc:
  input:
    fq1 = '../data/{sample}_R1.fastq.gz',
    fq2 = '../data/{sample}_R2.fastq.gz'
  output:
    '../results/fastqc/{sample}_R1_fastqc.html',
    '../results/fastqc/{sample}_R2_fastqc.html'
  params:
    out_dir = '../results/fastqc'
  log:
    '../log/{sample}.fastqc.log'
  benchmark:
    '../log/{sample}.fastqc.perf'
  conda:
    '../envs/fastqc.yaml'
  shell:
    'fastqc --noextract --nogroup -o {params.out_dir} {input.fq1} {input.fq2} >{log} 2>&1'
