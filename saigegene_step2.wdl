version 1.0

        
workflow saige_gene_step2 {
	
   input {
        File GMMATmodelFile
        File varianceRatioFile
    	File spGRMfile
    	File spGRMSamplefile
    	File bed
    	File bim
    	File fam
    	File grpfile
    	String chrom
        String maxMAF_in_groupTest
        String annotation_in_groupTest
    	String output_prefix
        String isFast
    }

    call step2_test {
    	input : GMMATmodelFile = GMMATmodelFile, varianceRatioFile = varianceRatioFile, spGRMfile = spGRMfile, spGRMSamplefile = spGRMSamplefile, bed = bed, bim = bim, fam = fam, grpfile = grpfile, chrom = chrom, output_prefix = output_prefix, isFast = isFast, maxMAF_in_groupTest = maxMAF_in_groupTest, annotation_in_groupTest = annotation_in_groupTest
    }

    output {

        File outfile = step2_test.outfile
        File outfile_single = step2_test.outfile_single
        File runinfofile = step2_test.runinfofile
        File outfile_index = step2_test.outfile_index
    }	

}


task step2_test {

    input {
        File GMMATmodelFile
        File varianceRatioFile
    	File spGRMfile
    	File spGRMSamplefile
    	File bed
    	File bim
    	File fam
    	File grpfile
    	String chrom
        String maxMAF_in_groupTest
        String annotation_in_groupTest
    	String output_prefix
        String isFast
    }
    Int actual_disk_gb = ceil(2 * (size(bed, "G") + size(bim, "G") + size(GMMATmodelFile, "G")))

    command <<<
    	set -euo pipefail
    	/usr/bin/time -o ~{output_prefix}.runinfo.txt -v step2_SPAtests.R  \
        --LOCO=FALSE \
        --bim=~{bim}    \
        --bed=~{bed}    \
        --fam=~{fam}  \
        --GMMATmodelFile=~{GMMATmodelFile}    \
        --varianceRatioFile=~{varianceRatioFile} \
        --SAIGEOutputFile=~{output_prefix} \
        --chrom=~{chrom} --minMAF=0 --AlleleOrder=alt-first --minMAC=0.5 \
        --sparseGRMFile=~{spGRMfile} \
        --sparseGRMSampleIDFile=~{spGRMSamplefile} \
        --groupFile=~{grpfile} \
        --maxMAF_in_groupTest=~{maxMAF_in_groupTest} \
        --annotation_in_groupTest=~{annotation_in_groupTest} \
        --relatednessCutoff=0.05 \
        --is_fastTest=~{isFast}
    >>>

    output {

        File outfile = output_prefix
        File outfile_single = output_prefix + ".singleAssoc.txt"
        File runinfofile = output_prefix + ".runinfo.txt"
        File outfile_index = output_prefix + ".index"
    }

    runtime {

        docker: "dx://saige:/SAIGE_GENE/docker_images/saige_1.0.9.tar.gz"
    }
}

