#!/bin/bash

cd ldsc
for i in $(cat phenotype_list.txt); do
for j in $(cat sumstats_list.txt); do
ldsc.py \
--rg ${i}.sumstats.gz,disorder_sumstats/${j}.sumstats.gz \
--ref-ld-chr eur_w_ld_chr/ \
--w-ld-chr eur_w_ld_chr/ \
--out correlation/rg_incp1_${i}_${j} \
--intercept-h2 1,1
done
done