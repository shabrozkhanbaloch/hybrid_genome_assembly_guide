# Hybrid Genome Assembly & Annotation Pipeline  
**Illumina short reads + Oxford Nanopore long reads**

---

## Overview

This repository contains a **complete, reproducible hybrid genome assembly pipeline** for bacterial whole-genome sequencing (WGS) data using **Illumina short reads** and **Oxford Nanopore long reads**.

The workflow is modular, script-based, and designed for **research-grade, and publication-ready analyses**.

The pipeline covers:

- Read quality control and preprocessing  
- Short-read, long-read, and hybrid genome assembly  
- Genome quality assessment  
- Genome annotation  
- Plasmid reconstruction  
- Antimicrobial resistance (AMR) gene detection  
- Viral and prophage detection  

---

## Directory Structure

Script:
`00_make_directories.sh`


```text
hybrid_genome_assembly_guide/
├── 00_papers/                     # Reference papers
├── 01_raw_reads/
│   ├── short_reads/
│   └── long_reads/
├── 02_qc_before_processing/
├── 03_processed_reads/
├── 04_qc_after_processing/
├── 05_genome_assembly/
│   ├── 01_short_only/
│   ├── 02_long_only/
│   └── 03_hybrid/
├── 06_genome_quality_assessment/
│   ├── checkm2/
│   ├── quast/
│   └── busco/
├── 07_genome_annotation/
│   ├── prokka/
│   └── bakta/
├── 08_plassembler/
├── 09_abricate/
│   ├── assembly_level/
│   └── plasmid_level/
├── 10_genomad/
│   ├── assembly_level/
│   └── plasmidid_level/
├── installation.sh
└── README.md

```
---



# Pipeline Workflow

### 1. Raw Read Setup
- Validates exactly **one Illumina paired-end sample**
- Validates **one Nanopore long-read FASTQ**
- Standardizes file naming

Script:
`01_setup_raw_reads.sh`

---
### 2. Quality Control (Before Processing)
- Illumina reads: FastQC + MultiQC
- Nanopore reads: NanoPlot

Script:
`02_qc_reads_before_processing.sh`

---

### 3. Read Processing
- Short reads: adapter trimming and quality filtering (fastp)
- Long reads: length and quality filtering (NanoFilt)

Script:
`03_process_reads.sh`

---

### 4. Genome Assembly
Three assemblies are generated using **Unicycler**:
- Short-read only
- Long-read only
- Hybrid (short + long)

Script:
`04_genome_assembly.sh`

---

### Step 5 – Genome Quality Assessment
Performed independently for all three assemblies:
- **CheckM2** – completeness and contamination
- **QUAST** – assembly statistics
- **BUSCO** – conserved single-copy orthologs
Script:
`05_genome_quality_assessment.sh`

---

### Step 6 – Genome Annotation
Functional annotation using:
- **Prokka**
- **Bakta**

Applied to:
- Short-only assembly
- Long-only assembly
- Hybrid assembly

Script:

`06_genome_annotation.sh`

---

### Step 7 – Plasmid Reconstruction
Plasmids are reconstructed using **Plassembler**, integrating
short- and long-read data.

Script:
`07_plassembler.sh`



## Key output:

---

### Step 8 – Antimicrobial Resistance Detection
AMR genes are detected using **Abricate** at two levels:

- **Assembly-level**  
  Input: Hybrid genome assembly  
  (chromosome + integrated plasmid contigs)

- **Plasmid-level**  
  Input: Plassembler plasmid FASTA only

Databases used:
- NCBI
- ResFinder
- CARD
- VFDB

Script:
`08_abricate.sh`


---

### Step 9 – Viral and Prophage Detection
Detection of viruses, prophages, and mobile genetic elements using **geNomad**.

Analyses performed at:
- Assembly-level (hybrid genome)
- Plasmid-level (Plassembler output)

Script:
`09_genomad.sh`


