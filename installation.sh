
# install grabseqs
conda create -n grabseqs -y
conda activate grabseqs

conda install grabseqs -c louiejtaylor -c bioconda -c conda-forge
conda install grabseqs -c louiejtaylor -c bioconda -c conda-forge


# srr file with -t

grabseqs sra -t 16 -m metadata.csv -o ./01_raw_reads/short_reads -r 4 SRR8893090
grabseqs sra -t 16 -m metadata.csv -o ./01_raw_reads/long_reads -r 4 SRR8893087
grabseqs sra -t 16 -m metadata.csv -o ./01_raw_reads/long_reads -r 4 SRR8893086
grabseqs sra -t 16 -m metadata.csv -o ./01_raw_reads/long_reads -r 4 SRR8893091