#!/bin/bash
# vim: syntax=sh tabstop=2 expandtab
# coding: utf-8
#------------------------------------------------------------------------------
# Script to duplicate each read in a sequencing experiment.
# Adds an "A" to read ID.
#------------------------------------------------------------------------------
# author   : Harald Detering
# email    : harald.detering@gmail.com
# modified : 2023-06-28
#------------------------------------------------------------------------------

scripts="workflow/scripts"
pfx_orig="data/sample_control"
pfx_dupl="data/sample_expanded"

# Duplicate FW reads
zcat ${pfx_orig}_R1.fastq.gz | bioawk -c fastx -f $scripts/expand_reads.bioawk \
| gzip -c > ${pfx_dupl}_R1.fastq.gz

# Duplicate RV reads
zcat ${pfx_orig}_R2.fastq.gz | bioawk -c fastx -f $scripts/expand_reads.bioawk \
| gzip -c > ${pfx_dupl}_R2.fastq.gz
