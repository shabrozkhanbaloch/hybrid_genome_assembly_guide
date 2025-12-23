# Whole Genome Sequence and Assembly

## Overview
## Workflow
### 1. Raw Reads

I will use grabseqs to download raw reads

#### 1.1. Installtion

```bash
# install grabseqs
conda create -n grabseqs -y
conda activate grabseqs

conda install grabseqs -c louiejtaylor -c bioconda -c conda-forge
conda install grabseqs -c louiejtaylor -c bioconda -c conda-forge 
```

#### 1.2. Download Raw reads

```bash
conda activate grabseqs
# to download a sequence illumina run
grabseqs sra -t 4 -m metadata.csv -o ./01_raw_reads/short_reads -r 4 SRR8893090

# first run of nanopore reads
grabseqs sra -t 4 -m metadata.csv -o ./01_raw_reads/long_reads -r 4 SRR8893087

# Second run of nanopore reads
grabseqs sra -t 4 -m metadata.csv -o ./01_raw_reads/long_reads -r 4 SRR8893086

# pacbioreads
grabseqs sra -t 4 -m metadata.csv -o ./01_raw_reads/long_reads -r 4 SRR8893091
```
