#!/bin/bash

module load regenie

njobs=4

################### non-binary outcomes #############################
for i in $(cat phenotype_list_nonbinary.txt); do

# step 1
base_command="regenie_v3.2.4.gz_x86_64_Linux \
--step 1 \
--covarFile covariates.txt \
--phenoFile ${i}.txt \
--phenoColList ${i} \
--keep UKB.EUR.keep \
--covarColList Batch,Array,PC{1:10},birth_year,drug_first_year,data_provider \
--catCovarList Batch,Array,data_provider \
--maxCatLevels 107 \
--bsize 1000 \
--threads 8 \
--gz"

# stage 1
$base_command \
--bed ukb_maf1_snp99_hwe10_exclMTchr \
--out fit_bin_l0_${i} \
--split-l0 fit_bin_parallel_${i},$njobs

# stage 2
for job in $(seq 1 $njobs); do
    $base_command \
    --bed ukb_maf1_snp99_hwe10_exclMTchr \
    --out fit_bin_l0_${i}_$job \
    --run-l0 fit_bin_parallel_${i}.master,$job
done

# stage 3
$base_command \
--bed ukb_maf1_snp99_hwe10_exclMTchr \
--out fit_bin_l1_${i} \
--run-l1 fit_bin_parallel_${i}.master \
--keep-l0

# step 2
for j in $(seq 1 22); do
regenie_v3.2.4.gz_x86_64_Linux \
--step 2 \
--bgen ukb_imp_chr${j} \
--sample ukb_chr1.sample \
--extract ukb_maf1_snp95_hwe10_var_list_chr${j}.txt \
--covarFile covariates.txt \
--phenoFile ${i}.txt \
--phenoColList ${i} \
--covarColList Batch,Array,PC{1:10},birth_year,drug_first_year,data_provider \
--catCovarList Batch,Array,data_provider \
--keep UKB.EUR.keep \
--maxCatLevels 107 \
--bsize 400 \
--pred fit_bin_l1_${i}_pred.list \
--out step2/ReGENIE_Step2_chr${j} \
--gz \
--threads 8 
done

# X chromosome
regenie_v3.2.4.gz_x86_64_Linux \
--step 2 \
--bgen ukb_imp_chrX \
--sample ukb_chr1.sample \
--extract ukb_maf1_snp95_hwe10_var_list_chrX.txt \
--covarFile covariates.txt \
--phenoFile ${i}.txt \
--phenoColList ${i} \
--covarColList Batch,Array,PC{1:10},birth_year,drug_first_year,data_provider,Sex \
--catCovarList Batch,Array,data_provider,Sex \
--keep UKB.EUR.keep \
--maxCatLevels 107 \
--bsize 400 \
--pred fit_bin_l1_${i}_pred.list \
--out step2/ReGENIE_Step2_chrX \
--gz \
--threads 8 
done 

################### binary outcomes #############################
for i in $(cat phenotype_list_binary.txt); do

# step 1
base_command="regenie_v3.2.4.gz_x86_64_Linux \
--step 1 \
--covarFile covariates.txt \
--phenoFile ${i}.txt \
--phenoColList ${i} \
--keep UKB.EUR.keep \
--covarColList Batch,Array,PC{1:10},birth_year,drug_first_year,data_provider \
--catCovarList Batch,Array,data_provider \
--maxCatLevels 107 \
--bsize 1000 \
--threads 8 \
--bt \
--gz"

# stage 1
$base_command \
--bed ukb_maf1_snp99_hwe10_exclMTchr \
--out fit_bin_l0_${i} \
--split-l0 fit_bin_parallel_${i},$njobs

# stage 2
for job in $(seq 1 $njobs); do
    $base_command \
    --bed ukb_maf1_snp99_hwe10_exclMTchr \
    --out fit_bin_l0_${i}_$job \
    --run-l0 fit_bin_parallel_${i}.master,$job
done

# stage 3
$base_command \
--bed ukb_maf1_snp99_hwe10_exclMTchr \
--out fit_bin_l1_${i} \
--run-l1 fit_bin_parallel_${i}.master \
--keep-l0

# step 2
for j in $(seq 1 22); do
regenie_v3.2.4.gz_x86_64_Linux \
--step 2 \
--bgen ukb_imp_chr${j} \
--sample ukb_chr1.sample \
--extract ukb_maf1_snp95_hwe10_var_list_chr${j}.txt \
--covarFile covariates.txt \
--phenoFile ${i}.txt \
--phenoColList ${i} \
--covarColList Batch,Array,PC{1:10},birth_year,drug_first_year,data_provider \
--catCovarList Batch,Array,data_provider \
--keep UKB.EUR.keep \
--maxCatLevels 107 \
--bsize 400 \
--pred fit_bin_l1_${i}_pred.list \
--out step2/ReGENIE_Step2_chr${j} \
--bt \
--gz \
--threads 8 
done

# X chromosome
regenie_v3.2.4.gz_x86_64_Linux \
--step 2 \
--bgen ukb_imp_chrX \
--sample ukb_chr1.sample \
--extract ukb_maf1_snp95_hwe10_var_list_chrX.txt \
--covarFile covariates.txt \
--phenoFile ${i}.txt \
--phenoColList ${i} \
--covarColList Batch,Array,PC{1:10},birth_year,drug_first_year,data_provider,Sex \
--catCovarList Batch,Array,data_provider,Sex \
--keep UKB.EUR.keep \
--maxCatLevels 107 \
--bsize 400 \
--pred fit_bin_l1_${i}_pred.list \
--out step2/ReGENIE_Step2_chrX \
--bt \
--gz \
--threads 8 
done 
