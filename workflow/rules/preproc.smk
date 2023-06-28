# vim: syntax=python tabstop=2 expandtab
# coding: utf-8
#------------------------------------------------------------------------------
# Snakemake rules to perform preprocessing steps.
#------------------------------------------------------------------------------
# author   : Harald Detering
# email    : harald.detering@gmail.com
# modified : 2023-06-24
#------------------------------------------------------------------------------

rule mark_duplicates:
  input:
    '../result/{prefix}.bam'
  output:
    '../results/{prefix}.markdup.bam'
  log:
    '../log/mark_duplicates.log'
  benchmark:
    '../log/mark_duplicates.perf'
  conda:
    '../envs/gatk.yaml'
  shell:
    'java -jar picard.jar I={input} O={output} M={output}.metrics.txt >{log} 2>&1'
