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



## 🔑 Core Design Principle (IMPORTANT)

The pipeline NEVER owns raw sequencing data.
Raw data lives in a central sequencing data directory and is linked to each project using symlinks.

### This makes the pipeline:

reusable across multiple projects

safe to clean/reset

GitHub-friendly

## Sequencing Data Layout (External to Pipeline)
Raw sequencing data is stored outside the pipeline repository, for example:
```
/data/sequencing_data/
└── project_02/
    ├── short_reads_clean/
    │   ├── ERR4824536_1.fastq.gz
    │   └── ERR4824536_2.fastq.gz
    └── long_reads/
        └── ERR4824536_long.fastq.gz
```
This directory is never deleted or modified by the pipeline
## Per-Project Directory Structure

### Created using:
00_make_directories.sh
- This directory is never deleted or modified by the pipeline
```
PROJECTS/paper_02/
├── data/
│   ├── short_reads -> /data/sequencing_data/project_02/short_reads_clean
│   └── long_reads  -> /data/sequencing_data/project_02/long_reads
├── results/
│   ├── qc_before/
│   ├── processed_reads/
│   ├── qc_after/
│   ├── assembly/
│   │   ├── 01_short_only/
│   │   ├── 02_long_only/
│   │   └── 03_hybrid/
│   ├── quality/
│   │   ├── checkm2/
│   │   ├── quast/
│   │   └── busco/
│   ├── annotation/
│   │   ├── prokka/
│   │   └── bakta/
│   ├── plasmids/
│   ├── amr/
│   │   ├── assembly_level/
│   │   └── plasmid_level/
│   └── prophage/
│       ├── assembly_level/
│       └── plasmid_level/
└── figures/


```
---



### 🔬 Pipeline Workflow
Step 1 – Raw Read Validation

Confirms exactly one Illumina paired-end sample

Confirms exactly one Oxford Nanopore long-read FASTQ

READ-ONLY check (no files are modified)

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
`bash run_pipeline.sh /path/to/PROJECT_DIR`



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

## Performance Notes

Tested on:
- Lenovo ThinkPad T15g Gen 2
- 16 CPU threads
- 128 GB RAM

Typical runtime (bacterial genome):
- ~1–1.5 hours end-to-end
(depending on read depth and long-read size)


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
# 🚀 Quick Start (5-Minute Setup)

Follow these steps to run the complete hybrid genome assembly pipeline from raw FASTQ files to publication-ready results.

## Step 1 – Clone the Repository
https://github.com/shabrozkhanbaloch/hybrid_genome_assembly_guide.git

## Step 2 – Prepare Sequencing Data (Outside the Pipeline)

Raw sequencing data must exist outside the pipeline repository.

### Example layout:
```
/data/sequencing_data/project_02/
├── short_reads_clean/
│   ├── SAMPLE_1.fastq.gz
│   └── SAMPLE_2.fastq.gz
└── long_reads/
    └── SAMPLE_long.fastq.gz

```
## 📌 Important

One Illumina paired-end sample per project

One Nanopore long-read FASTQ per project

Files must be compressed (.fastq.gz)

## Step 3 – Create a New Project
`mkdir -p /data/wgs_assembly/PROJECTS/paper_02
bash 00_make_directories.sh /data/wgs_assembly/PROJECTS/paper_02`

## Step 4 – Link Sequencing Data (Using Symlinks)
`ln -s /data/sequencing_data/project_02/short_reads_clean \
      /data/wgs_assembly/PROJECTS/paper_02/data/short_reads`

`ln -s /data/sequencing_data/project_02/long_reads \
      /data/wgs_assembly/PROJECTS/paper_02/data/long_reads`


## 🔒 Why symlinks?

Raw data is never copied or modified

Multiple projects can reuse the same sequencing data

Safe cleanup and reproducibility

## Step 5 – Preflight Check (REQUIRED)
`bash preflight_check.sh /data/wgs_assembly/PROJECTS/paper_02`


## Expected output:

✅ PRE-FLIGHT CHECK PASSED
🚀 Safe to run pipeline

## Step 6 – Run the Complete Pipeline
`bash run_pipeline.sh /data/wgs_assembly/PROJECTS/paper_02`


## The pipeline:

Executes all steps sequentially

Stops immediately if an error occurs

Produces fully reproducible results

## Optional – Cleanup & Re-Run

To remove heavy intermediate files while keeping final outputs:

`bash cleanup_project.sh /data/wgs_assembly/PROJECTS/paper_02`

⚠️ Important Rules

❌ Never copy FASTQ files into the pipeline repository

✅ Always use symlinks for raw sequencing data

✅ Results can be safely deleted and regenerated

⚠️ One sample per project directory (by design)

🎯 Done.

From raw FASTQ files to publication-ready assemblies in a single command.
# 📊 Automated Plots & Figures

This pipeline automatically generates publication-ready figures directly from analysis results.
All plots are fully reproducible, script-generated, and require no manual intervention.

Figures are created after genome assembly and quality assessment steps and are designed for direct inclusion in manuscripts.

## 📈 Implemented Figures

The pipeline currently generates the following types of plots:

Assembly Quality Comparison

Completeness vs contamination (CheckM2)

Comparison across:

Short-read assembly

Long-read assembly

Hybrid assembly

Read Coverage Analysis

Short reads mapped to short-only assembly

Short reads mapped to hybrid assembly

Long reads mapped to hybrid assembly

Quality Summary Visualizations

Aggregated QC metrics

Assembly-level comparisons suitable for figures and supplements

## 📁 Figure Output Location

All figures are saved in the project-specific figures/ directory:
```
PROJECTS/paper_02/
└── figures/
    ├── Figure1_CheckM2_Completeness_Contamination.png
    ├── Figure2_Coverage_Distribution.png
    ├── Figure3_Assembly_Statistics.png
    └── ...
```
🔁 Reproducibility of Figures

Figures are generated only from pipeline output files

No manual plotting or post-processing is required

Figures can be safely deleted and regenerated at any time
# ⚙️ Generating & Cleaning Figures (One-Go)

This pipeline provides fully automated figure generation.
All plots can be generated or regenerated using single commands, without any manual steps.

## ▶️ Generate All Figures (One Command)

To generate all plots at once from existing pipeline results:

`bash run_plots.sh /path/to/PROJECT_DIR`


This script:

reads finalized analysis outputs (assemblies, QC metrics, coverage results)

generates all publication-ready plots

saves them in the project figures/ directory

📁 Output:
```
PROJECTS/paper_02/
└── figures/
    ├── Figure1_CheckM2_Completeness_Contamination.png
    ├── Figure2_Coverage_Distribution.png
    ├── Figure3_Assembly_Statistics.png
    └── ...
```
## 🧹 Clean All Figures (Safe)

To remove all generated plots while keeping analysis results intact:

`bash cleanup_plots.sh /path/to/PROJECT_DIR`


This:

deletes only files inside figures/

does not touch raw data or results

is safe to run multiple times

## 🔁 Clean & Regenerate Figures (Recommended)

To fully regenerate plots from scratch:

`bash cleanup_plots.sh /path/to/PROJECT_DIR`
`bash run_plots.sh /path/to/PROJECT_DIR`

🔐 Safety Guarantees

❌ Raw sequencing data is never modified

❌ Analysis results are never deleted

✅ Only figure files are removed/regenerated

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
