#!/bin/bash

# LDSC
cd ldsc
for i in $(cat phenotype_list.txt); do
munge_sumstats.py \
--sumstats ${i}_ldsc.txt \
--out ${i} \
--merge-alleles eur_w_ld_chr/w_hm3.snplist \
--chunksize 500000

ldsc.py \
--h2 ${i}.sumstats.gz \
--ref-ld-chr eur_w_ld_chr/ \
--w-ld-chr eur_w_ld_chr/ \
--out heritability/h2_${i}
done

# GCTA
# making a GRM using 30 subsets of the UKB file
cd gcta
MBFILE="chromosomes.txt"
for i in $(seq 1 30); do
gcta \
--mpfile $MBFILE \
--maf 0.01 \
--keep  ad_clean_forgwas.txt \
--make-grm-part 30 ${i} \
--out gcta \
--threads 32
done

# concatenate the different subsets
cat gcta.part_30_*.grm.id > ad_GCTA.grm.id
cat gcta.part_30_*.grm.bin > ad_GCTA.grm.bin
cat gcta.part_30_*.grm.N.bin > ad_GCTA.grm.N.bin

# remove the subsets
rm gcta.part_30_*

# adjust GRM for incomplete tagging of causal SNPs 
gcta \
--grm ad_GCTA \
--grm-adj 0 \
--make-grm \
--out ad_GCTA.adjusted

## Remove related subjects
gcta \
--grm ad_GCTA.adjusted \
--grm-cutoff 0.125 \
--make-grm \
--out ad_GCTA.adjusted.unrel

# remove previous data:
rm ad_GCTA.grm.*

# Run GREML-SC:
# non-binary phenotypes:
for i in $(cat phenotype_list_nonbinary.txt); do
gcta \
--grm ad_GCTA.adjusted.unrel \
--reml \
--reml-no-constrain \
--pheno ${i}_gcta.txt \
--mpheno 1 \
--covar covariates_cat.txt \
--qcovar covariates_con.txt \
--out ad.adjusted.unrel.GREML_${i} \
--threads 32
done

# binary phenotypes:
for i in $(cat phenotype_list_binary.txt); do
PREV=$(awk '{ones += ($3 == 1); total++} END {print ones / total}' ${i}_gcta.txt)
gcta \
--grm ad_GCTA.adjusted.unrel \
--reml \
--reml-no-constrain \
--pheno ${i}_gcta.txt \
--mpheno 1 \
--covar covariates_cat.txt \
--qcovar covariates_con.txt \
--out ad.adjusted.unrel.GREML_${i} \
--prevalence ${PREV} \
--threads 32 
done