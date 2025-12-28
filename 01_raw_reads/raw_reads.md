# Work flow

## 1. Copy raw reads 
    Copy raw reads .fastaq.gz from this path /data/wgs_assembly/hybrid_genome_assembly_guide/raw_reads/short_reads and then create a new dir here ./ called 00_raw_reads

## 2. Create the following directories ./:
    - 01_qc_before_processing
    - 02_process_reads
    - 03_qc_after_processing

## Setup

Run the setup script to create directories and copy raw reads

```bash
chmod +x setup_directories.sh
./setup_directories.sh
```

## Directories Structure
- `00_raw_reads/` - Raw short reads (.fastq.gz)
- `01_qc_before_processing/` - QC result before processing
- `02_process_reads/` - Processed/trimmed reads
- `03_qc_after_processing/` - QC results after processing