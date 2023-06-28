# SG variant calling assignment

All steps are implemented as a Snakemake workflow.

## Dependencies

- conda (e.g. [mambaforge](https://github.com/conda-forge/miniforge#mambaforge))
- [snakemake](https://github.com/snakemake/snakemake)
- [gsutil](https://cloud.google.com/storage/docs/gsutil)
- [bedtools](https://github.com/arq5x/bedtools2)
- [bioawk](https://github.com/lh3/bioawk)

All dependencies to run the workflow can be installed using the following steps:

```
# Install mambaforge if no existing *conda installation
# (on Linux, adapt commands if you are on a different OS)
wget https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-Linux-x86_64.sh
bash ./Mambaforge-Linux-x86_64.sh
# When asked “Do you want to installer to initialize Miniconda by running conda init” then type “yes”

# Install workflow dependencies
conda env create -n sg-varcall-assignment -f workflow/env/snakemake.yaml
conda activate sg-varcall-assignment
```

## Running the workflow

To run the variant calling pipeline, all necessary data files must be placed in a folder `data`, parallel to the `workflow`folder. You're all set to go when your working directory looks like this:

```
├── data
│   ├── sample_control_R1.fastq.gz
│   ├── sample_control_R2.fastq.gz
│   └── target_regions.bed
└── workflow
    ├── config
    │   └── config.yaml
    ├── envs
    │   ├── bedtools.yaml
    │   ├── bwa.yaml
    │   ├── fastqc.yaml
    │   ├── gatk.yaml
    │   ├── picard.yaml
    │   ├── samtools.yaml
    │   └── snakemake.yaml
    ├── rules
    │   ├── map.smk
    │   ├── preproc.smk
    │   ├── qc.smk
    │   └── varcall.smk
    ├── scripts
    │   ├── eval_vars.sh
    │   ├── expand_reads.bioawk
    │   └── expand_reads.sh
    └── Snakefile
```

Then, the whole workflow can be started:

```
cd workflow
snakemake -j1 --use-conda ../results/sample_control.recal.vcf
```

The resulting VCF must be called <sample_x>.recal.vcf, and the sequencing reads must be in `data/<sample_x_R1.fastq.gz` and `data/<sample_x>_R2.fastq.gz`.
