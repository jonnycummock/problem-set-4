#! /usr/bin/env bash

factorx='/Users/jonny/RStudio/problem-set-4/data'

#needs to be unzipped first
#gunzip hg19.chr1.fa.gz
#gunzip factorx.chr1.fq.gz

#build index with bowtie2-build of chr1
bowtie2-build $factorx/hg19.chr1.fa hg19.chr1

#align factorx to genome and sort bam file
bowtie2 -x hg19.chr1 -U factorx.chr1.fq \
    | samtools sort -o factorx.sort.bam

#create bedgraph file with factorx signal
bedtools genomecov -ibam factorx.sort.bam -g hg19.chrom.sizes -bg > factorx.bg

#creat BigWig file for UCSC web
bedGraphToBigWig factorx.bg hg19.chrom.sizes factorx.bw

#call peaks
macs2 callpeak -t factorx.sort.bam -f BAM -n factorx

#make all peaks 200bp narrow
bedtools slop -i factorx_summits.bed -g hg19.chrom.sizes -b 100 > factorx_peaks.200.bed

#randomly select 1000 for motifs
shuf factorx_peaks.200.bed | head -n 1000 > factorx_random1000.bed

#generate motifs from peak calls
bedtools getfasta -fi hg19.chr1.fa -bed factorx_random1000.bed -fo factorx_random.fa

#derive motifs
meme factorx_random.fa -nmotifs 1 -maxw 20 -minw 8 -dna -maxsize 1000000

#get motif matrix for input into tomtom to search for motif
meme-get-motif -id 1 < meme_out/meme.txt


