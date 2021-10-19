HG38_FA=/home/public/igenomic_38/Sequence/WholeGenomeFasta/genome.fa
digest_genome=/home/chenjun/software/bio_tools/HiC-Pro_3.0.0/bin/utils/digest_genome.py

$digest_genome -r N^GATC -o /home/chenjun/software/bio_tools/HiC-Pro_3.0.0/annotation/hg38_dpnii.bed $HG38_FA

$digest_genome -r N^GATC G^ANTC -o /home/chenjun/software/bio_tools/HiC-Pro_3.0.0/annotation/hg38_arima.bed $HG38_FA

## 2021-7-6 make hindiii.bed
echo "$digest_genome -r A^AGCTT -o /home/chenjun/software/bio_tools/HiC-Pro_3.0.0/annotation/hg38_hindiii.bed $HG38_FA" > hindiii.sh