---

## Running the Complete Pipeline

All steps can be executed automatically using:

Script:
`./run_pipeline.sh`


The pipeline stops immediately if any step fails.

---

## Key Output Files

| Analysis | File |
|--------|------|
| Hybrid genome | `05_genome_assembly/03_hybrid/assembly.fasta` |
| Plasmid sequences | `08_plassembler/plassembler_plasmids.fasta` |
| AMR summary (genome) | `09_abricate/assembly_level/abricate_assembly_summary.tsv` |
| AMR summary (plasmids) | `09_abricate/plasmid_level/abricate_plasmid_summary.tsv` |
| Viral/prophage results | `10_genomad/*/summary` |

---
## Version Control & Reproducibility

This repository follows best practices for reproducible bioinformatics pipelines.

- **Raw data, intermediate files, and large result files are NOT tracked in Git**
- Only:
  - scripts
  - directory structure
  - lightweight summary files
are committed.

All heavy outputs (assemblies, BAMs, depth files, plots, HTML dashboards)
are generated locally after running the pipeline.

This ensures:
- GitHub size limits are respected
- Clean version history
- Fully reproducible analyses


## Intended Use

- Bacterial WGS analysis
- Research 
- Publication-ready workflows

---


## Software Installation

All tools are installed via Conda using the provided `installation.sh` script.
The pipeline has been tested on Linux systems.

The following Conda environments are created:

- Short-read QC: FastQC, fastp
- Long-read QC: NanoPlot, NanoFilt, Filtlong
- Assembly: Unicycler
- Genome quality assessment: CheckM2, QUAST, BUSCO
- Genome annotation: Prokka, Bakta
- Plasmid reconstruction: Plassembler
- AMR & virulence profiling: Abricate
- Prophage and mobile element detection: geNomad

All required reference databases (CheckM2, BUSCO, Bakta, Plassembler, geNomad) are downloaded automatically.

---

## Acknowledgements

This pipeline was developed with significant guidance, training, and conceptual support from **Codanics**.

Special thanks to:

**Dr. Muhammad Aammar Tufail**  
Founder & Lead Instructor, Codanics  


---

## Software Citations

If you use this pipeline or its components, please cite the following tools appropriately:

- **Unicycler**  
  Wick RR et al. (2017). *Unicycler: Resolving bacterial genome assemblies from short and long sequencing reads*.  
  PLOS Computational Biology 13(6): e1005595.

- **Plassembler**  
  Bouras G et al. (2023). *Plassembler: A hybrid assembly pipeline for accurate plasmid reconstruction*.  
  Microbial Genomics.

- **CheckM2**  
  Chklovski A et al. (2023). *CheckM2: a rapid, scalable and accurate tool for assessing microbial genome quality*.  
  Nature Methods.

- **QUAST**  
  Gurevich A et al. (2013). *QUAST: quality assessment tool for genome assemblies*.  
  Bioinformatics 29(8): 1072–1075.

- **BUSCO**  
  Manni M et al. (2021). *BUSCO Update: from single-copy orthologs to gene markers*.  
  Molecular Biology and Evolution.

- **Prokka**  
  Seemann T. (2014). *Prokka: rapid prokaryotic genome annotation*.  
  Bioinformatics 30(14): 2068–2069.

- **Bakta**  
  Schwengers O et al. (2021). *Bakta: rapid and standardized annotation of bacterial genomes*.  
  Nucleic Acids Research.

- **Abricate**  
  Seemann T.  
  https://github.com/tseemann/abricate

- **geNomad**  
  Camargo AP et al. (2023). *geNomad: identification of mobile genetic elements*.  
  Nature Biotechnology.

---

## Citation of This Pipeline

If you use or adapt this pipeline, please cite it as:

> Hybrid Genome Assembly and Analysis Pipeline  
> Illumina + Oxford Nanopore sequencing  
> Developed with training support from Codanics.
