# vim: syntax=python tabstop=2 expandtab
# coding: utf-8
#------------------------------------------------------------------------------
# Snakemake rules to perform variant calling steps.
#------------------------------------------------------------------------------
# author   : Harald Detering
# email    : harald.detering@gmail.com
# modified : 2023-06-27
#------------------------------------------------------------------------------

rule gatk_haplotypecaller:
  input:
    bam = '../results/{prefix}.recal.bam',
    ref = config['ref-fasta-path'],
    reg = config['target-regions']
  output:
    '../results/{prefix}.recal.vcf'
  log:
    '../log/{prefix}.gatk_haplotypecaller.log'
  benchmark:
    '../log/{prefix}.gatk_haplotypecaller.perf'
  conda:
    '../envs/gatk.yaml'
  shell:
    '''
    gatk HaplotypeCaller \
      -R {input.ref} \
      -I {input.bam} \
      -L {input.reg} \
      -O {output} \
    >{log} 2>&1
    '''

rule eval:
  input:
    var = '../results/{sample}.recal.vcf',
    tru = '../data/ground_truth.vcf',
    bed = '../data/target_regions.bed'
  output:
    '../results/{sample}.eval.csv'
  log:
    '../log/{sample}.eval.log'
  benchmark:
    '../log/{sample}.eval.perf'
  conda:
    '../envs/bedtools.yaml'
  shell:
    '(bash scripts/eval_vars.sh > {output}) >{log} 2>&1'

