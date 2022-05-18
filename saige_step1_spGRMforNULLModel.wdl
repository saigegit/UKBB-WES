version 1.0

workflow saige_null_sGRM {
	
	input {
        File bedfile
        File bimfile
        File famfile
    	File phenofile
    	File spGRMfile
    	File spGRMSamplefile
    	String output_prefix
    	String phenoCol
    	String traitType
        String invNormalize
        String sampleIDCol
        String covariatesList
        String qCovarColList

    }

    call null {
    	input : phenofile = phenofile, bedfile = bedfile, bimfile = bimfile, famfile = famfile, spGRMfile = spGRMfile, spGRMSamplefile= spGRMSamplefile, output_prefix=output_prefix, phenoCol=phenoCol, traitType=traitType, invNormalize=invNormalize, sampleIDCol=sampleIDCol, covariatesList=covariatesList, qCovarColList=qCovarColList
    }

    output {

        File modelfile = null.modelfile
        File vrfile = null.vrfile

    }	

}

task null {
	input {

    	File bedfile
        File bimfile
        File famfile
    	File spGRMfile
    	File spGRMSamplefile
        File phenofile
    	String output_prefix
    	String phenoCol
    	String traitType
        String invNormalize
        String sampleIDCol
        String covariatesList
        String qCovarColList
    }

    command <<<
    	set -euo pipefail
    	/usr/bin/time -o ~{output_prefix}.runinfo.txt -v step1_fitNULLGLMM.R  \
                --bedFile=~{bedfile} \
                --bimFile=~{bimfile} \
                --famFile=~{famfile} \
     		--phenoFile=~{phenofile} \
    		--outputPrefix=~{output_prefix} \
    		--sparseGRMFile=~{spGRMfile} \
                --sparseGRMSampleIDFile=~{spGRMSamplefile} \
    		--traitType=~{traitType}  \
    		--phenoCol=~{phenoCol} \
    		--sampleIDColinphenoFile=~{sampleIDCol} \
    		--covarColList=~{covariatesList} \
                --qCovarColList=~{qCovarColList} \
		--LOCO=FALSE \
		--useSparseGRMtoFitNULL=TRUE \
                --isCateVarianceRatio=TRUE \ 
    		--nThreads=1 \
    		--minCovariateCount=10 \
    		--relatednessCutoff=0.05 \
    		--invNormalize=~{invNormalize} 		
    >>>

    output {

        File modelfile = output_prefix + ".rda"
        File vrfile = output_prefix + ".varianceRatio.txt"
        File runinfofile = output_prefix + ".runinfo.txt"

    }

    runtime {
        docker: "dx://saige:/SAIGE_GENE/docker_images/saige_1.0.9.tar.gz"
    }
}

