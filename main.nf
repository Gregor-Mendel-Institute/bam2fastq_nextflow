#!/usr/bin/env nextflow

/**************
 * Parameters
 **************/

params.bam 		= "bam/*.bam"
params.seqtype 		= 'PR' // 'SR'
params.output        	= "results/"

/***********************
 * Channel for bam files
 ***********************/

bam_files = Channel
          .fromPath(params.bam)
          .map { file -> [ id:file.baseName,file:file] }


/********************** 
 * SORT BAM
 **********************/

process sortBam {
tag "sort: $id"

        input:
        set id, file(bam) from bam_files
        output:

        set id, file("${id}.sort.bam") into bam_sorted
	
        script:
        """
        samtools sort -n $bam -o ${id}.sort.bam
        """
}

/*********************
 * BAM TO FASTQ
 *********************/

process generateFastq {
publishDir "$params.output", mode: 'copy'
tag "bam : $name, type:$params.seqtype"

        input:
        set  name, file(bam) from bam_sorted
        
	output:
        set name, file('*.fastq') into fastqs
        
	script:
        if (params.seqtype=='SR'){
        """
        bedtools bamtofastq -i ${bam} -fq ${name}_1.fastq
        """
        }
        else {
        """
        bedtools bamtofastq -i ${bam} -fq ${name}_1.fastq -fq2 ${name}_2.fastq
        """
        }

}

