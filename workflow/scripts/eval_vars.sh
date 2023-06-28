#!/bin/bash
# vim: syntax=python tabstop=2 expandtab
# coding: utf-8
#------------------------------------------------------------------------------
# Calculate performance stats comparing ground truth to variant calls.
#------------------------------------------------------------------------------
# author   : Harald Detering
# email    : harald.detering@gmail.com
# modified : 2023-06-27
#------------------------------------------------------------------------------

vcf_truth='../data/ground_truth.vcf'
vcf_calls='../results/sample_control.recal.vcf'
bed_regions='../data/target_regions.bed'

# tally base metrics
all=$(cat $bed_regions | awk '{s+=$3-$2}END{print s}')
tp=$(bedtools intersect -a $vcf_truth -b $vcf_calls | wc -l)
fn=$(bedtools intersect -a $vcf_truth -b $vcf_calls -v | wc -l)
fp=$(bedtools intersect -b $vcf_truth -a $vcf_calls -v | wc -l)
let "tn = $all - $fp"


printf "TP,%d\n" $tp
printf "FP,%d\n" $fp
printf "TN,%d\n" $tn
printf "FN,%d\n" $fn
