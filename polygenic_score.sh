#!/bin/bash

cd sbayesr
module load gctb/2.04.3-gcc-13.2.0

for j in $(cat sumstats_list.txt); do
gctb --sbayes R \
--ldm ukbEURu_imp_v3_HM3_n50k.chisq10.ldm.sparse \
--pi 0.95,0.02,0.02,0.01 \
--gamma 0.0,0.01,0.1,1 \
--gwas-summary ${j}_COJO.txt \
--exclude-mhc \
--chain-length 10000 \
--burn-in 2000 \
--out sbayesr_${j} \
--impute-n \
--robust 
done 

# calculate polygenic scores
module load plink2/2.00a5.10-gcc-13.2.0

for i in {1..22} X; do
for j in $(cat sumstats_list.txt); do
plink2 --pfile ukb_imp_chr${i} \
--keep UKB.EUR.keep \
--extract ukb_maf1_snp95_hwe10_var_list_chr${i}.txt \
--score sbayesr_${j}.snpRes 2 5 8 header-read no-mean-imputation \
--out ${j}_chr${i} \
--threads 16
done
done 